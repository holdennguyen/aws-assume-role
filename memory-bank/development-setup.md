# Development Environment Setup Guide

## Prerequisites

### Required Tools
1. Rust Development Tools
   - Rustup (Rust toolchain manager)
   - Cargo (Rust package manager)
   - Latest stable Rust version

2. AWS Development Tools
   - AWS CLI (for testing)
   - AWS account with SSO access

3. Development Tools
   - Git
   - A code editor (VS Code recommended with rust-analyzer extension)
   - Terminal application

## Installation Steps

### 1. Install Rust
```bash
# Install rustup (Rust toolchain manager)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Verify installation
rustc --version
cargo --version

# Update to latest stable version
rustup update stable
```

### 2. Install AWS CLI
```bash
# For macOS (using Homebrew)
brew install awscli

# Verify installation
aws --version
```

### 3. IDE Setup
1. Install Visual Studio Code
   - Download from: https://code.visualstudio.com/

2. Install VS Code Extensions
   - rust-analyzer (Rust language support)
   - crates (Rust dependency management)
   - CodeLLDB (Debugger)
   - Even Better TOML (TOML file support)

### 4. Project Setup
```bash
# Create new Rust project
cargo new aws-assume-role
cd aws-assume-role

# Initialize git repository (if not already done)
git init

# Add .gitignore
echo "target/" > .gitignore
echo "**/*.rs.bk" >> .gitignore
echo ".env" >> .gitignore
```

## Project Structure
```
aws-assume-role/
├── src/
│   ├── main.rs
│   ├── cli/
│   ├── aws/
│   ├── config/
│   └── error/
├── tests/
├── Cargo.toml
├── Cargo.lock
└── README.md
```

## Configuration

### 1. Cargo.toml Setup
Essential dependencies:
```toml
[package]
name = "aws-assume-role"
version = "0.1.0"
edition = "2021"

[dependencies]
aws-config = "1.0"
aws-sdk-sts = "1.0"
aws-sdk-sso = "1.0"
tokio = { version = "1.0", features = ["full"] }
clap = { version = "4.0", features = ["derive"] }
anyhow = "1.0"
tracing = "0.1"
tracing-subscriber = "0.3"
```

### 2. AWS Configuration
```bash
# Configure AWS CLI (if not already done)
aws configure sso
```

## Development Workflow

### 1. Building the Project
```bash
# Build debug version
cargo build

# Build release version
cargo build --release
```

### 2. Running Tests
```bash
# Run all tests
cargo test

# Run specific test
cargo test test_name
```

### 3. Code Formatting
```bash
# Format code
cargo fmt

# Check formatting
cargo fmt -- --check
```

### 4. Code Linting
```bash
# Run clippy linter
cargo clippy
```

## Troubleshooting

### Common Issues
1. Rust Installation Issues
   - Ensure PATH is correctly set
   - Try restarting terminal after installation

2. AWS CLI Configuration
   - Verify AWS credentials
   - Check SSO session status

3. Build Issues
   - Clean build: `cargo clean`
   - Update dependencies: `cargo update`

## Next Steps
After setting up the development environment:
1. Verify all tools are working
2. Create initial project structure
3. Configure AWS SDK
4. Start implementing core functionality 