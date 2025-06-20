use clap::{Parser, Subcommand};
use crate::error::AppResult;
use crate::config::{Config, RoleConfig};
use crate::aws::{AwsClient, Credentials};

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
pub struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Configure a new role
    Configure {
        /// Name of the role configuration
        #[arg(short, long)]
        name: String,
        
        /// AWS Role ARN
        #[arg(short, long)]
        role_arn: String,
        
        /// AWS Account ID
        #[arg(short, long)]
        account_id: String,
        
        /// Source profile (optional)
        #[arg(short, long)]
        source_profile: Option<String>,
    },
    
    /// Assume a configured role
    Assume {
        /// Name of the role configuration to assume
        name: String,
        
        /// Duration in seconds (optional, default: 3600)
        #[arg(short, long)]
        duration: Option<i32>,
        
        /// Export format (json, export)
        #[arg(short, long, default_value = "export")]
        format: String,
        
        /// Execute a command with the assumed role credentials
        #[arg(short, long)]
        exec: Option<String>,
    },
    
    /// List configured roles
    List,
    
    /// Remove a configured role
    Remove {
        /// Name of the role configuration to remove
        name: String,
    },
}

impl Cli {
    pub async fn run() -> AppResult<()> {
        let cli = Cli::parse();
        let mut config = Config::load()?;

        match &cli.command {
            Commands::Configure { name, role_arn, account_id, source_profile } => {
                let role = RoleConfig {
                    name: name.clone(),
                    role_arn: role_arn.clone(),
                    account_id: account_id.clone(),
                    source_profile: source_profile.clone(),
                };
                
                config.add_role(role);
                config.save()?;
                println!("Role '{}' configured successfully", name);
            }
            
            Commands::Assume { name, duration, format, exec } => {
                let role = config.get_role(name)
                    .ok_or_else(|| crate::error::AppError::CliError(format!("Role '{}' not found", name)))?;
                
                let aws_client = AwsClient::new().await?;
                let credentials = aws_client.assume_role(role, *duration).await?;
                
                if let Some(command) = exec {
                    execute_with_credentials(&credentials, command).await?;
                } else {
                    output_credentials_for_shell(&credentials, format, name)?;
                }
            }
            
            Commands::List => {
                if config.roles.is_empty() {
                    println!("No roles configured");
                    return Ok(());
                }
                
                println!("Configured roles:");
                for role in &config.roles {
                    println!("- {} ({})", role.name, role.role_arn);
                }
            }
            
            Commands::Remove { name } => {
                if config.remove_role(name) {
                    config.save()?;
                    println!("Role '{}' removed successfully", name);
                } else {
                    println!("Role '{}' not found", name);
                }
            }
        }

        Ok(())
    }
}

fn output_credentials_for_shell(credentials: &Credentials, format: &str, role_name: &str) -> AppResult<()> {
    match format {
        "json" => {
            println!("{{");
            println!("  \"AccessKeyId\": \"{}\",", credentials.access_key_id);
            println!("  \"SecretAccessKey\": \"{}\",", credentials.secret_access_key);
            if let Some(token) = &credentials.session_token {
                println!("  \"SessionToken\": \"{}\",", token);
            }
            if let Some(expiration) = &credentials.expiration {
                println!("  \"Expiration\": \"{}\"", expiration.duration_since(std::time::UNIX_EPOCH).unwrap().as_secs());
            }
            println!("}}");
        }
        _ => {
            // Default export format - optimized for the target shell
            output_shell_exports(credentials, role_name)?;
        }
    }
    Ok(())
}

#[cfg(target_os = "windows")]
fn output_shell_exports(credentials: &Credentials, role_name: &str) -> AppResult<()> {
    // Check if we're in PowerShell or Command Prompt
    use std::env;
    
    if env::var("PSModulePath").is_ok() {
        // PowerShell format
        println!("$env:AWS_ACCESS_KEY_ID = \"{}\"", credentials.access_key_id);
        println!("$env:AWS_SECRET_ACCESS_KEY = \"{}\"", credentials.secret_access_key);
        if let Some(token) = &credentials.session_token {
            println!("$env:AWS_SESSION_TOKEN = \"{}\"", token);
        }
        println!("Write-Host \"✅ Assumed role: {}\" -ForegroundColor Green", role_name);
    } else {
        // Command Prompt format
        println!("set AWS_ACCESS_KEY_ID={}", credentials.access_key_id);
        println!("set AWS_SECRET_ACCESS_KEY={}", credentials.secret_access_key);
        if let Some(token) = &credentials.session_token {
            println!("set AWS_SESSION_TOKEN={}", token);
        }
        println!("echo ✅ Assumed role: {}", role_name);
    }
    
    Ok(())
}

#[cfg(not(target_os = "windows"))]
fn output_shell_exports(credentials: &Credentials, role_name: &str) -> AppResult<()> {
    use std::env;
    
    // Check for Fish shell
    if let Ok(shell) = env::var("SHELL") {
        if shell.contains("fish") {
            println!("set -gx AWS_ACCESS_KEY_ID \"{}\"", credentials.access_key_id);
            println!("set -gx AWS_SECRET_ACCESS_KEY \"{}\"", credentials.secret_access_key);
            if let Some(token) = &credentials.session_token {
                println!("set -gx AWS_SESSION_TOKEN \"{}\"", token);
            }
            println!("echo \"✅ Assumed role: {}\"", role_name);
            return Ok(());
        }
    }
    
    // Default to bash/zsh format
    println!("export AWS_ACCESS_KEY_ID=\"{}\"", credentials.access_key_id);
    println!("export AWS_SECRET_ACCESS_KEY=\"{}\"", credentials.secret_access_key);
    if let Some(token) = &credentials.session_token {
        println!("export AWS_SESSION_TOKEN=\"{}\"", token);
    }
    println!("echo \"✅ Assumed role: {}\"", role_name);
    
    Ok(())
}

async fn execute_with_credentials(credentials: &Credentials, command: &str) -> AppResult<()> {
    use std::process::Command;
    
    // Parse the command string into command and args
    let mut parts = command.split_whitespace();
    let cmd = parts.next().ok_or_else(|| crate::error::AppError::CliError("Empty command".to_string()))?;
    let args: Vec<&str> = parts.collect();
    
    // Create the command with environment variables
    let mut child = Command::new(cmd);
    child.args(&args);
    child.env("AWS_ACCESS_KEY_ID", &credentials.access_key_id);
    child.env("AWS_SECRET_ACCESS_KEY", &credentials.secret_access_key);
    
    if let Some(token) = &credentials.session_token {
        child.env("AWS_SESSION_TOKEN", token);
    }
    
    // Execute the command
    let status = child.status().map_err(|e| crate::error::AppError::CliError(format!("Failed to execute command: {}", e)))?;
    
    if !status.success() {
        return Err(crate::error::AppError::CliError(format!("Command failed with exit code: {:?}", status.code())));
    }
    
    Ok(())
}


