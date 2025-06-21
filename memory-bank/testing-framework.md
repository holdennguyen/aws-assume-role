# Testing Framework Documentation

## Overview

AWS Assume Role implements a comprehensive testing framework with 55 total tests covering all aspects of functionality, cross-platform compatibility, and shell integration. This document details our testing strategy, test matrix, and development processes.

## Test Matrix (v1.2.0)

### Complete Test Coverage (55 Tests)

```
Testing Architecture:
├── Unit Tests (23 tests)
│   ├── Config Module (10 tests)
│   │   ├── test_config_new_default() - Config creation and defaults
│   │   ├── test_config_add_role() - Role addition functionality
│   │   ├── test_config_remove_role() - Role removal functionality
│   │   ├── test_config_get_role() - Role retrieval
│   │   ├── test_config_list_roles() - Role listing
│   │   ├── test_config_serialization() - JSON serialization/deserialization
│   │   ├── test_config_save_and_load() - File I/O operations
│   │   ├── test_config_path() - Cross-platform path handling
│   │   ├── test_config_ensure_directory() - Directory creation
│   │   └── test_config_file_permissions() - Security permissions
│   └── Error Module (13 tests)
│       ├── test_app_error_creation() - Error type creation
│       ├── test_app_error_display() - Display formatting
│       ├── test_app_error_debug() - Debug formatting
│       ├── test_config_error_creation() - Config error handling
│       ├── test_config_error_display() - Config error formatting
│       ├── test_aws_error_creation() - AWS error handling
│       ├── test_aws_error_display() - AWS error formatting
│       ├── test_error_conversion() - Error type conversion
│       ├── test_error_chaining() - Error context chaining
│       ├── test_result_types() - Result type handling
│       ├── test_error_from_implementations() - From trait implementations
│       ├── test_anyhow_integration() - anyhow error integration
│       └── test_error_source_chain() - Error source tracking
├── Integration Tests (14 tests)
│   ├── CLI Functionality (8 tests)
│   │   ├── test_help_output() - Main help display
│   │   ├── test_configure_help() - Configure command help
│   │   ├── test_list_help() - List command help
│   │   ├── test_remove_help() - Remove command help
│   │   ├── test_version_output() - Version information
│   │   ├── test_invalid_command() - Invalid command handling
│   │   ├── test_missing_args() - Missing argument validation
│   │   └── test_command_validation() - Command structure validation
│   ├── Error Handling (3 tests)
│   │   ├── test_graceful_error_handling() - Error recovery
│   │   ├── test_invalid_input_handling() - Input validation
│   │   └── test_filesystem_error_handling() - File system errors
│   └── Config Integration (3 tests)
│       ├── test_config_workflow() - End-to-end configuration
│       ├── test_role_management_workflow() - Role CRUD operations
│       └── test_error_scenarios() - Error scenario handling
└── Shell Integration Tests (18 tests) ← NEW v1.2.0
    ├── Wrapper Script Structure (4 tests)
    │   ├── test_bash_wrapper_structure() - Bash/Zsh wrapper validation
    │   ├── test_powershell_wrapper_structure() - PowerShell wrapper validation
    │   ├── test_fish_wrapper_structure() - Fish shell wrapper validation
    │   └── test_cmd_wrapper_structure() - CMD batch wrapper validation
    ├── Cross-Platform Features (8 tests)
    │   ├── test_wrapper_binary_discovery() - Binary path detection
    │   ├── test_wrapper_error_handling() - Error handling patterns
    │   ├── test_wrapper_usage_information() - Usage/help display
    │   ├── test_shell_export_format_integration() - Export format validation
    │   ├── test_unix_file_permissions() - Unix executable permissions
    │   ├── test_installation_scripts() - Install/uninstall scripts
    │   ├── test_readme_documentation() - Documentation validation
    │   └── test_version_consistency() - Version consistency across scripts
    └── Test Utilities (6 tests)
        ├── test_sample_config_creation() - Mock configuration generation
        ├── test_mock_credentials() - Test credential creation
        ├── test_temp_directory_isolation() - Environment isolation
        ├── test_cross_platform_paths() - Path handling utilities
        ├── test_file_permission_helpers() - Permission testing utilities
        └── test_cleanup_verification() - Automatic cleanup validation
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

### 3. Shell Integration Testing Strategy ← NEW v1.2.0

**Scope**: Wrapper scripts and cross-platform shell compatibility
**Framework**: File system validation and script structure analysis
**Coverage**: All shell wrappers and installation scripts (18 tests)

```rust
// Example: Shell wrapper validation
#[test]
fn test_bash_wrapper_structure() {
    let wrapper_path = Path::new("releases/multi-shell/aws-assume-role-bash.sh");
    assert!(wrapper_path.exists());
    
    let content = fs::read_to_string(wrapper_path).unwrap();
    assert!(content.contains("#!/bin/bash"));
    assert!(content.contains("aws-assume-role"));
    
    // Validate executable permissions on Unix
    #[cfg(unix)]
    {
        let metadata = fs::metadata(wrapper_path).unwrap();
        let permissions = metadata.permissions();
        assert!(permissions.mode() & 0o111 != 0); // Executable
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

```bash
# Complete test suite (55 tests)
cargo test

# Test categories
cargo test --lib                           # Unit tests (23)
cargo test --test integration_tests        # Integration tests (14)
cargo test --test shell_integration_tests  # Shell integration tests (18)

# Performance benchmarks
cargo bench

# Test with coverage
cargo tarpaulin --verbose --all-features --workspace --timeout 120
```

### CI/CD Pipeline

```yaml
# GitHub Actions Test Matrix
Strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    rust: [stable]

Jobs:
├── Code Quality
│   ├── cargo fmt --all -- --check
│   ├── cargo clippy -- -D warnings
│   └── cargo audit
├── Unit Tests (23 tests)
│   └── cargo test --lib
├── Integration Tests (14 tests)
│   └── cargo test --test integration_tests
├── Shell Integration Tests (18 tests)
│   └── cargo test --test shell_integration_tests
├── Performance Tests
│   └── cargo bench
└── Cross-Compilation
    ├── x86_64-pc-windows-gnu
    ├── x86_64-unknown-linux-gnu
    └── x86_64-apple-darwin
```

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
    let script_path = Path::new("releases/multi-shell/new-script.sh");
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