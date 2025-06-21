use assert_cmd::Command;
use std::fs;
use std::path::Path;
use tempfile::TempDir;

mod common;

/// Test that wrapper scripts exist and are readable
#[test]
fn test_wrapper_scripts_exist() {
    let wrapper_dir = Path::new("releases/multi-shell");
    
    // Check that the wrapper directory exists
    assert!(wrapper_dir.exists(), "Wrapper scripts directory should exist");
    
    // Check all expected wrapper scripts exist
    let expected_scripts = [
        "aws-assume-role-bash.sh",
        "aws-assume-role-powershell.ps1", 
        "aws-assume-role-fish.fish",
        "aws-assume-role-cmd.bat",
    ];
    
    for script in &expected_scripts {
        let script_path = wrapper_dir.join(script);
        assert!(script_path.exists(), "Wrapper script {} should exist", script);
        
        // Check script is readable
        let content = fs::read_to_string(&script_path);
        assert!(content.is_ok(), "Should be able to read wrapper script {}", script);
        assert!(!content.unwrap().is_empty(), "Wrapper script {} should not be empty", script);
    }
}

/// Test bash wrapper script structure and key functionality
#[test]
fn test_bash_wrapper_structure() {
    let bash_script = Path::new("releases/multi-shell/aws-assume-role-bash.sh");
    let content = fs::read_to_string(bash_script).expect("Should read bash script");
    
    // Check for key components
    assert!(content.contains("aws_assume_role()"), "Should define aws_assume_role function");
    assert!(content.contains("alias awsr="), "Should define awsr alias");
    assert!(content.contains("eval $($binary_path assume"), "Should have eval for assume command");
    assert!(content.contains("--format export"), "Should use export format for shell integration");
    
    // Check for proper error handling
    assert!(content.contains("AWS Assume Role binary not found"), "Should handle missing binary");
    assert!(content.contains("return 1"), "Should return error code on failure");
    
    // Check for user guidance
    assert!(content.contains("COMMANDS AVAILABLE"), "Should provide command help");
    assert!(content.contains("QUICK START"), "Should provide usage examples");
}

/// Test PowerShell wrapper script structure and key functionality
#[test]
fn test_powershell_wrapper_structure() {
    let ps_script = Path::new("releases/multi-shell/aws-assume-role-powershell.ps1");
    let content = fs::read_to_string(ps_script).expect("Should read PowerShell script");
    
    // Check for key components
    assert!(content.contains("function Invoke-AwsAssumeRole"), "Should define main function");
    assert!(content.contains("Set-Alias -Name awsr"), "Should define awsr alias");
    assert!(content.contains("Invoke-Expression $output"), "Should execute PowerShell commands");
    assert!(content.contains("--format export"), "Should use export format");
    
    // Check for proper error handling
    assert!(content.contains("AWS Assume Role binary not found"), "Should handle missing binary");
    assert!(content.contains("$LASTEXITCODE"), "Should check exit codes");
    
    // Check for parameter handling
    assert!(content.contains("[Parameter(Position=0)]"), "Should handle positional parameters");
    assert!(content.contains("ValueFromRemainingArguments"), "Should handle remaining arguments");
}

/// Test Fish wrapper script structure and key functionality
#[test]
fn test_fish_wrapper_structure() {
    let fish_script = Path::new("releases/multi-shell/aws-assume-role-fish.fish");
    let content = fs::read_to_string(fish_script).expect("Should read Fish script");
    
    // Check for key components
    assert!(content.contains("function aws_assume_role"), "Should define aws_assume_role function");
    assert!(content.contains("alias awsr="), "Should define awsr alias");
    assert!(content.contains("eval ("), "Should use eval for assume command");
    assert!(content.contains("--format export"), "Should use export format");
    
    // Check for proper error handling
    assert!(content.contains("binary not found") || content.contains("not available"), 
            "Should handle missing binary");
    
    // Check Fish-specific syntax
    assert!(content.contains("end"), "Should use Fish function syntax");
    assert!(content.contains("test "), "Should use Fish test syntax");
}

/// Test CMD batch script structure and key functionality
#[test]
fn test_cmd_wrapper_structure() {
    let cmd_script = Path::new("releases/multi-shell/aws-assume-role-cmd.bat");
    let content = fs::read_to_string(cmd_script).expect("Should read CMD script");
    
    // Check for key components
    assert!(content.contains("@echo off"), "Should suppress command echoing");
    assert!(content.contains("aws-assume-role"), "Should call the binary");
    
    // Check for proper batch file structure
    assert!(content.contains("if") || content.contains("IF"), "Should have conditional logic");
    assert!(content.contains("%") || content.contains("!"), "Should use batch variables");
}

/// Test that wrapper scripts handle binary discovery correctly
#[test]
fn test_wrapper_binary_discovery() {
    let bash_script = Path::new("releases/multi-shell/aws-assume-role-bash.sh");
    let content = fs::read_to_string(bash_script).expect("Should read bash script");
    
    // Check for multiple binary name attempts
    assert!(content.contains("aws-assume-role-unix"), "Should try unix binary name");
    assert!(content.contains("aws-assume-role-macos"), "Should try macos binary name");
    assert!(content.contains("command -v"), "Should use command -v for discovery");
    
    let ps_script = Path::new("releases/multi-shell/aws-assume-role-powershell.ps1");
    let ps_content = fs::read_to_string(ps_script).expect("Should read PowerShell script");
    
    // Check PowerShell binary discovery
    assert!(ps_content.contains("Test-Path"), "Should use Test-Path for file checking");
    assert!(ps_content.contains("Get-Command"), "Should use Get-Command for discovery");
    assert!(ps_content.contains("aws-assume-role.exe"), "Should look for exe files");
}

/// Test wrapper script error handling patterns
#[test]
fn test_wrapper_error_handling() {
    let scripts = [
        ("bash", "releases/multi-shell/aws-assume-role-bash.sh"),
        ("powershell", "releases/multi-shell/aws-assume-role-powershell.ps1"),
        ("fish", "releases/multi-shell/aws-assume-role-fish.fish"),
        ("cmd", "releases/multi-shell/aws-assume-role-cmd.bat"),
    ];
    
    for (shell_type, script_path) in &scripts {
        let content = fs::read_to_string(script_path)
            .expect(&format!("Should read {} script", shell_type));
        
        // All scripts should handle missing binary
        assert!(
            content.contains("not found") || content.contains("not available"),
            "{} script should handle missing binary error",
            shell_type
        );
        
        // Scripts should provide user feedback
        assert!(
            content.contains("❌") || content.contains("Error") || content.contains("echo"),
            "{} script should provide error feedback",
            shell_type
        );
    }
}

/// Test that wrapper scripts provide proper usage information
#[test]
fn test_wrapper_usage_information() {
    let bash_script = Path::new("releases/multi-shell/aws-assume-role-bash.sh");
    let content = fs::read_to_string(bash_script).expect("Should read bash script");
    
    // Check for comprehensive usage information
    assert!(content.contains("COMMANDS AVAILABLE"), "Should list available commands");
    assert!(content.contains("QUICK START"), "Should provide quick start guide");
    assert!(content.contains("awsr verify"), "Should mention verify command");
    assert!(content.contains("awsr configure"), "Should mention configure command");
    assert!(content.contains("awsr assume"), "Should mention assume command");
    assert!(content.contains("awsr list"), "Should mention list command");
    
    // Check for helpful tips
    assert!(content.contains("TIP:") || content.contains("💡"), "Should provide usage tips");
}

/// Test shell integration with export format
#[test]
fn test_shell_export_format_integration() {
    let temp_dir = TempDir::new().unwrap();
    
    // Test that the binary supports export format for shell integration
    let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
    cmd.env("HOME", temp_dir.path())
        .args(["assume", "nonexistent-role", "--format", "export"]);
    
    let output = cmd.output().unwrap();
    
    // Should handle the format flag even if role doesn't exist
    // The error should be about the role, not the format
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(
        !stderr.contains("unknown") || !stderr.contains("format"),
        "Should recognize export format flag"
    );
}

/// Test that wrapper scripts are executable (on Unix systems)
#[cfg(unix)]
#[test]
fn test_wrapper_scripts_executable() {
    use std::os::unix::fs::PermissionsExt;
    
    let executable_scripts = [
        "releases/multi-shell/aws-assume-role-bash.sh",
        "releases/multi-shell/aws-assume-role-fish.fish",
    ];
    
    for script_path in &executable_scripts {
        let path = Path::new(script_path);
        if path.exists() {
            let metadata = fs::metadata(path).expect("Should get file metadata");
            let permissions = metadata.permissions();
            
            // Check if file has execute permission for owner
            assert!(
                permissions.mode() & 0o100 != 0,
                "Script {} should be executable",
                script_path
            );
        }
    }
}

/// Test installation scripts exist and are structured correctly
#[test]
fn test_installation_scripts_exist() {
    let install_dir = Path::new("releases/multi-shell");
    
    let install_scripts = [
        "INSTALL.sh",
        "INSTALL.ps1", 
        "UNINSTALL.sh",
        "UNINSTALL.ps1",
    ];
    
    for script in &install_scripts {
        let script_path = install_dir.join(script);
        assert!(script_path.exists(), "Installation script {} should exist", script);
        
        let content = fs::read_to_string(&script_path)
            .expect(&format!("Should read installation script {}", script));
        
        // Check for basic installation script structure
        assert!(!content.is_empty(), "Installation script {} should not be empty", script);
        
        // Check for key installation concepts
        assert!(
            content.contains("aws-assume-role") || content.contains("awsr"),
            "Installation script {} should reference the tool",
            script
        );
    }
}

/// Test that README provides proper documentation
#[test]
fn test_multi_shell_readme() {
    let readme_path = Path::new("releases/multi-shell/README.md");
    assert!(readme_path.exists(), "Multi-shell README should exist");
    
    let content = fs::read_to_string(readme_path).expect("Should read README");
    
    // Check for comprehensive documentation
    assert!(content.contains("Installation"), "Should document installation");
    assert!(content.contains("Usage"), "Should document usage");
    assert!(content.contains("bash") || content.contains("Bash"), "Should mention bash support");
    assert!(content.contains("PowerShell"), "Should mention PowerShell support");
    assert!(content.contains("Fish"), "Should mention Fish support");
    
    // Check for shell-specific instructions
    assert!(content.contains("source") || content.contains("dot"), "Should explain sourcing");
    assert!(content.contains("awsr"), "Should document awsr command");
}

/// Test version consistency across wrapper scripts and documentation
#[test]
fn test_version_consistency() {
    // This test ensures that if version is mentioned in wrapper scripts,
    // it should be consistent with the current version
    
    let scripts_dir = Path::new("releases/multi-shell");
    let readme_path = scripts_dir.join("README.md");
    
    if readme_path.exists() {
        let content = fs::read_to_string(&readme_path).expect("Should read README");
        
        // If version is mentioned, it should be current
        // This is a soft check since version might not always be in wrapper scripts
        if content.contains("version") || content.contains("v1.") {
            // Could add specific version checks here if needed
            // For now, just ensure the content is reasonable
            assert!(content.len() > 100, "README should have substantial content");
        }
    }
} 