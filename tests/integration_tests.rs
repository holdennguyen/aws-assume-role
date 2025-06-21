use assert_cmd::Command;
use predicates::prelude::*;
use tempfile::TempDir;

/// Integration tests for AWS Assume Role CLI
///
/// These tests verify the end-to-end functionality of the CLI application
/// without requiring actual AWS credentials or network access.

#[cfg(test)]
mod integration {
    use super::*;

    /// Test basic CLI help output
    #[test]
    fn test_cli_help() {
        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.arg("--help")
            .assert()
            .success()
            .stdout(predicate::str::contains("AWS Assume Role CLI (awsr)"));
    }

    /// Test CLI version output
    #[test]
    fn test_cli_version() {
        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.arg("--version")
            .assert()
            .success()
            .stdout(predicate::str::contains("aws-assume-role"));
    }

    /// Test configure command help
    #[test]
    fn test_configure_help() {
        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.args(&["configure", "--help"])
            .assert()
            .success()
            .stdout(predicate::str::contains("Configure a new AWS IAM role"));
    }

    /// Test assume command help
    #[test]
    fn test_assume_help() {
        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.args(&["assume", "--help"])
            .assert()
            .success()
            .stdout(predicate::str::contains("Assume a configured role"));
    }

    /// Test list command help
    #[test]
    fn test_list_help() {
        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.args(&["list", "--help"])
            .assert()
            .success()
            .stdout(predicate::str::contains(
                "List all configured AWS IAM roles",
            ));
    }

    /// Test verify command help
    #[test]
    fn test_verify_help() {
        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.args(&["verify", "--help"])
            .assert()
            .success()
            .stdout(predicate::str::contains(
                "Verify that all prerequisites are met",
            ));
    }

    /// Test remove command help
    #[test]
    fn test_remove_help() {
        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.args(&["remove", "--help"])
            .assert()
            .success()
            .stdout(predicate::str::contains("Remove a configured AWS IAM role"));
    }

    /// Test configure command with missing arguments
    #[test]
    fn test_configure_missing_args() {
        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.args(&["configure"])
            .assert()
            .failure()
            .stderr(predicate::str::contains("required"));
    }

    /// Test assume command with non-existent role
    #[test]
    fn test_assume_nonexistent_role() {
        let temp_dir = TempDir::new().unwrap();
        let _config_path = temp_dir.path().join(".aws-assume-role");

        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.env("HOME", temp_dir.path())
            .args(&["assume", "nonexistent-role"])
            .assert()
            .failure();
    }

    /// Test list command with no configured roles
    #[test]
    fn test_list_empty() {
        let temp_dir = TempDir::new().unwrap();

        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.env("HOME", temp_dir.path())
            .arg("list")
            .assert()
            .success()
            .stdout(predicate::str::contains("No roles configured"));
    }

    /// Test invalid command
    #[test]
    fn test_invalid_command() {
        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.arg("invalid-command")
            .assert()
            .failure()
            .stderr(predicate::str::contains("unrecognized subcommand"));
    }
}

#[cfg(test)]
mod config_integration {
    use super::*;
    use std::fs;

    /// Test configuration workflow end-to-end
    #[test]
    fn test_config_workflow() {
        let temp_dir = TempDir::new().unwrap();
        let config_dir = temp_dir.path().join(".aws-assume-role");
        fs::create_dir_all(&config_dir).unwrap();

        // Test configure command
        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.env("HOME", temp_dir.path())
            .args(&[
                "configure",
                "--name",
                "test-role",
                "--role-arn",
                "arn:aws:iam::123456789012:role/TestRole",
                "--account-id",
                "123456789012",
            ])
            .assert()
            .success();

        // Test list command shows the configured role
        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.env("HOME", temp_dir.path())
            .arg("list")
            .assert()
            .success()
            .stdout(predicate::str::contains("test-role"));

        // Test remove command
        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.env("HOME", temp_dir.path())
            .args(&["remove", "test-role"])
            .assert()
            .success();

        // Test list command shows no roles after removal
        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.env("HOME", temp_dir.path())
            .arg("list")
            .assert()
            .success()
            .stdout(predicate::str::contains("No roles configured"));
    }
}

#[cfg(test)]
mod error_handling {
    use super::*;

    /// Test error handling for invalid role ARN (graceful degradation)
    #[test]
    fn test_invalid_role_arn() {
        let temp_dir = TempDir::new().unwrap();

        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.env("HOME", temp_dir.path())
            .args(&[
                "configure",
                "--name",
                "invalid-role",
                "--role-arn",
                "invalid-arn",
                "--account-id",
                "123456789012",
            ])
            .assert()
            .success()
            .stdout(predicate::str::contains("could not verify"));
    }

    /// Test error handling for invalid account ID (graceful degradation)
    #[test]
    fn test_invalid_account_id() {
        let temp_dir = TempDir::new().unwrap();

        let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
        cmd.env("HOME", temp_dir.path())
            .args(&[
                "configure",
                "--name",
                "test-role",
                "--role-arn",
                "arn:aws:iam::123456789012:role/TestRole",
                "--account-id",
                "invalid-id",
            ])
            .assert()
            .success()
            .stdout(predicate::str::contains("could not verify"));
    }
}
