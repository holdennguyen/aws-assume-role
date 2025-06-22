# 🧪 Testing Framework Documentation

## Overview

AWS Assume Role implements a comprehensive testing framework with **79 total tests** covering all aspects of functionality, cross-platform compatibility, and shell integration. This document details our testing strategy, test matrix, and development processes.

## Test Matrix (v1.3.0)

### Complete Test Coverage (79 Tests)

```
Testing Architecture:
├── Unit Tests (23 tests)
│   ├── Config Module (10 tests)
│   └── Error Module (13 tests)
├── Integration Tests (14 tests)
│   ├── CLI Functionality (8 tests)
│   ├── Error Handling (3 tests)
│   └── Config Integration (3 tests)
├── Shell Integration Tests (19 tests)
│   ├── Universal Wrapper Validation (5 tests)
│   │   ├── test_universal_wrapper_structure() - Universal bash wrapper
│   │   ├── test_installation_script_structure()
│   │   ├── test_uninstallation_script_structure()
│   │   └── ...
│   ├── Cross-Platform Features (8 tests)
│   │   ├── test_wrapper_binary_discovery() - Binary path detection
│   │   ├── test_wrapper_error_handling() - Error handling
│   │   ├── test_shell_export_format_integration() - Export format
│   │   ├── test_unix_file_permissions() - Unix executable permissions
│   │   └── ...
│   └── Test Utilities (6 tests)
└── Additional Tests (23 tests)
```

## Testing Strategies

### 1. Unit Testing Strategy

**Scope**: Individual modules and functions in isolation
**Framework**: Built-in Rust testing with custom utilities
**Coverage**: Config and Error modules (23 tests)

```rust
// Example: Isolated unit test with environment setup
#[test]
fn test_config_operations() {
    let temp_dir = TempDir::new().unwrap();
    
    // Cross-platform environment setup
    std::env::set_var("HOME", temp_dir.path());
    #[cfg(windows)]
    std::env::set_var("USERPROFILE", temp_dir.path());
    
    // Test logic with automatic cleanup
    let config = Config::new();
    assert!(config.roles.is_empty());
    
    // Cleanup handled automatically by TempDir
}
```

### 2. Integration Testing Strategy

**Scope**: End-to-end CLI functionality and workflows
**Framework**: assert_cmd for CLI testing, predicates for assertions
**Coverage**: Complete CLI interface (14 tests)

```rust
// Example: CLI integration test
#[test]
fn test_help_output() {
    let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
    cmd.arg("--help")
        .assert()
        .success()
        .stdout(predicate::str::contains("AWS Assume Role CLI"));
}
```

### 3. Shell Integration Testing Strategy (Universal Wrapper)

**Scope**: Validates the single, universal bash wrapper (`aws-assume-role-bash.sh`) and its cross-platform compatibility.
**Framework**: File system validation and script structure analysis.
**Coverage**: Universal wrapper, installer, uninstaller, and cross-platform behavior (19 tests).

```rust
// Example: Universal Wrapper Validation
#[test]
fn test_universal_wrapper_structure() {
    let wrapper_path = Path::new("releases/aws-assume-role-bash.sh");
    assert!(wrapper_path.exists());
    
    let content = fs::read_to_string(wrapper_path).unwrap();
    assert!(content.contains("#!/bin/bash"));
    assert!(content.contains("Platform detection logic")); // Placeholder for actual check
    
    // Validate executable permissions on Unix
    #[cfg(unix)]
    {
        let metadata = fs::metadata(wrapper_path).unwrap();
        let permissions = metadata.permissions();
        assert!(permissions.mode() & 0o111 != 0, "Script should be executable");
    }
}
```

### 4. Performance Testing Strategy

**Scope**: Performance regression detection and optimization
**Framework**: Criterion for benchmarking
**Coverage**: Core operations (9 benchmarks)

```rust
// Example: Performance benchmark
fn config_operations_benchmark(c: &mut Criterion) {
    c.bench_function("config_creation", |b| {
        b.iter(|| {
            let config = Config::new();
            black_box(config);
        });
    });
}
```

## Test Environment Setup

### Cross-Platform Compatibility

Tests handle platform differences automatically:

```rust
// Cross-platform environment variable setup
fn setup_test_environment(temp_dir: &Path) {
    std::env::set_var("HOME", temp_dir);
    
    // Windows-specific environment
    #[cfg(windows)]
    std::env::set_var("USERPROFILE", temp_dir);
    
    // Unix-specific setup
    #[cfg(unix)]
    {
        // Set appropriate permissions
        let mut perms = std::fs::metadata(temp_dir).unwrap().permissions();
        perms.set_mode(0o700);
        std::fs::set_permissions(temp_dir, perms).unwrap();
    }
}
```

### Isolated Test Environments

Every test runs in complete isolation:

```rust
pub struct TestHelper {
    temp_dir: TempDir,
    config_path: PathBuf,
}

impl TestHelper {
    pub fn new() -> Self {
        let temp_dir = TempDir::new().expect("Failed to create temp directory");
        setup_test_environment(temp_dir.path());
        
        Self {
            config_path: temp_dir.path().join(".aws-assume-role").join("config.json"),
            temp_dir,
        }
    }
    
    // Automatic cleanup on drop
}
```

## Test Execution

### Local Development
The standard method for running all tests is to use the pre-commit script. This ensures you are running the exact same checks as the CI pipeline.

```bash
# Run the complete test suite (unit, integration, shell)
./scripts/pre-commit-hook.sh
```

For debugging specific parts of the test suite, you may still use manual `cargo test` commands, but the pre-commit script is the standard for validation.

```bash
# Optional: Run a specific test category
cargo test --test integration_tests

# Optional: Run performance benchmarks
cargo bench
```

### CI/CD Pipeline
Our continuous integration pipeline runs on a matrix of operating systems to ensure full cross-platform compatibility.

```yaml
# .github/workflows/ci-cd.yml
# This file contains the single, unified workflow.
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    rust: [stable]
```
All tests are executed on every push to the `develop` and `master` branches, and on every pull request.

## Quality Metrics

### Current Status (v1.2.0)

- **Total Tests**: 55 (23 unit + 14 integration + 18 shell integration)
- **Success Rate**: 100% (55/55 passing)
- **Platform Coverage**: Ubuntu, Windows, macOS
- **Shell Coverage**: Bash, Zsh, PowerShell, Fish, CMD
- **Security Coverage**: Automated vulnerability scanning
- **Performance Coverage**: Benchmark regression detection
- **Code Coverage**: Comprehensive module coverage with tarpaulin

### Test Quality Standards

1. **Isolation**: Every test runs in isolated environment
2. **Cleanup**: Automatic resource cleanup (no test pollution)
3. **Cross-Platform**: Platform-specific logic properly tested
4. **Error Handling**: Comprehensive error scenario coverage
5. **Performance**: No regression in benchmark tests
6. **Security**: No credential leakage in test environments
7. **Documentation**: Every test clearly documents its purpose

## Development Workflow

### Test-Driven Development

```bash
# 1. Write failing test first
cargo test test_new_feature -- --ignored

# 2. Implement feature
# ... code changes ...

# 3. Validate all tests pass
cargo test                                 # All 55 tests

# 4. Run quality checks
cargo fmt --all -- --check
cargo clippy -- -D warnings
cargo audit

# 5. Commit with proper convention
git commit -m "feat: implement new feature with comprehensive tests"
```

### Adding New Tests

#### Unit Tests
Add to appropriate module (config/mod.rs or error/mod.rs):

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;
    
    #[test]
    fn test_new_functionality() {
        let helper = TestHelper::new();
        // Test implementation
    }
}
```

#### Integration Tests
Add to tests/integration_tests.rs:

```rust
#[test]
fn test_new_cli_feature() {
    let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
    cmd.arg("new-command")
        .assert()
        .success();
}
```

#### Shell Integration Tests
Add to tests/shell_integration_tests.rs:

```rust
#[test]
fn test_new_shell_feature() {
    let script_path = Path::new("releases/new-script.sh");
    assert!(script_path.exists());
    // Validation logic
}
```

## Future Testing Enhancements

### Planned Improvements
- **Property-Based Testing**: Expand proptest usage for edge case discovery
- **Mutation Testing**: Implement cargo-mutants for test quality validation
- **Load Testing**: AWS API rate limiting and error handling under load
- **Container Testing**: Docker integration testing
- **Security Testing**: Penetration testing for credential handling

### Test Metrics Tracking
- **Coverage Trends**: Track test coverage over time
- **Performance Regression**: Automated benchmark comparison
- **Flaky Test Detection**: Identify and fix unreliable tests
- **Test Execution Time**: Optimize slow-running tests

This comprehensive testing framework ensures AWS Assume Role maintains enterprise-grade quality and reliability across all supported platforms and shell environments. 