use std::fs;
use std::path::Path;

mod common;

/// Test that the universal bash wrapper exists and covers all platforms
#[test]
fn test_shell_wrappers_exist() {
    let essential_files = [
        "releases/aws-assume-role-bash.sh", // Universal wrapper for all platforms
        "releases/INSTALL.sh",              // Universal installer
        "releases/UNINSTALL.sh",            // Universal uninstaller
        "releases/README.md",               // Documentation
    ];

    for file in &essential_files {
        assert!(
            Path::new(file).exists(),
            "Essential file {} should exist",
            file
        );
    }
}

/// Test universal bash wrapper script structure and cross-platform functionality
#[test]
fn test_bash_wrapper_structure() {
    let script_path = "releases/aws-assume-role-bash.sh";
    let content = fs::read_to_string(script_path)
        .unwrap_or_else(|_| panic!("Should read bash wrapper script"));

    // Check shebang
    assert!(
        content.starts_with("#!/bin/bash"),
        "Should have bash shebang"
    );

    // Check key functionality
    assert!(
        content.contains("aws_assume_role"),
        "Should define aws_assume_role function"
    );
    assert!(
        content.contains("eval"),
        "Should use eval for credential setting"
    );
    assert!(
        content.contains("--format export"),
        "Should use export format"
    );

    // Check platform detection
    assert!(content.contains("Linux*"), "Should detect Linux platform");
    assert!(content.contains("Darwin*"), "Should detect macOS platform");
    assert!(
        content.contains("MINGW*") || content.contains("MSYS*") || content.contains("CYGWIN*"),
        "Should detect Windows Git Bash platform"
    );

    // Check error handling
    assert!(
        content.contains("case") && content.contains("return 1"),
        "Should have platform detection and error handling"
    );

    // Check convenience alias
    assert!(content.contains("alias awsr"), "Should provide awsr alias");
}

/// Test cross-platform binary discovery logic
#[test]
fn test_binary_discovery() {
    let script_path = "releases/aws-assume-role-bash.sh";
    let content = fs::read_to_string(script_path)
        .unwrap_or_else(|_| panic!("Should read universal wrapper script"));

    // Should have logic to find platform-specific binaries
    assert!(
        content.contains("aws-assume-role-linux"),
        "Should reference Linux binary"
    );
    assert!(
        content.contains("aws-assume-role-macos"),
        "Should reference macOS binary"
    );
    assert!(
        content.contains("aws-assume-role-windows.exe"),
        "Should reference Windows binary"
    );

    // Should have fallback to installed binary
    assert!(
        content.contains("command -v aws-assume-role"),
        "Should have fallback to installed binary"
    );

    // Should check for file existence
    assert!(
        content.contains("[ -f"),
        "Should check for binary file existence"
    );
}

/// Test error handling patterns in universal wrapper
#[test]
fn test_wrapper_error_handling() {
    let script_path = "releases/aws-assume-role-bash.sh";
    let content = fs::read_to_string(script_path)
        .unwrap_or_else(|_| panic!("Should read universal wrapper script"));

    // Should have comprehensive error handling
    assert!(
        content.contains("Unsupported operating system"),
        "Should handle unsupported OS"
    );
    assert!(
        content.contains("binary not found"),
        "Should handle missing binary"
    );
    assert!(content.contains("return 1"), "Should return error codes");
    assert!(
        content.contains("if [ -z"),
        "Should check for empty variables"
    );
}

/// Test usage information in universal wrapper
#[test]
fn test_wrapper_usage_info() {
    let script_path = "releases/aws-assume-role-bash.sh";
    let content = fs::read_to_string(script_path)
        .unwrap_or_else(|_| panic!("Should read universal wrapper script"));

    // Should provide usage information
    assert!(
        content.contains("Usage:") || content.contains("awsr assume"),
        "Should provide usage information"
    );
    assert!(
        content.contains("assume") && content.contains("list") && content.contains("configure"),
        "Should document main commands"
    );
    assert!(
        content.contains("AWS Assume Role loaded"),
        "Should confirm successful loading"
    );
}

/// Test that universal wrapper supports export format for environment variables
#[test]
fn test_export_format_integration() {
    let script_path = "releases/aws-assume-role-bash.sh";
    let content =
        fs::read_to_string(script_path).unwrap_or_else(|_| panic!("Should read shell script"));

    // Universal wrapper should use eval with --format export
    assert!(
        content.contains("eval $($binary_path assume") && content.contains("--format export"),
        "Should use eval with --format export for environment variable setting"
    );

    // Should have role assumption logic
    assert!(
        content.contains("assume") && content.contains("Role assumed successfully"),
        "Should handle role assumption with success feedback"
    );
}

/// Test executable permissions on Unix systems
/// Test that Unix executable files have proper permissions (Unix only)
#[test]
#[cfg(unix)]
fn test_unix_executable_permissions() {
    use std::os::unix::fs::PermissionsExt;

    let executables = [
        "releases/aws-assume-role-bash.sh",
        "releases/INSTALL.sh",
        "releases/UNINSTALL.sh",
        "releases/aws-assume-role-linux",
        "releases/aws-assume-role-macos",
    ];

    for executable in &executables {
        if Path::new(executable).exists() {
            let metadata = fs::metadata(executable)
                .unwrap_or_else(|_| panic!("Should read metadata for {}", executable));
            let permissions = metadata.permissions();
            let mode = permissions.mode();

            assert!(
                mode & 0o111 != 0,
                "{} should be executable (has mode {:o})",
                executable,
                mode
            );
        }
    }
}

/// Test that files exist on Windows (Windows only)
#[test]
#[cfg(windows)]
fn test_windows_file_existence() {
    let files = [
        "releases/aws-assume-role-bash.sh",
        "releases/INSTALL.sh",
        "releases/UNINSTALL.sh",
        "releases/aws-assume-role-windows.exe",
    ];

    for file in &files {
        if Path::new(file).exists() {
            let metadata =
                fs::metadata(file).unwrap_or_else(|_| panic!("Should read metadata for {}", file));

            // On Windows, just check that files exist and are not empty
            assert!(metadata.len() > 0, "{} should not be empty", file);
        }
    }
}

/// Test installation and uninstallation scripts exist and have proper structure
#[test]
fn test_installation_scripts() {
    let scripts = [
        ("releases/INSTALL.sh", "installation"),
        ("releases/UNINSTALL.sh", "uninstallation"),
    ];

    for (script_path, script_type) in &scripts {
        assert!(
            Path::new(script_path).exists(),
            "{} script should exist",
            script_type
        );

        let content = fs::read_to_string(script_path)
            .unwrap_or_else(|_| panic!("Should read {} script {}", script_type, script_path));

        // Check shebang
        assert!(
            content.starts_with("#!/bin/bash"),
            "{} script should have bash shebang",
            script_type
        );

        // Check for key functionality
        assert!(
            content.contains("aws-assume-role"),
            "{} script should reference aws-assume-role",
            script_type
        );
    }
}

/// Test uninstallation scripts
#[test]
fn test_uninstallation_scripts() {
    let script_path = "releases/UNINSTALL.sh";
    assert!(
        Path::new(script_path).exists(),
        "Uninstallation script should exist"
    );

    let content = fs::read_to_string(script_path)
        .unwrap_or_else(|_| panic!("Should read uninstallation script {}", script_path));

    // Should have removal logic
    assert!(
        content.contains("rm") || content.contains("remove"),
        "Should have file removal logic"
    );

    // Should have path cleanup
    assert!(
        content.contains("PATH") || content.contains("bin"),
        "Should handle PATH cleanup"
    );
}

/// Test README mentions universal approach and supported platforms
#[test]
fn test_multishell_readme() {
    let readme_path = "releases/README.md";
    let content = fs::read_to_string(readme_path).unwrap_or_else(|_| panic!("Should read README"));

    // Should mention supported platforms
    assert!(
        content.contains("Linux") && content.contains("macOS") && content.contains("Windows"),
        "README should mention all supported platforms"
    );

    // Should mention the universal wrapper approach
    assert!(
        content.contains("bash")
            || content.contains("universal")
            || content.contains("cross-platform"),
        "README should mention universal/cross-platform approach"
    );

    // Should mention Git Bash for Windows
    assert!(
        content.contains("Git Bash") || content.contains("MSYS") || content.contains("bash"),
        "README should mention Windows bash compatibility"
    );
}

/// Test version consistency across files
#[test]
fn test_version_consistency() {
    // Read version from Cargo.toml
    let cargo_content = fs::read_to_string("Cargo.toml").expect("Should read Cargo.toml");

    let version_line = cargo_content
        .lines()
        .find(|line| line.trim().starts_with("version = "))
        .expect("Should find version in Cargo.toml");

    let version = version_line
        .split('=')
        .nth(1)
        .expect("Should extract version")
        .trim()
        .trim_matches('"');

    // Check README mentions the version
    let readme_content = fs::read_to_string("releases/README.md").expect("Should read README");

    assert!(
        readme_content.contains(version),
        "README should mention version {}",
        version
    );
}

/// Test that distribution creation is handled by automation scripts
#[test]
fn test_distribution_script() {
    // The automation approach uses scripts/release.sh for distribution
    let script_path = "scripts/release.sh";
    assert!(
        Path::new(script_path).exists(),
        "Release automation script should exist"
    );

    let content = fs::read_to_string(script_path)
        .unwrap_or_else(|_| panic!("Should read release automation script"));

    // Should have package creation functionality
    assert!(
        content.contains("package") || content.contains("distribution"),
        "Should have packaging functionality"
    );

    // Should handle multiple platforms
    assert!(
        content.contains("tar.gz") && content.contains("zip"),
        "Should create both tar.gz and zip distributions"
    );
}

/// Test that all required binary files exist
#[test]
fn test_binary_files_exist() {
    let binaries = [
        "releases/aws-assume-role-linux",
        "releases/aws-assume-role-macos",
        "releases/aws-assume-role-windows.exe",
    ];

    for binary in &binaries {
        assert!(Path::new(binary).exists(), "Binary {} should exist", binary);
    }

    // Check that binaries are not empty
    for binary in &binaries {
        let metadata =
            fs::metadata(binary).unwrap_or_else(|_| panic!("Should read metadata for {}", binary));
        assert!(metadata.len() > 0, "Binary {} should not be empty", binary);
    }
}

/// Test release notes exist (managed by automation)
#[test]
fn test_release_notes() {
    // Release notes are now managed in the release-notes/ directory by automation
    let release_notes_dir = "release-notes";
    assert!(
        Path::new(release_notes_dir).exists(),
        "Release notes directory should exist"
    );

    // Should have at least one release notes file
    let entries = fs::read_dir(release_notes_dir)
        .expect("Should read release notes directory")
        .filter_map(|entry| entry.ok())
        .filter(|entry| {
            entry
                .file_name()
                .to_string_lossy()
                .starts_with("RELEASE_NOTES_v")
                && entry.file_name().to_string_lossy().ends_with(".md")
        })
        .count();

    assert!(
        entries > 0,
        "Should find at least one release notes file in release-notes/ directory"
    );
}
