# Technical Context

## Technology Stack

### Core Technology
- **Language**: Rust 1.70+ (chosen for performance, safety, and cross-platform support)
- **CLI Framework**: clap 4.0+ with derive macros
- **AWS Integration**: aws-sdk-sts 1.75.0, aws-sdk-sso 1.73.0, aws-config 1.8.0 (AWS SDK v1.x)
- **Cryptographic Backend**: aws-lc-rs 1.13.1 (AWS Libcrypto for Rust)
- **Async Runtime**: tokio 1.0+ with full features
- **Serialization**: serde + serde_json for configuration management

### Key Dependencies (Updated v1.2.0+)
```toml
# AWS SDK v1.x (Security Enhanced)
aws-config = { version = "1.8.0", features = ["behavior-version-latest"] }
aws-sdk-sts = "1.75.0"       # Latest STS client
aws-sdk-sso = "1.73.0"       # Latest SSO client

# Core Dependencies
clap = { version = "4.0", features = ["derive"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tokio = { version = "1.0", features = ["full"] }
dirs = "5.0"                 # Cross-platform directory detection
anyhow = "1.0"               # Error handling
tracing = "0.1"              # Structured logging
tracing-subscriber = "0.3"   # Log formatting

# Testing Framework (v1.2.0+)
[dev-dependencies]
tempfile = "3.0"             # Temporary test directories
assert_cmd = "2.0"           # CLI testing
predicates = "3.0"           # Test assertions
tokio-test = "0.4"           # Async testing utilities
mock_instant = "0.3"         # Time mocking
serial_test = "3.0"          # Sequential test execution
env_logger = "0.10"          # Test logging
test-log = "0.2"             # Test log integration
rstest = "0.18"              # Parameterized testing
proptest = "1.0"             # Property-based testing
criterion = "0.5"            # Performance benchmarking
wiremock = "0.5"             # HTTP mocking
```

### Security Enhancements (v1.2.0+)
- **Cryptographic Library**: aws-lc-rs (AWS-maintained, FIPS-ready)
- **Vulnerability Status**: Clean security audit (no critical vulnerabilities)
- **FIPS Compliance**: Optional FIPS 140-3 certified cryptography available
- **Post-Quantum Crypto**: X25519MLKEM768 support for future-proofing
- **Active Maintenance**: AWS-supported cryptographic stack

## Build & Distribution

### Cross-Platform Compilation
- **Targets**: x86_64-apple-darwin, aarch64-apple-darwin, x86_64-pc-windows-gnu, x86_64-unknown-linux-gnu
- **Build Script**: `build-releases.sh` for automated multi-platform builds
- **Output**: Single binary per platform, no runtime dependencies
- **Security**: Modern cryptographic backend with no known vulnerabilities

### Package Distribution
- **Automated CI/CD**: GitHub Actions workflow for all package managers
- **Cargo**: Published to crates.io
- **Homebrew**: Personal tap (holdennguyen/homebrew-tap)
- **APT**: Launchpad PPA (ppa:holdennguyen/aws-assume-role)
- **YUM/DNF**: COPR repository (holdennguyen/aws-assume-role)

## Performance Characteristics

### Resource Usage
- **Binary Size**: ~8-15MB per platform (optimized release builds)
- **Memory**: <10MB runtime footprint
- **Startup**: <100ms cold start
- **AWS Calls**: Single STS AssumeRole operation per role switch
- **Cryptographic Performance**: Enhanced with aws-lc-rs optimizations

### Security Features (Enhanced)
- **Modern Cryptography**: AWS-LC based cryptographic operations
- **No Credential Storage**: Only stores role ARNs, never AWS credentials
- **Minimal Permissions**: Requires only sts:AssumeRole permission
- **Session Management**: Proper handling of temporary credentials with secure expiration
- **Error Safety**: No credential leakage in logs or error messages
- **Vulnerability Free**: Clean security audit with modern dependencies

## Testing Framework (v1.2.0+)

### Test Coverage
- **Unit Tests**: 23 tests covering config and error modules
- **Integration Tests**: 14 tests for CLI functionality and workflows
- **Performance Tests**: 9 benchmarks with Criterion for regression detection
- **Cross-Platform**: Automated testing on Ubuntu, Windows, macOS
- **Isolated Environments**: Temporary directories with automatic cleanup

### Test Utilities
```rust
// Test helper for isolated environments
pub struct TestHelper {
    temp_dir: TempDir,
    config_path: PathBuf,
}

impl TestHelper {
    pub fn new() -> Self { /* Creates isolated test environment */ }
    pub fn create_sample_config(&self) -> Config { /* Mock data */ }
    pub fn create_mock_credentials() -> Credentials { /* Test credentials */ }
}
```

### CI/CD Pipeline
- **Multi-Platform Testing**: Ubuntu, Windows, macOS
- **Code Quality**: Formatting (rustfmt), linting (clippy), security audit
- **Performance Monitoring**: Benchmark regression detection
- **Security Scanning**: Automated vulnerability detection
- **Cross-Compilation**: Verification builds for multiple targets

## Development Requirements

### Development Environment
- Rust 1.70+ with stable toolchain
- AWS CLI v2 configured for testing
- Cross-compilation targets for release builds
- Git with proper repository access
- cargo-audit for security scanning

### Testing Environment  
- Unit testing with cargo test (23 tests)
- Integration testing with assert_cmd (14 tests)
- Performance testing with criterion (9 benchmarks)
- Cross-platform testing (macOS, Linux, Windows)
- AWS SDK mocking for isolated tests
- Temporary directory isolation for test safety

### Git Flow Workflow
- **Branches**: master (production) → develop (integration) → feature/* branches
- **Quality Gates**: All tests must pass, formatting and clippy clean
- **Security**: Automated vulnerability scanning on all branches
- **Documentation**: DEVELOPMENT.md with complete workflow guide

## Configuration Management

### Storage Location
- **Path**: `~/.aws-assume-role/config.json`
- **Format**: JSON with role configurations
- **Permissions**: User-only read/write (600)

### File Structure
```json
{
  "roles": {
    "role-name": {
      "role_arn": "arn:aws:iam::123456789012:role/MyRole",
      "session_duration": 3600
    }
  }
}
```

## AWS SDK Integration (v1.x)

### Behavior Version
```rust
// Using latest AWS SDK patterns
let config_builder = aws_config::defaults(aws_config::BehaviorVersion::latest());
```

### Client Configuration
```rust
// Modern AWS client setup
pub async fn new() -> AppResult<Self> {
    let config_builder = aws_config::defaults(aws_config::BehaviorVersion::latest());
    let config = config_builder.load().await;
    Ok(Self::new_with_config(&config))
}
```

### Credential Handling
```rust
// Updated for AWS SDK v1.x DateTime handling
let expiration = Some(
    UNIX_EPOCH + std::time::Duration::from_secs(credentials.expiration.secs() as u64)
);
```

## Deployment Architecture
- **Single Binary**: Self-contained executable per platform
- **No Dependencies**: No external runtime requirements
- **Shell Integration**: Wrapper scripts for enhanced shell integration
- **Container Support**: Docker image available via GitHub Container Registry
- **Security**: Modern cryptographic backend with enterprise-grade security
- **Compliance Ready**: Optional FIPS mode for government/enterprise use

## Quality Metrics
- **Test Success Rate**: 100% (37/37 tests passing)
- **Security Status**: Clean audit (only minor test dependency warnings)
- **Performance**: Sub-second operations with benchmark monitoring
- **Code Quality**: Enforced formatting, linting, and documentation standards
- **Reliability**: Comprehensive error handling and graceful degradation 