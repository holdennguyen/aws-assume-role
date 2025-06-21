use crate::aws::{AwsClient, Credentials};
use crate::config::{Config, RoleConfig};
use crate::error::AppResult;
use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(
    author,
    version,
    about = "AWS Assume Role CLI - Switch between AWS IAM roles effortlessly",
    long_about = r#"AWS Assume Role CLI (awsr) - A fast, reliable tool for switching between AWS IAM roles.

BINARY NAMES:
  aws-assume-role  - The actual binary executable
  awsr            - Convenient wrapper script (recommended for daily use)

Both commands work identically. The 'awsr' wrapper provides shell integration
for direct credential setting without eval commands.

EXAMPLES:
  # Configure a new role
  awsr configure --name dev --role-arn arn:aws:iam::123456789012:role/DevRole --account-id 123456789012
  
  # Assume the role (sets credentials in current shell)
  awsr assume dev
  
  # List all configured roles
  awsr list
  
  # Verify prerequisites before assuming roles
  awsr verify
  
  # Get help for any command
  awsr help assume

PREREQUISITES:
  1. AWS CLI configured with valid credentials
  2. Permission to assume target roles (sts:AssumeRole)
  3. Target roles must trust your current identity

Run 'awsr verify' to check all prerequisites automatically."#
)]
pub struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Configure a new role
    #[command(long_about = r#"Configure a new AWS IAM role for easy switching.

EXAMPLES:
  # Basic role configuration
  awsr configure --name dev --role-arn arn:aws:iam::123456789012:role/DevRole --account-id 123456789012
  
  # With specific source profile
  awsr configure -n prod -r arn:aws:iam::987654321098:role/ProdRole -a 987654321098 -s my-profile

ROLE REQUIREMENTS:
  - The role must exist in the target AWS account
  - The role's trust policy must allow your current identity to assume it
  - You must have sts:AssumeRole permission for the role"#)]
    Configure {
        /// Name of the role configuration (used for 'awsr assume <name>')
        #[arg(short, long, help = "Friendly name for this role configuration")]
        name: String,

        /// AWS Role ARN to assume
        #[arg(
            short,
            long,
            help = "Full ARN of the IAM role (arn:aws:iam::ACCOUNT:role/ROLE-NAME)"
        )]
        role_arn: String,

        /// AWS Account ID where the role exists
        #[arg(short, long, help = "12-digit AWS account ID")]
        account_id: String,

        /// Source AWS profile to use (optional)
        #[arg(short, long, help = "AWS profile name from ~/.aws/credentials")]
        source_profile: Option<String>,

        /// Session duration in seconds (optional, default: 3600)
        #[arg(long, help = "Session duration in seconds (900-43200, default: 3600)")]
        session_duration: Option<i64>,
    },

    /// Assume a configured role and set credentials
    #[command(
        long_about = r#"Assume a configured role and set AWS credentials in the current shell.

EXAMPLES:
  # Assume role (default 1 hour session)
  awsr assume dev
  
  # Assume role with custom duration (2 hours)
  awsr assume dev --duration 7200
  
  # Output credentials in JSON format
  awsr assume dev --format json
  
  # Execute a command with the assumed role
  awsr assume dev --exec "aws s3 ls"

OUTPUT FORMATS:
  - export (default): Shell export statements for direct use
  - json: JSON format for programmatic use

The tool automatically detects your shell and outputs the appropriate format."#
    )]
    Assume {
        /// Name of the role configuration to assume
        #[arg(help = "Role name from 'awsr list'")]
        name: String,

        /// Session duration in seconds (default: 3600)
        #[arg(
            short,
            long,
            help = "Session duration in seconds (900-43200, default: 3600)"
        )]
        duration: Option<i32>,

        /// Output format for credentials
        #[arg(
            short,
            long,
            default_value = "export",
            help = "Output format: 'export' or 'json'"
        )]
        format: String,

        /// Execute a command with the assumed role credentials
        #[arg(short, long, help = "Command to execute with assumed role credentials")]
        exec: Option<String>,
    },

    /// List all configured roles
    #[command(long_about = r#"List all configured AWS IAM roles.

Shows role names, ARNs, and account IDs for all configured roles.
Use 'awsr assume <name>' to assume any of the listed roles."#)]
    List,

    /// Remove a configured role
    #[command(long_about = r#"Remove a configured AWS IAM role.

EXAMPLES:
  # Remove a role configuration
  awsr remove dev
  
This only removes the local configuration. It does not affect the actual IAM role in AWS."#)]
    Remove {
        /// Name of the role configuration to remove
        #[arg(help = "Role name from 'awsr list'")]
        name: String,
    },

    /// Verify AWS prerequisites and permissions
    #[command(
        long_about = r#"Verify that all prerequisites are met for assuming roles.

This command checks:
  1. AWS CLI installation and configuration
  2. Current AWS credentials validity
  3. Permission to assume configured roles
  4. IAM role trust policies (if accessible)

EXAMPLES:
  # Check all prerequisites
  awsr verify
  
  # Check specific role
  awsr verify --role dev

Run this command if you're having trouble assuming roles."#
    )]
    Verify {
        /// Specific role to verify (optional)
        #[arg(short, long, help = "Verify a specific role configuration")]
        role: Option<String>,

        /// Show detailed verification information
        #[arg(short, long, help = "Show detailed verification steps")]
        verbose: bool,
    },
}

impl Cli {
    pub async fn run() -> AppResult<()> {
        let cli = Cli::parse();
        let mut config = Config::load()?;

        match &cli.command {
            Commands::Configure {
                name,
                role_arn,
                account_id,
                source_profile,
                session_duration,
            } => {
                let role = RoleConfig {
                    name: name.clone(),
                    role_arn: role_arn.clone(),
                    account_id: account_id.clone(),
                    source_profile: source_profile.clone(),
                    session_duration: *session_duration,
                };

                // Test the role configuration before saving
                println!("🔧 Configuring role '{}'...", name);
                let aws_client = AwsClient::new().await?;

                print!("🔍 Testing role assumption... ");
                match aws_client.test_assume_role(&role).await {
                    Ok(true) => {
                        println!("✅ Success!");
                        config.add_role(role);
                        config.save()?;
                        println!("✅ Role '{}' configured successfully", name);
                        println!("   Use 'awsr assume {}' to assume this role", name);
                    }
                    Ok(false) => {
                        println!("❌ Failed!");
                        println!("⚠️  Warning: Cannot assume role '{}'", name);
                        println!("   The role configuration will be saved, but you may not be able to assume it.");
                        println!("   Possible issues:");
                        println!("   - Role doesn't exist in account {}", account_id);
                        println!("   - Role trust policy doesn't allow your current identity");
                        println!("   - You don't have sts:AssumeRole permission");
                        println!();
                        print!("   Save configuration anyway? (y/N): ");

                        use std::io::{self, Write};
                        io::stdout().flush().unwrap();
                        let mut input = String::new();
                        io::stdin().read_line(&mut input).unwrap();
                        let input = input.trim().to_lowercase();

                        if input == "y" || input == "yes" {
                            config.add_role(role);
                            config.save()?;
                            println!("✅ Role '{}' configured (with warnings)", name);
                            println!("   Run 'awsr verify --role {}' to troubleshoot", name);
                        } else {
                            println!("❌ Role configuration cancelled");
                        }
                    }
                    Err(e) => {
                        println!("⚠️  Error testing role: {}", e);
                        config.add_role(role);
                        config.save()?;
                        println!("✅ Role '{}' configured (could not verify)", name);
                        println!(
                            "   Run 'awsr verify --role {}' to test the configuration",
                            name
                        );
                    }
                }
            }

            Commands::Assume {
                name,
                duration,
                format,
                exec,
            } => {
                let role = config.get_role(name).ok_or_else(|| {
                    crate::error::AppError::CliError(format!("Role '{}' not found", name))
                })?;

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

            Commands::Verify { role, verbose } => {
                verify_prerequisites(&config, role.as_deref(), *verbose).await?;
            }
        }

        Ok(())
    }
}

fn output_credentials_for_shell(
    credentials: &Credentials,
    format: &str,
    role_name: &str,
) -> AppResult<()> {
    match format {
        "json" => {
            println!("{{");
            println!("  \"AccessKeyId\": \"{}\",", credentials.access_key_id);
            println!(
                "  \"SecretAccessKey\": \"{}\",",
                credentials.secret_access_key
            );
            if let Some(token) = &credentials.session_token {
                println!("  \"SessionToken\": \"{}\",", token);
            }
            if let Some(expiration) = &credentials.expiration {
                println!(
                    "  \"Expiration\": \"{}\"",
                    expiration
                        .duration_since(std::time::UNIX_EPOCH)
                        .unwrap()
                        .as_secs()
                );
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
        println!(
            "$env:AWS_SECRET_ACCESS_KEY = \"{}\"",
            credentials.secret_access_key
        );
        if let Some(token) = &credentials.session_token {
            println!("$env:AWS_SESSION_TOKEN = \"{}\"", token);
        }
        println!(
            "Write-Host \"✅ Assumed role: {}\" -ForegroundColor Green",
            role_name
        );
    } else {
        // Command Prompt format
        println!("set AWS_ACCESS_KEY_ID={}", credentials.access_key_id);
        println!(
            "set AWS_SECRET_ACCESS_KEY={}",
            credentials.secret_access_key
        );
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
            println!(
                "set -gx AWS_ACCESS_KEY_ID \"{}\"",
                credentials.access_key_id
            );
            println!(
                "set -gx AWS_SECRET_ACCESS_KEY \"{}\"",
                credentials.secret_access_key
            );
            if let Some(token) = &credentials.session_token {
                println!("set -gx AWS_SESSION_TOKEN \"{}\"", token);
            }
            println!("echo \"✅ Assumed role: {}\"", role_name);
            return Ok(());
        }
    }

    // Default to bash/zsh format
    println!("export AWS_ACCESS_KEY_ID=\"{}\"", credentials.access_key_id);
    println!(
        "export AWS_SECRET_ACCESS_KEY=\"{}\"",
        credentials.secret_access_key
    );
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
    let cmd = parts
        .next()
        .ok_or_else(|| crate::error::AppError::CliError("Empty command".to_string()))?;
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
    let status = child.status().map_err(|e| {
        crate::error::AppError::CliError(format!("Failed to execute command: {}", e))
    })?;

    if !status.success() {
        return Err(crate::error::AppError::CliError(format!(
            "Command failed with exit code: {:?}",
            status.code()
        )));
    }

    Ok(())
}

async fn verify_prerequisites(
    config: &Config,
    specific_role: Option<&str>,
    verbose: bool,
) -> AppResult<()> {
    println!("🔍 Verifying AWS prerequisites...\n");

    let mut all_checks_passed = true;

    // Check 1: AWS CLI Installation
    if verbose {
        println!("Checking AWS CLI installation...");
    }
    match AwsClient::check_aws_cli() {
        Ok(true) => println!("✅ AWS CLI is installed and accessible"),
        Ok(false) => {
            println!("❌ AWS CLI is not installed or not in PATH");
            println!("   Install AWS CLI v2: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html");
            all_checks_passed = false;
        }
        Err(e) => {
            println!("⚠️  Could not verify AWS CLI installation: {}", e);
            all_checks_passed = false;
        }
    }

    // Check 2: AWS Credentials and Identity
    if verbose {
        println!("Checking AWS credentials...");
    }
    let aws_client = match AwsClient::new().await {
        Ok(client) => {
            println!("✅ AWS SDK initialized successfully");
            client
        }
        Err(e) => {
            println!("❌ Failed to initialize AWS SDK: {}", e);
            println!("   Check your AWS credentials configuration");
            all_checks_passed = false;
            return Ok(());
        }
    };

    // Check current identity
    match aws_client.verify_current_identity().await {
        Ok(identity) => {
            println!("✅ Current AWS identity verified");
            if verbose {
                println!("   Account: {}", identity.account);
                println!("   ARN: {}", identity.arn);
                println!("   User ID: {}", identity.user_id);
            }
        }
        Err(e) => {
            println!("❌ Failed to verify current AWS identity: {}", e);
            println!("   Ensure your AWS credentials are valid and not expired");
            println!("   Try: aws sts get-caller-identity");
            all_checks_passed = false;
        }
    }

    // Check 3: Role Configurations
    if config.roles.is_empty() {
        println!("⚠️  No roles configured yet");
        println!("   Run 'awsr configure --help' to add your first role");
    } else {
        println!("✅ Found {} configured role(s)", config.roles.len());

        // Check specific role or all roles
        let roles_to_check: Vec<&RoleConfig> = if let Some(role_name) = specific_role {
            match config.get_role(role_name) {
                Some(role) => vec![role],
                None => {
                    println!("❌ Role '{}' not found in configuration", role_name);
                    all_checks_passed = false;
                    vec![]
                }
            }
        } else {
            config.roles.iter().collect()
        };

        // Test role assumptions
        for role in roles_to_check {
            if verbose {
                println!("Testing role assumption for '{}'...", role.name);
            }

            match aws_client.test_assume_role(role).await {
                Ok(true) => {
                    println!("✅ Can assume role '{}' ({})", role.name, role.role_arn);
                }
                Ok(false) => {
                    println!("❌ Cannot assume role '{}' ({})", role.name, role.role_arn);
                    println!("   Possible issues:");
                    println!("   - Role doesn't exist in account {}", role.account_id);
                    println!("   - Role trust policy doesn't allow your current identity");
                    println!("   - You don't have sts:AssumeRole permission");
                    all_checks_passed = false;
                }
                Err(e) => {
                    println!("⚠️  Could not test role '{}': {}", role.name, e);
                    all_checks_passed = false;
                }
            }
        }
    }

    // Summary
    println!();
    if all_checks_passed {
        println!("🎉 All prerequisites verified successfully!");
        println!("   You're ready to assume roles with 'awsr assume <role-name>'");
    } else {
        println!("❌ Some prerequisites failed verification");
        println!("   Fix the issues above before assuming roles");
        println!();
        println!("💡 Common solutions:");
        println!("   1. Install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html");
        println!("   2. Configure credentials: aws configure");
        println!("   3. Check role trust policies in AWS IAM Console");
        println!("   4. Ensure you have sts:AssumeRole permission");
    }

    Ok(())
}
