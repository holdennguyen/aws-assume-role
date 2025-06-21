# Development Workflow & Common Patterns

## 🚨 CRITICAL: Mandatory Post-Change Workflow

### The Formatting Pattern (ALWAYS REQUIRED)
Every code change in this project MUST follow this sequence:

```bash
# 1. Make your code changes (fix bugs, add features, etc.)
[edit files]

# 2. MANDATORY: Apply formatting (prevents CI failures)
cargo fmt

# 3. Verify formatting is correct
cargo fmt --check

# 4. Ensure tests still pass
cargo test

# 5. Commit with descriptive message
git add -A
git commit -m "fix: apply cargo fmt after [your change description]"

# 6. Push to trigger CI
git push origin [branch-name]
```

### Why This Pattern Exists
- **Rust Formatter**: `rustfmt` has strict formatting rules
- **CI Pipeline**: Zero tolerance for formatting violations
- **Historical Pattern**: EVERY code change triggers formatting issues
- **Solution**: Always format after ANY modification

## 🔄 Git Flow Workflow

### Branch Structure
```
master (production)
├── develop (integration)
    ├── feature/comprehensive-testing
    ├── feature/security-upgrade  
    ├── release/v1.2.0
    └── hotfix/critical-fix
```

### Development Cycle
1. **Start Feature**: `git checkout develop && git pull && git checkout -b feature/your-feature`
2. **Develop**: Make changes, test locally, commit frequently
3. **Format**: ALWAYS run `cargo fmt` before final commit
4. **Test**: Ensure all 59 tests pass with `cargo test`
5. **Quality**: Check with `cargo clippy -- -D warnings`
6. **Push**: `git push origin feature/your-feature`
7. **PR**: Create pull request to `develop` branch
8. **CI**: Wait for all quality gates to pass
9. **Merge**: Merge to `develop` after approval

## 🧪 Testing Workflow

### Local Testing Strategy
```bash
# Quick validation (run frequently)
cargo test --lib                    # Unit tests (23)
cargo clippy -- -D warnings         # Linting
cargo fmt --check                   # Formatting

# Comprehensive validation (before PR)
cargo test                          # All tests (59)
cargo bench                         # Performance benchmarks
cargo audit                         # Security audit
```

### Test Categories
1. **Unit Tests (23)**: `cargo test --lib` - Fast, isolated module tests
2. **Integration Tests (14)**: `cargo test --test integration_tests` - CLI workflow tests
3. **Shell Tests (18)**: `cargo test --test shell_integration_tests` - Wrapper script tests
4. **Performance**: `cargo bench` - Regression detection

### Cross-Platform Considerations
- **Environment Variables**: Use both `HOME` and `USERPROFILE` for Windows
- **Serial Tests**: Use `#[serial_test::serial]` for env var tests
- **Path Handling**: Use `PathBuf` for cross-platform paths
- **Permissions**: Conditional `#[cfg(unix)]` for Unix-specific tests

## 🔧 Common Development Patterns

### Environment Variable Testing
```rust
#[test]
#[serial_test::serial]  // Prevents race conditions
fn test_with_env_vars() {
    // Store original values
    let original_home = std::env::var("HOME").ok();
    #[cfg(windows)]
    let original_userprofile = std::env::var("USERPROFILE").ok();
    
    // Set test values
    std::env::set_var("HOME", temp_dir.path());
    #[cfg(windows)]
    std::env::set_var("USERPROFILE", temp_dir.path());
    
    // Test logic here...
    
    // Restore original values (not remove!)
    match original_home {
        Some(value) => std::env::set_var("HOME", value),
        None => std::env::remove_var("HOME"),
    }
    #[cfg(windows)]
    match original_userprofile {
        Some(value) => std::env::set_var("USERPROFILE", value),
        None => std::env::remove_var("USERPROFILE"),
    }
}
```

### Error Handling Pattern
```rust
// Use AppResult for consistent error handling
pub type AppResult<T> = Result<T, AppError>;

// Implement From traits for easy conversion
impl From<std::io::Error> for AppError {
    fn from(err: std::io::Error) -> Self {
        AppError::IoError(err.to_string())
    }
}
```

### Configuration Management
```rust
// Always use Default trait for structs
#[derive(Default, Serialize, Deserialize)]
pub struct Config {
    pub roles: Vec<RoleConfig>,
}

// Implement new() that calls default
impl Config {
    pub fn new() -> Self {
        Self::default()
    }
}
```

## 🚀 CI/CD Integration

### Quality Gates (All Must Pass)
1. **Formatting**: `cargo fmt --all -- --check`
2. **Linting**: `cargo clippy --all-targets --all-features -- -D warnings`
3. **Testing**: All 59 tests across 3 platforms
4. **Security**: `cargo audit` with clean results
5. **Performance**: Benchmark regression detection

### Platform Matrix
- **Ubuntu Latest**: Primary development platform
- **Windows Latest**: Cross-platform compatibility
- **macOS Latest**: Apple ecosystem support

### Security Scanning
- **Vulnerability Detection**: Automated `cargo audit`
- **Dependency Monitoring**: AWS SDK v1.x with `aws-lc-rs`
- **Clean Results**: Zero tolerance for security issues

## 📚 Documentation Workflow

### Memory Bank Maintenance
- **activeContext.md**: Current status and recent changes
- **progress.md**: What works, what's left, evolution
- **techContext.md**: Technical details and test metrics
- **systemPatterns.md**: Architecture and design decisions
- **security-upgrade.md**: Security enhancement details

### Documentation Updates
Update memory bank when:
1. Major features added or changed
2. Architecture decisions made
3. Testing framework enhanced
4. Security improvements implemented
5. User requests **update memory bank**

## 🐛 Troubleshooting Common Issues

### Formatting Failures
- **Problem**: CI fails at "Check formatting"
- **Solution**: Always run `cargo fmt` after code changes
- **Prevention**: Set up pre-commit hooks or IDE auto-format

### Windows Test Failures
- **Problem**: `test_config_path` fails on Windows
- **Solution**: Use both `HOME` and `USERPROFILE` environment variables
- **Prevention**: Use `#[serial_test::serial]` for environment tests

### Clippy Warnings
- **Problem**: CI fails at "Run clippy"
- **Solution**: Fix warnings or add `#[allow(clippy::specific_lint)]`
- **Prevention**: Run `cargo clippy -- -D warnings` locally

### Security Audit Failures
- **Problem**: Vulnerable dependencies detected
- **Solution**: Update to latest secure versions (e.g., AWS SDK v1.x)
- **Prevention**: Regular `cargo audit` and dependency monitoring

## 🎯 Best Practices Summary

1. **Always Format**: Run `cargo fmt` after ANY code change
2. **Test Thoroughly**: All 59 tests must pass before PR
3. **Document Changes**: Update memory bank for significant changes
4. **Security First**: Monitor and resolve vulnerabilities immediately
5. **Cross-Platform**: Test on multiple platforms and shells
6. **Git Flow**: Use proper branching strategy
7. **Quality Gates**: Ensure all CI checks pass
8. **Memory Bank**: Learn from patterns and document solutions 