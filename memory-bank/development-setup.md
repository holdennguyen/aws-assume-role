# Development Setup

## Quick Start
```bash
# Clone and build
git clone https://github.com/holdennguyen/aws-assume-role.git
cd aws-assume-role
cargo build

# Run tests
cargo test

# Build release
./build-releases.sh
```

## Prerequisites
- **Rust**: 1.70+ with stable toolchain
- **AWS CLI**: v2 configured with SSO access
- **Git**: Configured with repository access

## Installation
```bash
# Install Rust (if needed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install AWS CLI (macOS)
brew install awscli

# Verify setup
rustc --version
cargo --version
aws --version
```

## Development Commands
```bash
# Build debug version
cargo build

# Build optimized release
cargo build --release

# Run all tests
cargo test

# Run specific tests
cargo test test_name

# Format code
cargo fmt

# Lint code
cargo clippy

# Clean build artifacts
cargo clean
```

## Cross-Platform Release Build
```bash
# Build for all platforms
./build-releases.sh

# Manually build for specific target
cargo build --release --target x86_64-apple-darwin
```

## Project Structure
```
aws-assume-role/
├── src/                    # Source code
│   ├── cli/               # CLI interface
│   ├── aws/               # AWS integration
│   ├── config/            # Configuration management
│   └── error/             # Error handling
├── tests/                 # Integration tests
├── packaging/             # Package configurations
├── scripts/               # Build and release scripts
├── .github/workflows/     # CI/CD automation
└── memory-bank/           # Documentation
```

## Testing Strategy
```bash
# Unit tests (fast)
cargo test --lib

# Integration tests
cargo test --test integration

# Test specific feature
cargo test assume

# Test with output
cargo test -- --nocapture
```

## IDE Setup (VS Code)
Essential extensions:
- **rust-analyzer**: Rust language support
- **CodeLLDB**: Debugging support
- **crates**: Dependency management

## Troubleshooting
**Build Issues**: Run `cargo clean && cargo build`
**Test Failures**: Ensure AWS CLI is configured with valid credentials
**Cross-compilation**: Install required targets with `rustup target add <target>`

## Release Process
1. Update version in `Cargo.toml`
2. Run `./scripts/release.sh version <version>` to sync all package versions
3. Build releases with `./build-releases.sh`
4. Test on multiple platforms
5. Create GitHub release (triggers automated package publishing) 