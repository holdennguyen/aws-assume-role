use std::fs;
use std::path::Path;

mod common;

/// Test that the essential release files exist.
#[test]
fn test_essential_files_exist() {
    let essential_files = [
        "releases/aws-assume-role-bash.sh",
        "releases/INSTALL.sh",
        "releases/UNINSTALL.sh",
        "releases/aws-assume-role-linux",
        "releases/aws-assume-role-macos",
        "releases/aws-assume-role-windows.exe",
    ];

    for file in &essential_files {
        assert!(
            Path::new(file).exists(),
            "Essential release file {} should exist",
            file
        );
    }
}

/// Test the universal bash wrapper script structure and cross-platform compatibility.
#[test]
fn test_universal_bash_wrapper_structure() {
    let script_path = "releases/aws-assume-role-bash.sh";
    let content = fs::read_to_string(script_path)
        .unwrap_or_else(|_| panic!("Should read bash wrapper script from {}", script_path));

    // 1. Universal bash compatibility
    assert!(
        content.starts_with("#!/bin/bash"),
        "Should have a bash shebang for universal compatibility."
    );
    assert!(
        content.contains("awsr() {") || content.contains("function awsr() {"),
        "Should define an 'awsr' function for shell integration."
    );
    assert!(
        !content.contains("alias awsr="),
        "Should not use an alias, must use a function for proper argument handling."
    );

    // 2. Cross-platform OS detection
    assert!(
        content.contains("uname -s"),
        "Should use uname -s for cross-platform OS detection."
    );
    assert!(
        content.contains("Linux*") && content.contains("Darwin*") && content.contains("MINGW*"),
        "Should detect Linux, macOS, and Windows Git Bash environments."
    );

    // 3. Universal path resolution
    assert!(
        content.contains("BASH_SOURCE[0]"),
        "Should use BASH_SOURCE[0] for reliable path detection across environments."
    );
    assert!(
        content.contains("_AWS_ASSUME_ROLE_SCRIPT_DIR="),
        "Should determine its own script directory for binary discovery."
    );
    assert!(
        content.contains("binary_path=\"$_AWS_ASSUME_ROLE_SCRIPT_DIR/"),
        "Should construct absolute paths to platform-specific binaries."
    );
    assert!(
        !content.contains("command -v"),
        "Should NOT search system PATH - must use local binaries for reliability."
    );

    // 4. Universal credential handling
    assert!(
        content.contains("if [ \"$1\" = \"assume\" ]"),
        "Should specifically handle the 'assume' command for credential export."
    );
    assert!(
        content.contains("--format export"),
        "Should use --format export for bash-compatible credential output."
    );
    assert!(
        content.contains("eval \"$output\""),
        "Should use eval to apply credentials in the current shell environment."
    );

    // 5. Universal command execution
    assert!(
        content.contains("\"$binary_path\"") && content.contains("\"$@\""),
        "Should execute non-assume commands directly by calling the binary with all arguments."
    );

    // 6. Universal error handling
    assert!(
        content.contains("echo \"awsr: Error:"),
        "Should provide clear error messages for unsupported environments."
    );
    assert!(
        content.contains("return 1"),
        "Should return appropriate exit codes for error conditions."
    );
}

/// Test cross-platform binary naming convention
#[test]
fn test_cross_platform_binary_naming() {
    let script_path = "releases/aws-assume-role-bash.sh";
    let content = fs::read_to_string(script_path)
        .unwrap_or_else(|_| panic!("Should read bash wrapper script from {}", script_path));

    // Verify the dynamic binary naming approach
    assert!(
        content.contains("binary_name=\"aws-assume-role-$os_type\""),
        "Should use dynamic binary naming pattern for cross-platform compatibility."
    );

    // Verify Windows-specific handling
    assert!(
        content.contains("aws-assume-role-windows.exe"),
        "Should handle Windows binary with .exe extension."
    );

    // Verify OS detection logic
    assert!(
        content.contains("Linux*") && content.contains("Darwin*") && content.contains("MINGW*"),
        "Should detect all supported operating systems."
    );

    // Verify binary path construction
    assert!(
        content.contains("binary_path=\"$_AWS_ASSUME_ROLE_SCRIPT_DIR/$binary_name\""),
        "Should construct proper binary paths using script directory."
    );
}

/// Test that the INSTALL.sh script provides the correct manual instructions.
#[test]
fn test_installer_instructions() {
    let script_path = "releases/INSTALL.sh";
    let content = fs::read_to_string(script_path)
        .unwrap_or_else(|_| panic!("Should read INSTALL.sh from {}", script_path));

    // It must instruct the user to source the wrapper script.
    assert!(
        content.contains("source \\\"$install_dir/aws-assume-role-bash.sh\\\""),
        "Installer must output the correct 'source' command for the user."
    );
    assert!(
        content.contains("you MUST add the following line"),
        "Installer must clearly state that manual action is required."
    );
    assert!(
        content.contains("~/.bash_profile") && content.contains("~/.bashrc"),
        "Installer should suggest common profile files."
    );

    // It must NOT modify shell profiles itself.
    assert!(
        !content.contains(">> ~/.bashrc") && !content.contains(">> $HOME/.bash_profile"),
        "Installer must NOT automatically modify user profiles."
    );
}

/// Test that the UNINSTALL.sh script provides the correct manual instructions.
#[test]
fn test_uninstaller_instructions() {
    let script_path = "releases/UNINSTALL.sh";
    let content = fs::read_to_string(script_path)
        .unwrap_or_else(|_| panic!("Should read UNINSTALL.sh from {}", script_path));

    // It must instruct the user to perform manual cleanup steps.
    assert!(
        content.contains("Remove from shell profile"),
        "Uninstaller must instruct user to remove from shell profile."
    );
    assert!(
        content.contains("sed -i"),
        "Uninstaller must provide sed -i commands for shell profile cleanup."
    );
    assert!(
        content.contains("Remove this uninstaller script"),
        "Uninstaller must instruct user to remove the uninstaller script."
    );
    assert!(
        content.contains("rmdir"),
        "Uninstaller must instruct user to remove the installation directory."
    );
    assert!(
        content.contains("unset -f awsr"),
        "Uninstaller must instruct user to clear the awsr shell function."
    );
    assert!(
        content.contains("Reload your shell configuration"),
        "Uninstaller must instruct user to reload their shell configuration."
    );
    // It must NOT modify shell profiles itself automatically (no direct file redirection)
    assert!(
        !content.contains(">> ~/.bashrc") && !content.contains(">> $HOME/.bash_profile"),
        "Uninstaller must NOT automatically modify user profiles."
    );
    // It must remove the correct files (by pattern)
    assert!(
        content.contains("aws-assume-role-*") || content.contains("aws-assume-role-bash.sh"),
        "Uninstaller should target the correct files for removal."
    );
}
