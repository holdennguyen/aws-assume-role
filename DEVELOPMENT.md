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

## ⚡ Development Lifecycle Overview

```bash
# Complete Development Flow
1. Planning:    Consolidate issues → Plan version → Create milestones
2. Feature:     Branch → Develop → Test → PR → Review → Merge
3. Integration: Develop branch → CI testing → Cross-platform validation  
4. Release:     Stabilize → Version bump → Release branch → Publish
```

## 📋 Phase 1: Version Planning & Issue Consolidation

### Issue & Feature Consolidation

```bash
# 1. Review and consolidate issues
# - Check GitHub Issues for bug reports
# - Review feature requests and discussions
# - Analyze community feedback and usage patterns
# - Identify breaking changes vs backward-compatible improvements

# 2. Version planning
# - Patch (1.2.x): Bug fixes, security updates, documentation
# - Minor (1.x.0): New features, enhancements, backward compatible
# - Major (x.0.0): Breaking changes, major architectural changes
```

### Project Planning Workflow

**Create Version Milestone:**
1. Go to GitHub Issues → Milestones
2. Create milestone: `v1.3.0 - Enhanced Role Management`
3. Set due date and description
4. Assign relevant issues to milestone

**Issue Categorization:**
```
🐛 Bug Fixes (Patch)
├── Windows compatibility issues
├── Configuration parsing errors
└── Shell integration failures

✨ Features (Minor)  
├── Multi-factor authentication support
├── Enhanced SSO integration
└── Configuration validation

💥 Breaking Changes (Major)
├── API restructuring
├── Configuration format changes
└── Dependency major updates
```

### Branch Strategy & Workflow

```
Git Flow Strategy:
master ──────●────────●────────●── Production releases
          v1.2.0   v1.2.1   v1.3.0

develop ─────●─────●─────●─────●──── Integration branch
            /     /     /     /
feature/auth ────●                    Feature branches
feature/sso ──────────●
feature/config ─────────────●

release/v1.3.0 ──────────────●─●──── Release preparation
                               └──── Hotfix branches
hotfix/critical-bug ──────────────●
```

## 🚀 Phase 2: Feature Development Workflow

### Starting New Version Development

```bash
# 1. Ensure clean develop branch
git checkout develop
git pull origin develop

# 2. Verify development environment
cargo test                         # All tests should pass
cargo fmt --check                  # No formatting issues
cargo clippy -- -D warnings        # No clippy warnings

# 3. Create feature branch
git checkout -b feature/multi-factor-auth

# 4. Set up development environment for the feature
# - Review requirements and acceptance criteria
# - Plan implementation approach
# - Identify test scenarios
```

### Feature Development Cycle

**Daily Development Workflow:**
```bash
# 1. Start of day - sync with develop
git checkout develop
git pull origin develop
git checkout feature/your-feature
git rebase develop                  # Keep feature branch up to date

# 2. Development cycle
# - Implement features incrementally
# - Write tests alongside implementation
# - Keep commits small and focused

# 3. Quality gates (run frequently)
cargo fmt                          # Format code
cargo clippy -- -D warnings        # Check for issues  
cargo test                         # Run all tests
cargo test --test integration_tests # Integration tests
./build-releases.sh                # Verify cross-platform builds

# 4. Commit with conventional commits
git add .
git commit -m "feat(auth): add MFA token validation"
git push origin feature/your-feature
```

### Multi-Branch Testing Strategy

**Branch-Specific Testing:**
```bash
# Feature branch testing
cargo test --lib                   # Unit tests for your changes
cargo test --test integration_tests # Integration tests  
cargo test test_your_specific_feature # Focused testing

# Cross-platform validation (before PR)
./build-releases.sh
# Test binaries on different platforms
./releases/multi-shell/aws-assume-role-macos --version
./releases/multi-shell/aws-assume-role-unix --version  
./releases/multi-shell/aws-assume-role.exe --version
```

**CI Testing Per Branch:**
- **Feature branches**: Unit tests, integration tests, cross-platform builds
- **Develop branch**: Full test suite, cross-platform validation, security audit
- **Release branches**: Comprehensive testing, performance benchmarks, package builds
- **Master branch**: Production deployment validation, release verification

### Pull Request Workflow

```bash
# 1. Prepare for pull request
git checkout feature/your-feature
git rebase develop                  # Ensure clean history
cargo test                         # Final test run
cargo fmt                          # Final formatting
cargo clippy -- -D warnings        # Final clippy check

# 2. Create pull request
# - Target: develop branch
# - Title: "feat(auth): Add multi-factor authentication support"
# - Description: Link to issues, describe changes, testing done
# - Checklist: [ ] Tests pass [ ] Documentation updated [ ] No breaking changes

# 3. Address review feedback
# - Make requested changes
# - Update tests if needed
# - Re-run quality checks
```

## 🔄 Phase 3: Integration & Continuous Testing

### Develop Branch Management

**Integration Testing:**
```bash
# When feature PRs are merged to develop
git checkout develop
git pull origin develop

# Run comprehensive test suite
cargo test                         # All 59 tests
cargo audit                        # Security vulnerabilities
cargo bench                        # Performance regression check
./build-releases.sh                # Cross-platform builds

# Monitor CI pipeline for:
# - Ubuntu, Windows, macOS builds
# - All test categories passing
# - Package manager compatibility
# - Shell integration tests
```

**Managing Multiple Features:**
```bash
# Working with multiple concurrent features
git checkout develop

# Check which features are in progress
git branch -r | grep feature/

# Common integration scenarios:
# 1. Feature A depends on Feature B
feature/auth-base → develop
feature/mfa-support (depends on auth-base) → rebase on develop

# 2. Conflicting features  
feature/config-v2 conflicts with feature/legacy-support
# Resolve: Coordinate development, resolve conflicts on develop

# 3. Large features
feature/major-refactor → break into smaller sub-features
feature/refactor-config, feature/refactor-aws, etc.
```

### Continuous Integration Validation

**Per-Commit Testing (All Branches):**
```yaml
# GitHub Actions validates on every push:
- Code formatting (cargo fmt --check)
- Clippy warnings (cargo clippy -- -D warnings)  
- Unit tests (cargo test --lib)
- Integration tests (cargo test --test integration_tests)
- Shell integration tests (cargo test --test shell_integration_tests)
- Cross-platform builds (Ubuntu, Windows, macOS)
```

**Develop Branch Additional Testing:**
```yaml
# Additional validations on develop:
- Security audit (cargo audit)
- Performance benchmarks (cargo bench)
- Package builds (Homebrew, APT, RPM, Docker)
- Installation script testing
- Documentation link validation
```

## 🎯 Phase 4: Pre-Release Stabilization

### Release Branch Creation

```bash
# When develop is stable and ready for release
git checkout develop
git pull origin develop

# Final validation before release branch
cargo test                         # All tests pass
cargo audit                        # No security issues
cargo bench                        # Performance acceptable
./build-releases.sh                # All platforms build

# Create release branch
git checkout -b release/v1.3.0
git push origin release/v1.3.0
```

### Release Branch Workflow

**Stabilization Process:**
```bash
# Only bug fixes and release preparations on release branch
git checkout release/v1.3.0

# Update version and create release notes
./scripts/update-version.sh 1.3.0
./scripts/create-release-notes.sh 1.3.0

# Edit release notes with comprehensive changes
# Update documentation for new features
# Final testing and validation

git add .
git commit -m "🔖 Bump version to v1.3.0"
git push origin release/v1.3.0
```

**Release Branch Testing:**
```bash
# Comprehensive release validation
cargo test                         # All 59 tests
cargo fmt --check                  # Clean formatting
cargo clippy -- -D warnings        # No warnings
cargo audit                        # Security clean
cargo bench                        # Performance check

# Cross-platform validation  
./build-releases.sh
# Test on multiple platforms
# Validate installation scripts
# Test package manager builds

# Final release candidate testing
# - Manual testing of critical workflows
# - Regression testing of existing features
# - Performance validation
# - Documentation review
```

## 🎯 Phase 5: Release & Post-Release

### Release Process

```bash
# Final release from release branch
git checkout release/v1.3.0

# Create tag and trigger release
git tag -a v1.3.0 -m "Release v1.3.0"
git push origin master
git push origin v1.3.0

# GitHub Actions automatically:
# 1. Validates version consistency
# 2. Builds cross-platform binaries
# 3. Publishes to package managers
# 4. Creates GitHub release
# 5. Updates Docker images
```

### Post-Release Workflow

```bash
# After successful release, update branches
git checkout master
git pull origin master

# Merge release changes back to develop
git checkout develop
git merge master
git push origin develop

# Clean up release branch (optional)
git branch -d release/v1.3.0
git push origin --delete release/v1.3.0

# Update milestone and issues
# - Close completed milestone
# - Move remaining issues to next milestone
# - Create next version planning
```

### Hotfix Workflow (Emergency)

```bash
# Critical bug in production
git checkout master
git pull origin master
git checkout -b hotfix/critical-security-fix

# Make minimal fix
# Test thoroughly
git add .
git commit -m "fix: resolve critical security vulnerability"

# Fast-track release
./scripts/update-version.sh 1.3.1
git add .
git commit -m "🔖 Bump version to v1.3.1"

# Release and merge back
git checkout master
git merge hotfix/critical-security-fix
git tag -a v1.3.1 -m "Hotfix v1.3.1"
git push origin master
git push origin v1.3.1

# Merge to develop
git checkout develop
git merge master
git push origin develop
```

## 🧪 Testing Strategy per Development Phase

### Phase 1: Planning Testing
```bash
# Establish testing requirements for upcoming version
# - Identify new test scenarios needed
# - Plan test coverage for new features
# - Review existing test gaps
# - Set up test environments
```

### Phase 2: Feature Development Testing
```bash
# Test-Driven Development approach
# 1. Write failing tests first
cargo test test_new_feature         # Should fail initially

# 2. Implement feature incrementally
# - Write minimal code to pass tests
# - Refactor and improve
# - Add edge case tests

# 3. Continuous validation
cargo test --lib                    # Unit tests
cargo test --test integration_tests # Integration tests
cargo fmt && cargo clippy -- -D warnings # Code quality
```

### Phase 3: Integration Testing
```bash
# Full test suite on develop branch
cargo test                          # All 59 tests
cargo test -- --nocapture          # With full output if debugging

# Cross-platform testing
./build-releases.sh                 # Build all platforms
# Manual testing on Windows, macOS, Linux
# Shell wrapper validation (bash, fish, PowerShell, cmd)

# Performance regression testing
cargo bench                         # Ensure no performance degradation
```

### Phase 4: Release Testing
```bash
# Comprehensive pre-release validation
cargo test                          # All tests pass
cargo audit                         # Security vulnerabilities
cargo fmt --check                   # Formatting compliance  
cargo clippy -- -D warnings         # Zero warnings

# Release candidate testing
# - Manual end-to-end testing
# - Installation script validation
# - Package manager testing
# - Documentation accuracy verification
```

### Phase 5: Post-Release Testing
```bash
# Validate release in production-like environments
# - Test installation from package managers
# - Verify GitHub release assets
# - Validate documentation links
# - Monitor for post-release issues
```

## 🔄 Development Environment Management

### Keeping Multiple Branches in Sync

```bash
# Daily synchronization routine
git checkout develop
git pull origin develop

# For each active feature branch:
git checkout feature/your-feature
git rebase develop                   # Keep up to date
# Resolve any conflicts
git push --force-with-lease origin feature/your-feature

# Check for outdated branches
git branch -vv | grep behind         # Find branches behind origin
git branch -vv | grep ahead          # Find branches with unpushed changes
```

### Managing Dependencies Across Branches

```bash
# When Cargo dependencies change on develop:
git checkout develop
git pull origin develop
cargo update                         # Update lock file

# Update feature branches:
git checkout feature/your-feature
git rebase develop
cargo build                          # Ensure dependencies work
cargo test                           # Verify tests still pass
```

## 📊 Continuous Monitoring & Quality Gates

### Automated Quality Checks (CI/CD)
```yaml
# Every commit triggers:
✅ Code formatting validation
✅ Clippy linting (zero warnings)
✅ Unit tests (14 tests)
✅ Integration tests (23 tests)  
✅ Shell integration tests (22 tests)
✅ Cross-platform builds (3 platforms)
✅ Security audit (cargo audit)
✅ Performance benchmarks (on develop/release branches)
```

### Manual Quality Gates
```bash
# Before each PR:
✅ All tests pass locally
✅ Code is formatted (cargo fmt)
✅ No clippy warnings
✅ Feature is tested on multiple platforms
✅ Documentation is updated
✅ Breaking changes are documented

# Before release:
✅ All CI checks pass
✅ Performance benchmarks acceptable
✅ Manual testing completed
✅ Release notes are comprehensive
✅ Version consistency verified
```

## 🎯 Best Practices Summary

### Development Flow Best Practices
1. **Small, Focused Commits**: Use conventional commits (feat:, fix:, docs:)
2. **Regular Rebasing**: Keep feature branches up to date with develop
3. **Comprehensive Testing**: Write tests before or alongside implementation
4. **Quality Gates**: Never skip formatting, clippy, or test validation
5. **Documentation**: Update docs with code changes
6. **Cross-Platform**: Always test on multiple platforms before PR

### Branch Management Best Practices
1. **Feature Branches**: One feature per branch, clear naming convention
2. **Develop Branch**: Always deployable, comprehensive CI validation
3. **Release Branches**: Stabilization only, no new features
4. **Master Branch**: Production-ready code only
5. **Hotfix Branches**: Minimal changes, fast-track to production

### Testing Best Practices
1. **Test Coverage**: Maintain above 80% coverage
2. **Cross-Platform**: Test environment variables on all platforms
3. **Integration Tests**: Use `#[serial_test::serial]` for env var tests
4. **Performance**: Monitor for regressions with benchmarks
5. **Security**: Regular security audits with `cargo audit`

## 🎯 Phase 4: Pre-Release Stabilization

### Release Branch Creation

```bash
# When develop is stable and ready for release
git checkout develop
git pull origin develop

# Final validation before release branch
cargo test                         # All tests pass
cargo audit                        # No security issues
cargo bench                        # Performance acceptable
./build-releases.sh                # All platforms build

# Create release branch
git checkout -b release/v1.3.0
git push origin release/v1.3.0
```

### Release Branch Workflow

**Stabilization Process:**
```bash
# Only bug fixes and release preparations on release branch
git checkout release/v1.3.0

# Update version and create release notes
./scripts/update-version.sh 1.3.0
./scripts/create-release-notes.sh 1.3.0

# Edit release notes with comprehensive changes
# Update documentation for new features
# Final testing and validation

git add .
git commit -m "🔖 Bump version to v1.3.0"
git push origin release/v1.3.0
```

**Release Branch Testing:**
```bash
# Comprehensive release validation
cargo test                         # All 59 tests
cargo fmt --check                  # Clean formatting
cargo clippy -- -D warnings        # No warnings
cargo audit                        # Security clean
cargo bench                        # Performance check

# Cross-platform validation  
./build-releases.sh
# Test on multiple platforms
# Validate installation scripts
# Test package manager builds

# Final release candidate testing
# - Manual testing of critical workflows
# - Regression testing of existing features
# - Performance validation
# - Documentation review
```

## 🎯 Phase 5: Release & Post-Release

### Release Process

```bash
# Final release from release branch
git checkout release/v1.3.0

# Create tag and trigger release
git tag -a v1.3.0 -m "Release v1.3.0"
git push origin master
git push origin v1.3.0

# GitHub Actions automatically:
# 1. Validates version consistency
# 2. Builds cross-platform binaries
# 3. Publishes to package managers
# 4. Creates GitHub release
# 5. Updates Docker images
```

### Post-Release Workflow

```bash
# After successful release, update branches
git checkout master
git pull origin master

# Merge release changes back to develop
git checkout develop
git merge master
git push origin develop

# Clean up release branch (optional)
git branch -d release/v1.3.0
git push origin --delete release/v1.3.0

# Update milestone and issues
# - Close completed milestone
# - Move remaining issues to next milestone
# - Create next version planning
```

### Hotfix Workflow (Emergency)

```bash
# Critical bug in production
git checkout master
git pull origin master
git checkout -b hotfix/critical-security-fix

# Make minimal fix
# Test thoroughly
git add .
git commit -m "fix: resolve critical security vulnerability"

# Fast-track release
./scripts/update-version.sh 1.3.1
git add .
git commit -m "🔖 Bump version to v1.3.1"

# Release and merge back
git checkout master
git merge hotfix/critical-security-fix
git tag -a v1.3.1 -m "Hotfix v1.3.1"
git push origin master
git push origin v1.3.1

# Merge to develop
git checkout develop
git merge master
git push origin develop
```