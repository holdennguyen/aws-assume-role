use std::fs;
use std::path::Path;

mod common;

/// Test that all shell wrapper scripts exist and have basic structure
#[test]
fn test_shell_wrappers_exist() {
    let wrapper_scripts = [
        "releases/multi-shell/aws-assume-role-bash.sh",
        "releases/multi-shell/aws-assume-role-powershell.ps1", 
        "releases/multi-shell/aws-assume-role-fish.fish",
        "releases/multi-shell/aws-assume-role-cmd.bat",
    ];

    for script in &wrapper_scripts {
        assert!(
            Path::new(script).exists(),
            "Wrapper script {} should exist",
            script
        );
    }
}

/// Test bash/zsh wrapper script structure and functionality
#[test]
fn test_bash_wrapper_structure() {
    let script_path = "releases/multi-shell/aws-assume-role-bash.sh";
    let content = fs::read_to_string(script_path)
        .unwrap_or_else(|_| panic!("Should read bash wrapper script"));

    // Check shebang
    assert!(content.starts_with("#!/bin/bash"), "Should have bash shebang");
    
    // Check key functionality
    assert!(content.contains("aws_assume_role"), "Should define aws_assume_role function");
    assert!(content.contains("eval"), "Should use eval for credential setting");
    assert!(content.contains("--format export"), "Should use export format");
    
    // Check error handling
    assert!(content.contains("if") || content.contains("case"), "Should have conditional logic");
    assert!(content.contains("return 1"), "Should have error handling");
}

/// Test PowerShell wrapper script structure
#[test]
fn test_powershell_wrapper_structure() {
    let script_path = "releases/multi-shell/aws-assume-role-powershell.ps1";
    let content = fs::read_to_string(script_path)
        .unwrap_or_else(|_| panic!("Should read PowerShell wrapper script"));

    // Check PowerShell specific elements
    assert!(content.contains("Invoke-Expression") || content.contains("$env:"), 
            "Should handle environment variables");
    assert!(content.contains("aws-assume-role"), "Should reference main binary");
    
    // Check parameter handling
    assert!(content.contains("param") || content.contains("$args"), 
            "Should handle parameters");
}

/// Test Fish shell wrapper script structure
#[test]
fn test_fish_wrapper_structure() {
    let script_path = "releases/multi-shell/aws-assume-role-fish.fish";
    let content = fs::read_to_string(script_path)
        .unwrap_or_else(|_| panic!("Should read Fish wrapper script"));

    // Check Fish shell specific syntax
    assert!(content.contains("eval") && content.contains("--format export"), 
            "Should use eval with export format for environment variables");
    assert!(content.contains("aws-assume-role"), "Should reference main binary");
    
    // Check function definition (Fish uses functions)
    assert!(content.contains("function"), 
            "Should define function");
}

/// Test CMD batch wrapper script structure
#[test]
fn test_cmd_wrapper_structure() {
    let script_path = "releases/multi-shell/aws-assume-role-cmd.bat";
    let content = fs::read_to_string(script_path)
        .unwrap_or_else(|_| panic!("Should read CMD wrapper script"));

    // Check batch file elements
    assert!(content.contains("@echo off"), 
            "Should have batch file syntax");
    assert!(content.contains("aws-assume-role"), "Should reference main binary");
    
    // Check environment variable setting (CMD uses for loops to execute commands)
    assert!(content.contains("for /f") || content.contains("SET"), "Should handle command execution");
}

/// Test binary discovery logic across platforms
#[test]
fn test_binary_discovery() {
    let scripts = [
        ("releases/multi-shell/aws-assume-role-bash.sh", "bash"),
        ("releases/multi-shell/aws-assume-role-powershell.ps1", "powershell"),
        ("releases/multi-shell/aws-assume-role-fish.fish", "fish"),
    ];

    for (script_path, shell_type) in &scripts {
        let content = fs::read_to_string(script_path)
            .unwrap_or_else(|_| panic!("Should read {} script", shell_type));

        // Should have logic to find the binary
        assert!(
            content.contains("command -v") || 
            content.contains("Get-Command") ||
            content.contains("Test-Path") ||
            content.contains("test -f") ||
            content.contains("if [ -f"),
            "{} script should have binary discovery logic", shell_type
        );
    }
}

/// Test error handling patterns in wrapper scripts
#[test]
fn test_wrapper_error_handling() {
    let scripts = [
        ("releases/multi-shell/aws-assume-role-bash.sh", "bash"),
        ("releases/multi-shell/aws-assume-role-powershell.ps1", "powershell"),
        ("releases/multi-shell/aws-assume-role-fish.fish", "fish"),
        ("releases/multi-shell/aws-assume-role-cmd.bat", "cmd"),
    ];

    for (script_path, shell_type) in &scripts {
        let content = fs::read_to_string(script_path)
            .unwrap_or_else(|_| panic!("Should read {} script", shell_type));

        // Should have some form of error handling
        let has_error_handling = content.contains("if") || 
                                content.contains("try") || 
                                content.contains("catch") ||
                                content.contains("||") ||
                                content.contains("&&") ||
                                content.contains("exit") ||
                                content.contains("return") ||
                                content.contains("not found") ||
                                content.contains("Error") ||
                                content.contains("$?");

        assert!(has_error_handling, 
                "{} script should have error handling", shell_type);
    }
}

/// Test usage information in wrapper scripts
#[test]
fn test_wrapper_usage_info() {
    let scripts = [
        ("releases/multi-shell/aws-assume-role-bash.sh", "bash"),
        ("releases/multi-shell/aws-assume-role-powershell.ps1", "powershell"),
        ("releases/multi-shell/aws-assume-role-fish.fish", "fish"),
    ];

    for (script_path, shell_type) in &scripts {
        let content = fs::read_to_string(script_path)
            .unwrap_or_else(|_| panic!("Should read {} script", shell_type));

        // Should have usage information or help
        let has_usage = content.contains("Usage") ||
                       content.contains("usage") ||
                       content.contains("COMMANDS") ||
                       content.contains("echo") ||
                       content.contains("Write-Host") ||
                       content.contains("awsr");

        assert!(has_usage, 
                "{} script should have usage information", shell_type);
    }
}

/// Test export format integration for shell environments
#[test]
fn test_export_format_integration() {
    let shell_scripts = [
        ("releases/multi-shell/aws-assume-role-bash.sh", "--format export"),
        ("releases/multi-shell/aws-assume-role-fish.fish", "--format export"),
    ];

    for (script_path, expected_format) in &shell_scripts {
        let content = fs::read_to_string(script_path)
            .unwrap_or_else(|_| panic!("Should read shell script"));

        assert!(content.contains(expected_format), 
                "Script should use {} for environment variables", expected_format);
        
        // Should handle role assumption
        assert!(content.contains("assume"), 
                "Script should handle role assumption");
    }
}

/// Test executable permissions on Unix systems
#[cfg(unix)]
#[test]
fn test_unix_executable_permissions() {
    use std::os::unix::fs::PermissionsExt;
    
    let unix_scripts = [
        "releases/multi-shell/aws-assume-role-bash.sh",
        "releases/multi-shell/aws-assume-role-fish.fish",
    ];

    for script_path in &unix_scripts {
        let metadata = fs::metadata(script_path)
            .unwrap_or_else(|_| panic!("Should read metadata for {}", script_path));
        
        let permissions = metadata.permissions();
        let mode = permissions.mode();
        
        // Check if executable bit is set (at least for owner)
        assert!(mode & 0o100 != 0, 
                "Script {} should be executable", script_path);
    }
}

/// Test installation script validation
#[test]
fn test_installation_scripts() {
    let install_scripts = [
        "releases/multi-shell/INSTALL.sh",
        "releases/multi-shell/INSTALL.ps1",
    ];

    for script in &install_scripts {
        let content = fs::read_to_string(script)
            .unwrap_or_else(|_| panic!("Should read installation script {}", script));

        // Should reference the main binary or wrapper scripts
        assert!(content.contains("aws-assume-role"), 
                "Installation script should reference aws-assume-role");
        
        // Should have installation logic
        let has_install_logic = content.contains("install") ||
                               content.contains("copy") ||
                               content.contains("cp") ||
                               content.contains("Copy-Item") ||
                               content.contains("mv") ||
                               content.contains("Move-Item") ||
                               content.contains("chmod") ||
                               content.contains("mkdir");

        assert!(has_install_logic, 
                "Installation script {} should have installation logic", script);
    }
}

/// Test uninstallation script validation  
#[test]
fn test_uninstallation_scripts() {
    let uninstall_scripts = [
        "releases/multi-shell/UNINSTALL.sh", 
        "releases/multi-shell/UNINSTALL.ps1",
    ];

    for script in &uninstall_scripts {
        let content = fs::read_to_string(script)
            .unwrap_or_else(|_| panic!("Should read uninstallation script {}", script));

        // Should have removal logic
        let has_removal_logic = content.contains("remove") ||
                               content.contains("rm") ||
                               content.contains("Remove-Item") ||
                               content.contains("uninstall") ||
                               content.contains("delete") ||
                               content.contains("del");

        assert!(has_removal_logic, 
                "Uninstallation script {} should have removal logic", script);
    }
}

/// Test README documentation in multi-shell directory
#[test]
fn test_multishell_readme() {
    let readme_path = "releases/multi-shell/README.md";
    let content = fs::read_to_string(readme_path)
        .unwrap_or_else(|_| panic!("Should read multi-shell README"));

    // Should document the wrapper scripts
    assert!(content.contains("bash") || content.contains("Bash"), 
            "README should mention bash support");
    assert!(content.contains("PowerShell") || content.contains("powershell"), 
            "README should mention PowerShell support");
    assert!(content.contains("fish") || content.contains("Fish"), 
            "README should mention Fish shell support");
    
    // Should have installation instructions
    assert!(content.contains("install") || content.contains("Install"), 
            "README should have installation instructions");
}

/// Test version consistency across shell scripts
#[test]
fn test_version_consistency() {
    let script_files = [
        "releases/multi-shell/create-distribution.sh",
        "releases/multi-shell/README.md",
    ];

    for script_path in &script_files {
        if Path::new(script_path).exists() {
            let content = fs::read_to_string(script_path)
                .unwrap_or_else(|_| panic!("Should read {}", script_path));

            // Should reference version information
            let has_version = content.contains("1.") || 
                             content.contains("v1.") ||
                             content.contains("version") ||
                             content.contains("Version");

            assert!(has_version, 
                    "File {} should contain version information", script_path);
        }
    }
}

/// Test distribution creation script
#[test]
fn test_distribution_script() {
    let script_path = "releases/multi-shell/create-distribution.sh";
    let content = fs::read_to_string(script_path)
        .unwrap_or_else(|_| panic!("Should read distribution creation script"));

    // Should have build or distribution logic
    assert!(content.contains("cp") || content.contains("copy") || content.contains("tar"), 
            "Distribution script should have build/copy logic");
    
    // Should handle multiple platforms
    let has_platform_logic = content.contains("unix") ||
                            content.contains("windows") ||
                            content.contains("macos") ||
                            content.contains("exe") ||
                            content.contains(".sh");

    assert!(has_platform_logic, 
            "Distribution script should handle multiple platforms");
}

/// Test binary files exist (basic check)
#[test]
fn test_binary_files_exist() {
    let binaries = [
        "releases/multi-shell/aws-assume-role-macos",
        "releases/multi-shell/aws-assume-role-unix",
        "releases/multi-shell/aws-assume-role.exe",
    ];

    for binary in &binaries {
        assert!(Path::new(binary).exists(), 
                "Binary {} should exist", binary);
        
        // Check file size (should not be empty)
        let metadata = fs::metadata(binary)
            .unwrap_or_else(|_| panic!("Should read metadata for {}", binary));
        assert!(metadata.len() > 0, 
                "Binary {} should not be empty", binary);
    }
}

/// Test release notes exist and have content
#[test]
fn test_release_notes() {
    let release_notes_pattern = "releases/multi-shell/RELEASE_NOTES_v*.md";
    
    // Check if any release notes files exist
    let release_dir = Path::new("releases/multi-shell");
    if let Ok(entries) = fs::read_dir(release_dir) {
        let mut found_release_notes = false;
        
        for entry in entries.flatten() {
            let file_name = entry.file_name();
            let file_str = file_name.to_string_lossy();
            
            if file_str.starts_with("RELEASE_NOTES_v") && file_str.ends_with(".md") {
                found_release_notes = true;
                
                let content = fs::read_to_string(entry.path())
                    .unwrap_or_else(|_| panic!("Should read release notes file"));
                
                assert!(!content.trim().is_empty(), 
                        "Release notes should not be empty");
                
                // Should contain version or release information
                assert!(content.contains("v1.") || content.contains("Version") || 
                        content.contains("Release") || content.contains("Changes"),
                        "Release notes should contain version/release information");
            }
        }
        
        assert!(found_release_notes, 
                "Should find at least one release notes file matching pattern {}", 
                release_notes_pattern);
    }
}
