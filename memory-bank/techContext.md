# Technical Context

## Technology Stack

### Core Technology
- **Language**: Rust 1.70+ (chosen for performance, safety, and cross-platform support)
- **CLI Framework**: clap 4.0+ with derive macros
- **AWS Integration**: aws-sdk-sts 0.30.0, aws-config 0.56.1
- **Async Runtime**: tokio 1.0+ with full features
- **Serialization**: serde + serde_json for configuration management

### Key Dependencies
```toml
aws-config = "0.56.1"        # AWS SDK configuration
aws-sdk-sts = "0.30.0"       # STS role assumption
clap = "4.0"                 # CLI argument parsing
serde = "1.0"                # JSON serialization
tokio = "1.0"                # Async runtime
dirs = "5.0"                 # Cross-platform directory detection
anyhow = "1.0"               # Error handling
tracing = "0.1"              # Structured logging
```

## Build & Distribution

### Cross-Platform Compilation
- **Targets**: x86_64-apple-darwin, aarch64-apple-darwin, x86_64-pc-windows-gnu, x86_64-unknown-linux-gnu
- **Build Script**: `build-releases.sh` for automated multi-platform builds
- **Output**: Single binary per platform, no runtime dependencies

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

### Security Features
- **No Credential Storage**: Only stores role ARNs, never AWS credentials
- **Minimal Permissions**: Requires only sts:AssumeRole permission
- **Session Management**: Proper handling of temporary credentials
- **Error Safety**: No credential leakage in logs or error messages

## Development Requirements

### Development Environment
- Rust 1.70+ with stable toolchain
- AWS CLI v2 configured for testing
- Cross-compilation targets for release builds
- Git with proper repository access

### Testing Environment  
- Unit testing with cargo test
- Integration testing with assert_cmd
- Cross-platform testing (macOS, Linux, Windows)
- AWS SDK mocking for isolated tests

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

## Deployment Architecture
- **Single Binary**: Self-contained executable per platform
- **No Dependencies**: No external runtime requirements
- **Shell Integration**: Wrapper scripts for enhanced shell integration
- **Container Support**: Docker image available via GitHub Container Registry 