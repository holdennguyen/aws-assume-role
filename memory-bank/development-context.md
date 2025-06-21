# 🛠️ Development Context

Development workflow, patterns, and best practices for AWS Assume Role CLI development.

## 🚀 Development Workflow

### **⚠️ CRITICAL: Post-Change Workflow**

**MANDATORY** after ANY code changes to prevent CI failures:

```bash
# 1. Format code (REQUIRED)
cargo fmt

# 2. Verify formatting (REQUIRED)
cargo fmt --check

# 3. Run clippy with strict warnings (REQUIRED)
cargo clippy -- -D warnings

# 4. Run all tests (REQUIRED)
cargo test

# 5. Commit and push
git add .
git commit -m "Your changes"
git push
```

**Why This Matters:**
- CI has zero tolerance for formatting violations
- Any formatting differences cause immediate build failures
- Pattern observed in multiple CI failure cycles during v1.2.0 development

### **Development Environment Setup**

**Prerequisites:**
```bash
# Install Rust (recommended via rustup)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install required components
rustup component add rustfmt clippy

# Install development tools
cargo install cargo-audit cargo-tarpaulin criterion
```

**Project Setup:**
```bash
# Clone and setup
git clone https://github.com/holdennguyen/aws-assume-role.git
cd aws-assume-role

# Switch to develop branch
git checkout develop
git pull origin develop

# Install dependencies and build
cargo build

# Run tests to verify setup
cargo test

# Run with debug logging
RUST_LOG=debug cargo run -- --help
```

### **Branch Strategy (Git Flow)**

```
Branch Hierarchy:
├── master                 # Production releases only
├── develop               # Integration branch (default)
├── feature/feature-name  # New features
├── release/v1.x.x       # Release preparation
└── hotfix/issue-name    # Critical production fixes
```

**Feature Development Workflow:**
```bash
# Start new feature
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name

# Development cycle
# ... make changes ...
cargo fmt                    # MANDATORY
cargo clippy -- -D warnings # MANDATORY
cargo test                   # MANDATORY

# Commit and push
git add .
git commit -m "feat: implement your feature"
git push -u origin feature/your-feature-name

# Create pull request to develop
```

## 🧪 Testing Framework

### **Test Structure (59 Total Tests)**

```
Testing Architecture:
├── Unit Tests (14 tests)
│   ├── config::tests (10 tests)
│   │   ├── Configuration loading/saving
│   │   ├── Cross-platform path handling
│   │   ├── JSON serialization/deserialization
│   │   └── Environment variable resolution
│   └── error::tests (4 tests)
│       ├── Error type creation and conversion
│       ├── Error chain handling
│       └── Display formatting
├── Integration Tests (23 tests)
│   ├── CLI functionality (8 tests)
│   ├── Error handling (3 tests)
│   └── Configuration workflows (12 tests)
└── Shell Integration Tests (22 tests)
    ├── Bash/Zsh wrapper validation (6 tests)
    ├── PowerShell wrapper validation (6 tests)
    ├── Fish shell wrapper validation (5 tests)
    └── CMD batch wrapper validation (5 tests)
```

### **Running Tests**

```bash
# Complete test suite
cargo test

# Specific test categories
cargo test --lib                        # Unit tests only
cargo test --test integration_tests     # Integration tests
cargo test --test shell_integration_tests # Shell wrapper tests

# Individual test
cargo test test_config_path

# With output
cargo test -- --nocapture

# Performance benchmarks
cargo bench
```

### **Test Environment Setup**

**Cross-Platform Environment Variables:**
```bash
# For integration tests (Unix/Linux/macOS)
export HOME="/tmp/test"

# For integration tests (Windows)
export USERPROFILE="C:\\tmp\\test"

# AWS credentials (for integration tests)
export AWS_ACCESS_KEY_ID="test-key"
export AWS_SECRET_ACCESS_KEY="test-secret"
export AWS_DEFAULT_REGION="us-east-1"
```

## 🔧 Development Patterns

### **Environment Variable Testing (Cross-Platform)**

**Critical Pattern for Windows Compatibility:**
```rust
#[cfg(test)]
mod tests {
    use super::*;
    use serial_test::serial;
    use std::env;

    #[test]
    #[serial]  // REQUIRED: Prevent race conditions with env vars
    fn test_cross_platform_config() {
        // Store original values (REQUIRED for restoration)
        let original_home = env::var("HOME").ok();
        let original_userprofile = env::var("USERPROFILE").ok();
        
        // Set test values for both platforms
        env::set_var("HOME", "/tmp/test");
        env::set_var("USERPROFILE", "C:\\tmp\\test");
        
        // Your test logic here
        let config_path = get_config_path();
        assert!(config_path.to_string_lossy().contains("test"));
        
        // REQUIRED: Restore original values
        match original_home {
            Some(val) => env::set_var("HOME", val),
            None => env::remove_var("HOME"),
        }
        match original_userprofile {
            Some(val) => env::set_var("USERPROFILE", val),
            None => env::remove_var("USERPROFILE"),
        }
    }
}
```

### **Integration Test Pattern**

**CLI Testing with Cross-Platform Support:**
```rust
use assert_cmd::Command;
use predicates::prelude::*;

#[test]
fn test_cli_functionality() {
    let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
    
    // Set cross-platform environment variables
    cmd.env("HOME", "/tmp/test")
       .env("USERPROFILE", "C:\\tmp\\test");
    
    let output = cmd
        .arg("assume")
        .arg("test-role")
        .assert()
        .success();
    
    // Verify output contains expected content
    output.stdout(predicate::str::contains("Assumed role"));
}
```

### **Shell Integration Test Pattern**

**Wrapper Script Validation:**
```rust
#[test]
fn test_bash_wrapper_structure() {
    let wrapper_content = fs::read_to_string("releases/multi-shell/aws-assume-role-bash.sh")
        .expect("Bash wrapper file should exist");
    
    // Verify function definition
    assert!(wrapper_content.contains("awsr() {"));
    
    // Verify error handling
    assert!(wrapper_content.contains("local exit_code=$?"));
    
    // Verify eval logic for assume command
    assert!(wrapper_content.contains("eval \"$output\""));
}
```

## 🔍 Debugging & Troubleshooting

### **Debug Logging**

```bash
# Enable debug logging
RUST_LOG=debug cargo run -- assume my-role

# Trace level logging
RUST_LOG=trace cargo run -- assume my-role

# Module-specific logging
RUST_LOG=aws_assume_role::aws=debug cargo run -- assume my-role
```

### **Common Development Issues**

**1. Test Failures**
```bash
# Environment variable race conditions
# Solution: Use #[serial_test::serial] for env var tests

# Windows compatibility issues
# Solution: Test both HOME and USERPROFILE variables

# Binary path issues in integration tests
# Solution: Use Command::cargo_bin() for reliable binary location
```

**2. CI/CD Failures**
```bash
# Formatting failures (MOST COMMON)
# Solution: Always run `cargo fmt` before committing

# Clippy warnings
# Solution: Fix all warnings, don't ignore them
# Command: cargo clippy -- -D warnings

# Cross-platform test failures
# Solution: Test on multiple platforms, handle environment differences
```

**3. Build Issues**
```bash
# Clean build artifacts
cargo clean

# Update dependencies
cargo update

# Check for outdated dependencies
cargo outdated
```

### **Performance Profiling**

```bash
# Run benchmarks
cargo bench

# Profile with perf (Linux)
cargo build --release
perf record target/release/aws-assume-role assume my-role
perf report

# Memory profiling with valgrind
cargo build --release
valgrind --tool=massif target/release/aws-assume-role assume my-role
```

## 📋 Code Quality Standards

### **Rust Standards**

**Formatting (Enforced by CI):**
```bash
# Check formatting
cargo fmt --check

# Apply formatting
cargo fmt
```

**Linting (Zero Warnings Policy):**
```bash
# Run clippy with strict warnings
cargo clippy -- -D warnings

# Fix common issues
cargo clippy --fix
```

**Testing Requirements:**
- Maintain test coverage above 80%
- Use `#[serial_test::serial]` for environment variable tests
- Test cross-platform compatibility
- Include integration tests for new features

### **Documentation Standards**

```rust
/// Assumes an AWS role and returns temporary credentials
/// 
/// # Arguments
/// 
/// * `role_name` - The name of the role to assume
/// * `duration` - Session duration in seconds (optional)
/// 
/// # Returns
/// 
/// Returns `Ok(Credentials)` on success, or `Err(CliError)` on failure
/// 
/// # Examples
/// 
/// ```
/// let creds = assume_role("production", Some(3600))?;
/// println!("Access Key: {}", creds.access_key_id);
/// ```
pub fn assume_role(role_name: &str, duration: Option<u32>) -> Result<Credentials, CliError> {
    // Implementation
}
```

### **Error Handling Standards**

```rust
// Use thiserror for structured error types
#[derive(Error, Debug)]
pub enum CliError {
    #[error("AWS CLI not found. Please install AWS CLI v2")]
    AwsCliNotFound,
    
    #[error("Failed to assume role '{role}': {source}")]
    AssumeRoleFailed { 
        role: String, 
        #[source] source: Box<dyn std::error::Error> 
    },
}

// Provide actionable error messages
impl From<std::io::Error> for CliError {
    fn from(err: std::io::Error) -> Self {
        match err.kind() {
            std::io::ErrorKind::NotFound => CliError::AwsCliNotFound,
            _ => CliError::IoError { source: err },
        }
    }
}
```

## 🚀 Release Workflow

### **Pre-Release Checklist**

```bash
# 1. Ensure all tests pass
cargo test

# 2. Check formatting
cargo fmt --check

# 3. Run clippy
cargo clippy -- -D warnings

# 4. Security audit
cargo audit

# 5. Build release binaries
./build-releases.sh

# 6. Update version
./scripts/update-version.sh 1.2.1

# 7. Create release notes
# Edit releases/multi-shell/RELEASE_NOTES_v1.2.1.md
```

### **Release Process**

```bash
# Create release branch
git checkout develop
git pull origin develop
git checkout -b release/v1.2.1

# Commit version updates
git add .
git commit -m "release: prepare v1.2.1"
git push origin release/v1.2.1

# Create PR to master
# After approval and merge:

# Tag release
git checkout master
git pull origin master
git tag -a v1.2.1 -m "Release v1.2.1"
git push origin v1.2.1

# Merge back to develop
git checkout develop
git merge master
git push origin develop
```

## 🔧 Troubleshooting Guide

### **CI/CD Pipeline Issues**

**Formatting Failures (Most Common):**
```bash
# Problem: CI fails at "Check formatting" step
# Solution: Run cargo fmt before committing
cargo fmt
git add .
git commit -m "fix: apply formatting"
git push
```

**Clippy Warnings:**
```bash
# Problem: CI fails at "Run clippy" step
# Solution: Fix all warnings
cargo clippy -- -D warnings
# Fix issues manually, then:
git add .
git commit -m "fix: resolve clippy warnings"
git push
```

**Test Failures:**
```bash
# Problem: Tests fail in CI but pass locally
# Common causes:
# 1. Environment variable conflicts
# 2. Platform-specific issues
# 3. Race conditions in tests

# Solutions:
# 1. Use #[serial_test::serial] for env var tests
# 2. Test on multiple platforms
# 3. Ensure proper test isolation
```

### **Development Environment Issues**

**AWS CLI Integration:**
```bash
# Problem: Integration tests fail with "AWS CLI not found"
# Solution: Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
```

**Cross-Platform Development:**
```bash
# Problem: Tests fail on Windows but pass on Unix
# Solution: Ensure both HOME and USERPROFILE are handled

# In tests:
cmd.env("HOME", "/tmp/test")
   .env("USERPROFILE", "C:\\tmp\\test");

# In production code:
if let Ok(home) = env::var("HOME") {
    return PathBuf::from(home).join(".aws-assume-role");
}
if let Ok(userprofile) = env::var("USERPROFILE") {
    return PathBuf::from(userprofile).join(".aws-assume-role");
}
```

## 📚 Best Practices Summary

### **Development Best Practices**

1. **Always Format Code**: Run `cargo fmt` after every change
2. **Fix All Warnings**: Zero tolerance for clippy warnings
3. **Test Cross-Platform**: Consider Windows, macOS, and Linux differences
4. **Use Serial Tests**: For environment variable modifications
5. **Document Changes**: Update relevant documentation
6. **Commit Frequently**: Small, focused commits with clear messages

### **Testing Best Practices**

1. **Test Isolation**: Use temporary directories and environment restoration
2. **Cross-Platform**: Test environment variable handling for all platforms
3. **Integration Tests**: Test real binary execution, not just library code
4. **Error Scenarios**: Test failure cases and error messages
5. **Shell Wrappers**: Validate wrapper script content and behavior

### **Release Best Practices**

1. **Version Consistency**: Update all version references
2. **Release Notes**: Document all changes and breaking changes
3. **Binary Testing**: Verify all platform binaries work correctly
4. **Automated Publishing**: Let CI/CD handle package manager updates
5. **Post-Release Verification**: Confirm packages are available

This development context provides comprehensive guidance for contributing to and maintaining AWS Assume Role CLI while ensuring high quality and reliability. 