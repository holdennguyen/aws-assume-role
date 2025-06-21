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

## 🏷️ Release Workflow (MANDATORY PROCESS)

### Pre-Release Preparation (BEFORE Master Merge)

#### 1. Version Validation
```bash
# Ensure version consistency across all components
./scripts/update-version.sh [NEW_VERSION]  # Updates all version references
cargo build --release                      # Verify build works
./target/release/aws-assume-role --version # Confirm version
```

#### 2. Multi-Shell Release Updates (CRITICAL)
```bash
# Update local release binaries with latest changes
cargo build --release

# Update multi-shell binaries
cp target/release/aws-assume-role releases/multi-shell/aws-assume-role-macos
cp target/release/aws-assume-role releases/multi-shell/aws-assume-role-unix

# Verify updated binaries
./releases/multi-shell/aws-assume-role-macos --version
./releases/multi-shell/aws-assume-role-unix --version
ls -la releases/multi-shell/aws-assume-role-* # Check timestamps
```

#### 3. Create Release Notes (MANDATORY)
**⚠️ CRITICAL**: Always create release notes BEFORE merging to master

```bash
# Create comprehensive release notes
touch releases/multi-shell/RELEASE_NOTES_v[VERSION].md
```

**Release Notes Template Structure:**
```markdown
# 🚀 AWS Assume Role CLI v[VERSION] Release Notes

**Release Date**: [DATE]  
**Focus**: [PRIMARY_FOCUS]

## 🎯 Overview
[Brief description of the release]

## 🔧 Critical Fixes
### [Category 1]
- **Issue**: Description
- **Solution**: What was fixed
- **Impact**: How it helps users

## 🧪 Testing Improvements
### Enhanced Test Framework
- **Test Coverage**: X unit + Y integration + Z shell tests
- **Platforms**: Ubuntu ✅ Windows ✅ macOS ✅

## 🏗️ Architecture Enhancements
[Technical improvements with code examples if relevant]

## 📦 Distribution Updates
### Multi-Shell Release Binaries
- ✅ **macOS Binary**: Updated with latest fixes
- ✅ **Unix/Linux Binary**: Updated with latest fixes
- ✅/**⚠️** **Windows Binary**: Status and notes

## 🔒 Security & Dependencies
[Security improvements and dependency updates]

## 📋 Technical Details
### Test Matrix
| Platform | Unit Tests | Integration Tests | Shell Tests | Status |
|----------|------------|-------------------|-------------|---------|
| Ubuntu   | X/X ✅     | Y/Y ✅            | Z/Z ✅      | PASS ✅  |
| Windows  | X/X ✅     | Y/Y ✅            | Z/Z ✅      | PASS ✅  |
| macOS    | X/X ✅     | Y/Y ✅            | Z/Z ✅      | PASS ✅  |

## 📥 Installation
[Installation instructions]

## 🙏 Acknowledgments
[Credits and thanks]
```

#### 4. Commit Pre-Release Changes
```bash
# Commit all pre-release updates
git add releases/multi-shell/
git commit -m "📦 Prepare v[VERSION] release artifacts

- Updated multi-shell binaries with latest changes
- Created comprehensive release notes for v[VERSION]
- Verified all local artifacts contain latest fixes
- Ready for production release"
```

### Release Process (After Pre-Release Preparation)

#### 5. Merge to Master
```bash
# Only after ALL pre-release steps completed
git checkout master
git merge develop  # All changes including release notes and updated binaries
```

#### 6. Create Release Tag
```bash
git tag -a v[VERSION] -m "Release v[VERSION]: [BRIEF_DESCRIPTION]

[DETAILED_RELEASE_SUMMARY]"
```

#### 7. Push Release
```bash
git push origin master
git push origin v[VERSION]  # Triggers automated GitHub Actions release
```

### Post-Release Validation
- ✅ GitHub Actions builds all platform binaries
- ✅ GitHub Release created with assets
- ✅ Package managers updated automatically
- ✅ Multi-shell distribution available
- ✅ All installation methods working

### Release Notes Best Practices
1. **User-Focused**: Explain impact, not just technical changes
2. **Comprehensive**: Cover all significant changes
3. **Visual**: Use emojis and tables for readability
4. **Technical Details**: Include code examples for major changes
5. **Installation**: Always include updated installation instructions
6. **Test Matrix**: Show comprehensive testing results
7. **Binary Status**: Clearly indicate which binaries are updated

### Why This Process Matters
- **User Communication**: Release notes inform users of changes
- **Binary Consistency**: Ensures distributed binaries contain latest fixes
- **Quality Assurance**: Validates everything works before public release
- **Documentation**: Creates permanent record of changes
- **Professional Standards**: Maintains high-quality release practices

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