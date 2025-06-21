# 🛠️ Development Guide

Complete guide for developing, testing, and contributing to AWS Assume Role CLI.

## 🚀 Quick Start

### Prerequisites
- **Rust** 1.70+ (`rustup` recommended)
- **AWS CLI** v2 (for integration testing)
- **Git** (for version control)

### Setup
```bash
# Clone and setup
git clone https://github.com/holdennguyen/aws-assume-role.git
cd aws-assume-role

# Install dependencies and build
cargo build

# Run tests
cargo test

# Run with debug logging
RUST_LOG=debug cargo run -- --help
```

## 📁 Project Structure

```
aws-assume-role/
├── src/                          # Source code
│   ├── main.rs                  # CLI entry point
│   ├── lib.rs                   # Library interface
│   ├── cli/mod.rs               # Command-line interface
│   ├── aws/mod.rs               # AWS integration
│   ├── config/mod.rs            # Configuration management
│   └── error/mod.rs             # Error handling
├── tests/                        # Test suite
│   ├── integration_tests.rs     # Integration tests (23 tests)
│   ├── shell_integration_tests.rs # Shell wrapper tests (22 tests)
│   └── common/mod.rs            # Test utilities
├── benches/                      # Performance benchmarks
├── packaging/                    # Distribution packages
├── releases/multi-shell/         # Release binaries
├── scripts/                      # Automation scripts
└── memory-bank/                  # Development documentation
```

## 🧪 Testing Framework

### Test Categories (59 Total Tests)

**Unit Tests (14 tests)**
- Configuration management
- Error handling
- AWS integration logic
- CLI argument parsing

**Integration Tests (23 tests)**
- End-to-end CLI functionality
- AWS credential handling
- Configuration file operations
- Cross-platform compatibility

**Shell Integration Tests (22 tests)**
- Bash/Zsh wrapper scripts
- PowerShell wrapper scripts
- Fish shell wrapper scripts
- Command Prompt batch files

### Running Tests

```bash
# All tests
cargo test

# Specific test categories
cargo test --test integration_tests
cargo test --test shell_integration_tests

# Unit tests only
cargo test --lib

# With output
cargo test -- --nocapture

# Specific test
cargo test test_assume_role_success

# Performance tests
cargo bench
```

### Test Environment Setup

**Required Environment Variables for Testing:**
```bash
# AWS credentials (for integration tests)
export AWS_ACCESS_KEY_ID="test-key"
export AWS_SECRET_ACCESS_KEY="test-secret"
export AWS_DEFAULT_REGION="us-east-1"

# Optional: Custom AWS profile
export AWS_PROFILE="test-profile"
```

**Cross-Platform Environment Variables:**
- **Unix/Linux/macOS**: `HOME` for user directory
- **Windows**: `USERPROFILE` for user directory

## 🔧 Development Workflow

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
- Pattern observed in multiple CI failure cycles

### Development Patterns

**Environment Variable Testing (Cross-Platform):**
```rust
#[cfg(test)]
mod tests {
    use super::*;
    use serial_test::serial;
    use std::env;

    #[test]
    #[serial]  // Prevent race conditions with env vars
    fn test_cross_platform_config() {
        // Store original values
        let original_home = env::var("HOME").ok();
        let original_userprofile = env::var("USERPROFILE").ok();
        
        // Set test values
        env::set_var("HOME", "/tmp/test");
        env::set_var("USERPROFILE", "C:\\tmp\\test");
        
        // Your test logic here
        
        // Restore original values
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

**Integration Test Pattern:**
```rust
#[test]
fn test_cli_functionality() {
    let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
    
    // Set cross-platform environment
    cmd.env("HOME", "/tmp/test")
       .env("USERPROFILE", "C:\\tmp\\test");
    
    let output = cmd
        .arg("assume")
        .arg("test-role")
        .assert()
        .success();
    
    // Verify output
    output.stdout(predicate::str::contains("Assumed role"));
}
```

### Code Quality Standards

**Rust Standards:**
- Follow `rustfmt` formatting (enforced by CI)
- Pass `clippy` with `-D warnings` (enforced by CI)
- Maintain test coverage above 80%
- Use `#[serial_test::serial]` for environment variable tests

**Error Handling:**
- Use `thiserror` for structured error types
- Provide actionable error messages
- Include context for debugging

**Documentation:**
- Document all public APIs
- Include usage examples
- Maintain up-to-date README

## 🏗️ Architecture

### Core Components

**CLI Layer (`src/cli/mod.rs`)**
- Command parsing and validation
- User interaction and output formatting
- Shell integration coordination

**AWS Layer (`src/aws/mod.rs`)**
- STS AssumeRole operations
- Credential management
- AWS CLI integration

**Configuration Layer (`src/config/mod.rs`)**
- Cross-platform config file handling
- User preference management
- Default value resolution

**Error Layer (`src/error/mod.rs`)**
- Structured error types
- User-friendly error messages
- Debug information preservation

### Key Design Patterns

**Cross-Platform Compatibility:**
```rust
pub fn get_config_path() -> PathBuf {
    // Production: Use both environment variables for cross-platform support
    if let Ok(home) = env::var("HOME") {
        return PathBuf::from(home).join(".aws-assume-role");
    }
    if let Ok(userprofile) = env::var("USERPROFILE") {
        return PathBuf::from(userprofile).join(".aws-assume-role");
    }
    
    // Fallback to dirs crate
    dirs::home_dir()
        .unwrap_or_else(|| PathBuf::from("."))
        .join(".aws-assume-role")
}
```

**Error Propagation:**
```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum CliError {
    #[error("AWS CLI not found. Please install AWS CLI v2")]
    AwsCliNotFound,
    
    #[error("Failed to assume role '{role}': {source}")]
    AssumeRoleFailed { role: String, source: Box<dyn std::error::Error> },
    
    #[error("Configuration error: {0}")]
    ConfigError(String),
}
```

## 🔍 Debugging

### Debug Logging
```bash
# Enable debug logging
RUST_LOG=debug cargo run -- assume my-role

# Trace level logging
RUST_LOG=trace cargo run -- assume my-role

# Module-specific logging
RUST_LOG=aws_assume_role::aws=debug cargo run -- assume my-role
```

### Common Issues

**Test Failures:**
- **Environment Variables**: Use `#[serial_test::serial]` for env var tests
- **Windows Compatibility**: Test both `HOME` and `USERPROFILE` variables
- **Race Conditions**: Avoid parallel env var modifications

**CI/CD Failures:**
- **Formatting**: Always run `cargo fmt` before committing
- **Clippy Warnings**: Fix all warnings, don't ignore them
- **Cross-Platform**: Test on multiple platforms

**Integration Test Issues:**
- **AWS Credentials**: Ensure test credentials are configured
- **Binary Path**: Use `Command::cargo_bin()` for reliable binary location
- **Shell Wrappers**: Verify wrapper script content matches expectations

### Performance Profiling

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

## 📦 Release Process

### Version Management

```bash
# Update version in Cargo.toml
./scripts/update-version.sh 1.2.1

# This updates:
# - Cargo.toml version
# - Documentation references
# - Package configurations
```

### Build Release Binaries

```bash
# Build all platform binaries
./build-releases.sh

# Builds:
# - macOS universal binary
# - Linux x86_64 binary  
# - Windows x86_64 binary
# - Shell wrapper scripts
```

### Release Checklist

**Pre-Release:**
- [ ] All tests passing (`cargo test`)
- [ ] Code formatted (`cargo fmt --check`)
- [ ] No clippy warnings (`cargo clippy -- -D warnings`)
- [ ] Version updated in all files
- [ ] Release notes created
- [ ] Binaries built and tested

**Release:**
- [ ] Git tag created (`git tag v1.2.1`)
- [ ] GitHub release published
- [ ] Binaries uploaded to release
- [ ] Package managers updated automatically

**Post-Release:**
- [ ] Monitor CI/CD pipeline
- [ ] Verify package manager updates
- [ ] Update documentation if needed

## 🤝 Contributing

### Getting Started
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the development workflow above
4. Submit a pull request

### Pull Request Requirements
- [ ] All tests pass
- [ ] Code is formatted (`cargo fmt`)
- [ ] No clippy warnings
- [ ] Documentation updated if needed
- [ ] Descriptive commit messages

### Code Review Process
1. Automated CI checks must pass
2. Manual code review by maintainer
3. Integration testing on multiple platforms
4. Merge to develop branch
5. Release when ready

## 🔧 Troubleshooting Development Issues

### Cargo Issues
```bash
# Clean build artifacts
cargo clean

# Update dependencies
cargo update

# Check for outdated dependencies
cargo outdated
```

### Test Environment Issues
```bash
# Reset test environment
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
rm -rf ~/.aws-assume-role

# Verify AWS CLI
aws --version
aws sts get-caller-identity
```

### CI/CD Pipeline Debugging
```bash
# Simulate CI formatting check
cargo fmt --check

# Simulate CI clippy check
cargo clippy -- -D warnings

# Simulate CI test run
cargo test --verbose
```

## 📚 Resources

### Rust Development
- [Rust Book](https://doc.rust-lang.org/book/)
- [Cargo Book](https://doc.rust-lang.org/cargo/)
- [Clippy Lints](https://rust-lang.github.io/rust-clippy/master/)

### AWS Development
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [AWS STS API Reference](https://docs.aws.amazon.com/STS/latest/APIReference/)
- [AWS SDK for Rust](https://github.com/awslabs/aws-sdk-rust)

### Testing
- [Rust Testing Guide](https://doc.rust-lang.org/book/ch11-00-testing.html)
- [Assert Command](https://docs.rs/assert_cmd/)
- [Serial Test](https://docs.rs/serial_test/) 