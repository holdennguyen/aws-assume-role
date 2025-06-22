# 🛠️ Development Setup Guide

This document outlines the one-time setup and standard commands for developing the AWS Assume Role CLI.

## 🚀 One-Time Setup

### 1. Prerequisites
- **Rust**: Version 1.70 or newer.
- **Git**: For source control.
- **Homebrew** (macOS): For installing the cross-compilation toolchain.

### 2. Clone the Repository
```bash
git clone https://github.com/holdennguyen/aws-assume-role.git
cd aws-assume-role
```

### 3. Install Cross-Compilation Toolchain (Required for Release Builds)
This is a one-time setup to enable building for Linux and Windows from a macOS environment.
```bash
# Install required tools via Homebrew
brew install musl-cross mingw-w64 cmake

# Add the Rust target platforms
rustup target add x86_64-unknown-linux-musl
rustup target add x86_64-pc-windows-gnu
```
After this step, verify that the `.cargo/config.toml` file exists and is configured for the linkers.

## 🔄 Standard Development Commands

### ✅ The Only Command You Need for Quality Checks
For all local development—building, testing, formatting, and linting—use the standard pre-commit script. This is the same script the CI pipeline uses.

```bash
# Run all quality checks (format, clippy, test, build)
./scripts/pre-commit-hook.sh
```

### Building Release Binaries
To build the binaries for all target platforms (macOS, Linux, Windows), use the dedicated build script.

```bash
# Build binaries for all platforms
./scripts/build-releases.sh
```

The compiled binaries will be available in the `releases/` directory.

## 릴 Release Process
The release process is strictly defined by the **Safe Release Process**. All developers must follow the steps outlined in:
- `docs/DEVELOPER_WORKFLOW.md`

Attempting to release without following this workflow will be blocked by CI checks.

## 📂 Project Structure
```
aws-assume-role/
├── src/                    # Rust source code
│   ├── cli/               # Command-Line Interface logic
│   ├── aws/               # AWS integration using the Rust SDK
│   ├── config/            # Role configuration management
│   └── error/             # Error handling
├── tests/                 # Integration and shell integration tests
├── scripts/               # Build, release, and quality-gate scripts
├── .github/workflows/     # CI/CD automation pipeline (ci-cd.yml)
├── docs/                  # Project documentation (architecture, workflow)
└── memory-bank/           # Internal project memory and context
```

##  troubleshooting
**Build Issues**: Run `./scripts/pre-commit-hook.sh`. If it fails, it will provide guidance on how to fix the issue.
**Cross-compilation**: Ensure the toolchain is installed correctly as described in the one-time setup. Check that the required `rustup` targets are installed.
**CI Failures**: CI failures should not happen if the pre-commit script passes locally. If they do, it indicates a problem with the CI environment itself. 