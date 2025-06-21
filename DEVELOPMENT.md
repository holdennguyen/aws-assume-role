# Development Guide

## 🔒 Security First

### Latest Security Enhancement (v1.2.0+)
AWS Assume Role has been upgraded to AWS SDK v1.x with `aws-lc-rs` cryptographic backend, **completely resolving all ring vulnerabilities**:

- ✅ **RUSTSEC-2025-0009**: ring AES panic issue - FIXED
- ✅ **RUSTSEC-2025-0010**: ring unmaintained warning - FIXED  
- ✅ **Clean Security Audit**: Modern, AWS-maintained cryptography
- ✅ **FIPS Ready**: Optional FIPS 140-3 compliance available
- ✅ **Post-Quantum Crypto**: Future-proof cryptographic support

See `memory-bank/security-upgrade.md` for complete security upgrade details.

### Security Practices
```bash
# Always run security audit before commits
cargo audit

# Should show only minor test dependency warnings
# No critical vulnerabilities should be present
```

## 🔄 Git Flow Workflow

We use a modified Git Flow branching strategy to manage development:

### Branch Structure

- **`master`**: Production-ready code, tagged releases
- **`develop`**: Integration branch, latest development features  
- **`feature/*`**: New features and enhancements
- **`release/*`**: Release preparation and testing
- **`hotfix/*`**: Critical fixes for production issues

### Workflow Commands

#### Starting New Features
```bash
# Create and switch to feature branch
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name

# Work on your feature...
git add .
git commit -m "feat: implement your feature"

# Push feature branch
git push -u origin feature/your-feature-name
```

## 🧪 Comprehensive Testing Framework

### Test Matrix Overview (55 Total Tests)

Our testing framework provides comprehensive coverage across all functionality:

```
Testing Framework (v1.2.0):
├── Unit Tests (23 tests)
│   ├── Config Module (10 tests)
│   │   ├── Role configuration and management
│   │   ├── Serialization/deserialization
│   │   ├── File I/O operations
│   │   └── Cross-platform path handling
│   └── Error Module (13 tests)
│       ├── Error type creation and conversion
│       ├── Display and debug formatting
│       ├── Error chaining and context
│       └── Result type handling
├── Integration Tests (14 tests)
│   ├── CLI Functionality (8 tests)
│   │   ├── Help output verification
│   │   ├── Version information
│   │   └── Command validation
│   ├── Error Handling (3 tests)
│   │   ├── Invalid input validation
│   │   └── Graceful error recovery
│   └── Config Workflow (3 tests)
│       └── End-to-end configuration testing
└── Shell Integration Tests (18 tests) ← v1.2.0 NEW!
    ├── Wrapper Script Structure (4 tests)
    │   ├── Bash/Zsh wrapper validation
    │   ├── PowerShell wrapper validation
    │   ├── Fish shell wrapper validation
    │   └── CMD batch wrapper validation
    ├── Cross-Platform Features (8 tests)
    │   ├── Binary discovery logic
    │   ├── Error handling patterns
    │   ├── Usage information display
    │   ├── Export format integration
    │   ├── File permissions (Unix)
    │   ├── Installation scripts
    │   ├── Documentation validation
    │   └── Version consistency
    └── Test Utilities (6 tests)
        └── Common testing infrastructure
```

### Test Structure

```
Project Testing Architecture:
├── src/
│   ├── lib.rs                   # Library entry point (enables unit testing)
│   ├── config/mod.rs           # Config module + 10 unit tests
│   ├── error/mod.rs            # Error module + 13 unit tests
│   ├── cli/mod.rs              # CLI logic (tested via integration)
│   └── aws/mod.rs              # AWS integration (tested via integration)
├── tests/
│   ├── common/mod.rs           # Shared test utilities and helpers
│   ├── integration_tests.rs    # 14 CLI and workflow tests
│   └── shell_integration_tests.rs # 18 shell wrapper tests (NEW v1.2.0)
├── benches/
│   └── performance.rs          # Performance benchmarks (Criterion)
└── releases/multi-shell/       # Shell wrapper scripts (tested)
    ├── aws-assume-role-bash.sh
    ├── aws-assume-role-powershell.ps1
    ├── aws-assume-role-fish.fish
    ├── aws-assume-role-cmd.bat
    ├── INSTALL.sh / INSTALL.ps1
    └── UNINSTALL.sh / UNINSTALL.ps1
```

### Running Tests

#### Complete Test Suite (Recommended)
```bash
# Run all 55 tests across all categories
cargo test

# Run with detailed output
cargo test -- --nocapture

# Run with test timing information
cargo test -- --nocapture --show-output
```

#### Test Categories

#### Unit Tests (23 tests)
```bash
# Run all unit tests
cargo test --lib

# Run specific module tests
cargo test --lib config::tests
cargo test --lib error::tests
```

#### Integration Tests (14 tests)
```bash
# Run all integration tests
cargo test --test integration_tests

# Run specific integration test groups
cargo test --test integration_tests integration::
cargo test --test integration_tests error_handling::
cargo test --test integration_tests config_integration::
```

#### Shell Integration Tests (18 tests) - NEW v1.2.0
```bash
# Run all shell integration tests
cargo test --test shell_integration_tests

# Run specific shell wrapper tests
cargo test test_bash_wrapper_structure
cargo test test_powershell_wrapper_structure
cargo test test_fish_wrapper_structure
cargo test test_cmd_wrapper_structure

# Run cross-platform feature tests
cargo test test_wrapper_binary_discovery
cargo test test_wrapper_error_handling
cargo test test_shell_export_format_integration
```

#### Performance Benchmarks
```bash
# Run all performance benchmarks
cargo bench

# Run specific benchmark categories
cargo bench config_operations
cargo bench file_operations
```

### Test Environment Setup

#### Isolated Testing
All tests use isolated environments to prevent interference:

```rust
// Example: Isolated test environment
use tempfile::TempDir;

#[test]
fn test_with_isolation() {
    let temp_dir = TempDir::new().unwrap();
    
    // Set cross-platform environment variables
    std::env::set_var("HOME", temp_dir.path());
    #[cfg(windows)]
    std::env::set_var("USERPROFILE", temp_dir.path());
    
    // Test logic here...
    
    // Automatic cleanup on test completion
}
```

#### Cross-Platform Compatibility
Tests handle platform differences automatically:

```rust
// Cross-platform file permissions testing
#[cfg(unix)]
#[test]
fn test_unix_permissions() {
    // Unix-specific permission testing
}

#[cfg(windows)]
#[test]
fn test_windows_permissions() {
    // Windows-specific permission testing
}
```

### Test Coverage Analysis

```bash
# Install coverage tool (one-time setup)
cargo install cargo-tarpaulin

# Generate comprehensive coverage report
cargo tarpaulin --verbose --all-features --workspace --timeout 120

# Generate coverage with specific test exclusions
cargo tarpaulin --verbose --all-features --workspace --timeout 120 \
  --exclude-files "tests/*" --exclude-files "benches/*"

# HTML coverage report
cargo tarpaulin --verbose --all-features --workspace --timeout 120 \
  --out Html --output-dir coverage/
```

### Test Quality Metrics

#### Current Status (v1.2.0)
- **Total Tests**: 55 (23 unit + 14 integration + 18 shell integration)
- **Success Rate**: 100% (55/55 passing)
- **Platform Coverage**: Ubuntu, Windows, macOS
- **Shell Coverage**: Bash, Zsh, PowerShell, Fish, CMD
- **Security Coverage**: Automated vulnerability scanning
- **Performance Coverage**: Benchmark regression detection

## 🏗️ Development Environment

### Prerequisites
- **Rust**: 1.70+ with stable toolchain
- **Git**: Configured with repository access
- **AWS CLI**: v2 for integration testing (optional)

### Setup
```bash
# Clone repository
git clone https://github.com/holdennguyen/aws-assume-role.git
cd aws-assume-role

# Switch to develop branch
git checkout develop

# Install dependencies and build
cargo build

# Run tests to verify setup
cargo test
```

## 🚀 CI/CD Pipeline

### Quality Gates (Enhanced v1.2.0)

All pull requests must pass comprehensive quality checks:

#### Code Quality Gates
1. ✅ **Formatting Check**: `cargo fmt --all -- --check`
2. ✅ **Linting**: `cargo clippy -- -D warnings` (zero warnings policy)
3. ✅ **Documentation**: All public APIs documented

#### Testing Gates (55 Total Tests)
4. ✅ **Unit Tests**: All 23 module tests passing (config + error)
5. ✅ **Integration Tests**: All 14 CLI and workflow tests passing
6. ✅ **Shell Integration Tests**: All 18 wrapper script tests passing ← NEW v1.2.0
7. ✅ **Cross-Platform Tests**: Ubuntu, Windows, macOS validation
8. ✅ **Performance Benchmarks**: No regression detection (advisory)

#### Security & Compliance Gates
9. ✅ **Security Audit**: `cargo audit` with clean results
10. ✅ **Vulnerability Scanning**: No critical security issues
11. ✅ **Dependency Validation**: Up-to-date and secure dependencies

#### Build & Distribution Gates
12. ✅ **Cross Compilation**: Linux, Windows, macOS builds successful
13. ✅ **Release Builds**: Optimized builds for all platforms
14. ✅ **Binary Validation**: Generated binaries functional

### GitHub Actions Workflow

Our CI/CD pipeline runs on multiple platforms and validates all aspects:

```yaml
# .github/workflows/test.yml (Enhanced v1.2.0)
Strategy Matrix:
├── Platforms: [ubuntu-latest, windows-latest, macos-latest]
├── Rust Versions: [stable]
└── Test Categories:
    ├── Unit Tests (23 tests)
    ├── Integration Tests (14 tests) 
    ├── Shell Integration Tests (18 tests)
    ├── Security Audit
    ├── Performance Benchmarks
    └── Cross-compilation Verification
```

### Local Development Workflow

#### Pre-commit Checklist
```bash
# 1. Run complete test suite
cargo test                              # All 55 tests

# 2. Check code formatting
cargo fmt --all -- --check

# 3. Run linting with strict warnings
cargo clippy -- -D warnings

# 4. Security audit
cargo audit

# 5. Performance benchmarks (optional)
cargo bench

# 6. Cross-platform build test (optional)
cargo build --target x86_64-pc-windows-gnu    # Windows
cargo build --target x86_64-unknown-linux-gnu # Linux
```

#### Test-Driven Development
```bash
# Development cycle with comprehensive testing
git checkout develop
git pull origin develop
git checkout -b feature/new-feature

# Write tests first
cargo test --test integration_tests test_new_feature -- --ignored

# Implement feature
# ... code changes ...

# Validate all tests
cargo test                              # All 55 tests must pass

# Commit with proper convention
git add .
git commit -m "feat: implement new feature with comprehensive tests"
```

## 📝 Commit Standards

### Conventional Commits Format
```
type(scope): description
```

#### Types
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `test`: Test additions/modifications
- `refactor`: Code restructuring
- `perf`: Performance improvements
- `ci`: CI/CD configuration changes 