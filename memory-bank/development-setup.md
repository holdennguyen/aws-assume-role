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

# Development Setup & Guidelines

## Prerequisites
- Rust 1.70+ installed
- AWS CLI v2 configured
- Git configured with proper credentials
- Cross-compilation targets for release builds

## Development Workflow
1. Clone repository
2. Run `cargo build` to verify setup
3. Run `cargo test` to ensure tests pass
4. Make changes following coding standards
5. Test changes locally
6. Update version following semantic versioning rules
7. Create release following release process

## Testing
```bash
# Unit tests
cargo test

# Integration tests
cargo test --test integration

# Build for all platforms
./build-releases.sh
```

## Semantic Versioning Rules (v1.1.0+)

### Version Format: MAJOR.MINOR.PATCH

#### 🔴 MAJOR Version (X.0.0) - Breaking Changes
**When to use:**
- Remove or rename CLI commands
- Change command argument names or behavior
- Remove configuration file fields
- Change output format in incompatible ways
- Require higher minimum Rust version
- Change core API that breaks existing workflows

**Examples:**
- `awsr assume` → `awsr switch` (command rename)
- Remove `--format` option from assume command
- Change config file from JSON to YAML
- Require different AWS permissions

**Release Process:**
- Create migration guide
- Update major version in all packages
- Announce breaking changes prominently
- Provide backward compatibility period when possible

#### 🟡 MINOR Version (0.X.0) - New Features
**When to use:**
- Add new CLI commands
- Add new command options/flags
- Add new output formats (alongside existing)
- Add new configuration options
- Enhance existing functionality without breaking changes
- Add new AWS service integrations
- Improve error messages or help text

**Examples:**
- Add `verify` command (✅ v1.1.0)
- Add `--verbose` flag to existing commands
- Add `--exec` option to assume command
- Add new output format like `--format yaml`
- Add SSO integration
- Add role chaining support

**Release Process:**
- All existing functionality must work unchanged
- New features should be opt-in
- Update documentation with new features
- Test backward compatibility thoroughly

#### 🟢 PATCH Version (0.0.X) - Bug Fixes
**When to use:**
- Fix bugs without changing behavior
- Performance improvements
- Security fixes
- Documentation updates (non-functional)
- Dependency updates (compatible versions)
- Fix error handling
- Improve logging

**Examples:**
- Fix Windows Git Bash timeout issue (✅ v1.0.2)
- Fix credential parsing edge cases
- Improve error messages for clarity
- Update dependencies for security
- Fix memory leaks or performance issues

**Release Process:**
- No new functionality
- All existing tests must pass
- Focus on stability and reliability
- Quick release cycle for critical fixes

### 🏷️ Pre-release Versions
**Format:** `1.1.0-alpha.1`, `1.1.0-beta.2`, `1.1.0-rc.1`

**When to use:**
- Testing major changes before release
- Getting user feedback on new features
- Beta testing with select users
- Release candidates before production

### 📋 Version Decision Matrix

| Change Type | Examples | Version Bump |
|-------------|----------|--------------|
| New CLI command | `awsr backup`, `awsr validate` | MINOR |
| New command option | `--region`, `--mfa-code` | MINOR |
| Remove command | Remove `awsr list` | MAJOR |
| Change option name | `--name` → `--role-name` | MAJOR |
| Bug fix | Fix parsing error | PATCH |
| Performance improvement | Faster role switching | PATCH |
| Documentation update | README improvements | PATCH |
| New output format | Add `--format xml` | MINOR |
| Change default behavior | Change default duration | MAJOR |
| Add configuration field | Add `default_region` | MINOR |
| Remove configuration field | Remove `account_id` | MAJOR |

### 🔄 Release Automation Rules

#### Version Update Process
```bash
# Update version across all components
./scripts/update-version.sh 1.2.0

# Files automatically updated:
# - Cargo.toml
# - All package manager configs (Homebrew, Chocolatey, etc.)
# - GitHub Actions workflows
# - Documentation references
```

#### Git Tagging Strategy
```bash
# Create annotated tag with release notes
git tag -a v1.1.0 -m "Release v1.1.0: Prerequisites verification system"

# Push tag to trigger release automation
git push origin v1.1.0
```

#### Branch Strategy
- **master**: Production-ready code
- **develop**: Integration branch for new features
- **feature/***: Individual feature development
- **hotfix/***: Critical bug fixes
- **release/***: Release preparation

### 📊 Version History Tracking

#### Current Version: v1.1.0
**Type:** MINOR (New Features)
**Changes:**
- ✅ Added `verify` command for prerequisites checking
- ✅ Enhanced `configure` with automatic role testing
- ✅ Improved CLI help system with examples
- ✅ Documentation consolidation

#### Previous Versions:
- **v1.0.2** (PATCH): Windows Git Bash timeout fix + GitHub Packages
- **v1.0.1** (PATCH): Multi-shell distribution package
- **v1.0.0** (MAJOR): Initial production release

### 🎯 Future Version Planning

#### Planned v1.2.0 (MINOR) - SSO Integration
- Add `awsr sso login` command
- Add `--sso-profile` option to configure
- Add SSO token management
- Maintain backward compatibility

#### Planned v1.3.0 (MINOR) - Role Chaining
- Add `--source-role` option for role chaining
- Add `awsr chain` command for complex role paths
- Add configuration templates

#### Planned v2.0.0 (MAJOR) - Configuration Redesign
- Move from JSON to YAML configuration
- Restructure configuration file format
- Require AWS CLI v2.15+
- Remove deprecated options

### 🚨 Emergency Release Process

#### Hotfix Procedure (PATCH)
1. Create hotfix branch from master
2. Fix critical issue
3. Test thoroughly
4. Update patch version
5. Merge to master and develop
6. Tag and release immediately

#### Security Release Process
1. Assess security impact
2. Determine version bump (usually PATCH)
3. Coordinate with security team
4. Prepare security advisory
5. Release with security notes

### 📈 Success Metrics
- **Adoption Rate**: Downloads per version
- **Stability**: Issue reports per version
- **Compatibility**: Breaking change frequency
- **User Satisfaction**: Feedback and ratings

This semantic versioning system ensures predictable, professional releases while maintaining backward compatibility and clear communication with users about the impact of each update. 