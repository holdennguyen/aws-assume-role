# Package Manager Distribution Guide

This directory contains configuration files and scripts for distributing AWS Assume Role CLI through popular package managers across different operating systems.

## 📦 Supported Package Managers

### 🍺 Homebrew (macOS/Linux)
**Installation**: `brew install holdennguyen/tap/aws-assume-role`

**Files**:
- `homebrew/aws-assume-role.rb` - Homebrew formula
- Automatically creates `awsr` wrapper with shell integration

**Setup**:
1. Create a Homebrew tap repository: `homebrew-tap`
2. Add the formula file to the tap
3. Users can install with: `brew install holdennguyen/tap/aws-assume-role`

### 🍫 Chocolatey (Windows)
**Installation**: `choco install aws-assume-role`

**Files**:
- `chocolatey/aws-assume-role.nuspec` - Package specification
- `chocolatey/tools/chocolateyinstall.ps1` - Installation script
- `chocolatey/tools/chocolateyuninstall.ps1` - Uninstallation script

**Features**:
- PowerShell module integration
- Automatic shell profile configuration
- Helper functions (Clear-AwsCredentials, Get-AwsWhoAmI)

### 📦 APT (Debian/Ubuntu)
**Installation**: `sudo apt install aws-assume-role`

**Files**:
- `apt/DEBIAN/control` - Package metadata
- `apt/DEBIAN/postinst` - Post-installation script
- `apt/DEBIAN/prerm` - Pre-removal script

**Features**:
- Creates `awsr` wrapper script
- Shell helper functions
- Automatic integration setup

### 📦 RPM (RedHat/CentOS/Fedora)
**Installation**: `sudo dnf install aws-assume-role`

**Files**:
- `rpm/aws-assume-role.spec` - RPM specification

**Features**:
- System-wide installation
- Shell integration scripts
- Helper functions

### 🏗️ AUR (Arch Linux)
**Installation**: `yay -S aws-assume-role`

**Files**:
- `aur/PKGBUILD` - Build script
- `aur/.SRCINFO` - Package metadata

**Features**:
- Builds from source
- Automatic dependency management
- Shell integration

### 🦀 Cargo (Rust)
**Installation**: `cargo install aws-assume-role`

**Files**:
- `../Cargo.toml` - Updated for crates.io publication

**Features**:
- Cross-platform installation
- Automatic dependency resolution
- Latest Rust toolchain support

## 🚀 Quick Setup Guide

### For Maintainers

1. **Build packages locally**:
   ```bash
   ./packaging/build-packages.sh
   ```

2. **Test packages**:
   - Test on target operating systems
   - Verify installation and uninstallation
   - Check shell integration

3. **Update checksums**:
   - Update SHA256 checksums in package configs
   - Verify binary integrity

4. **Submit to repositories**:
   - Follow each package manager's submission process
   - Update documentation with installation commands

### For Automated CI/CD

The GitHub Actions workflow (`.github/workflows/release.yml`) automatically:
- Builds cross-platform binaries
- Creates packages for all supported managers
- Uploads to GitHub releases
- Publishes to crates.io (with token)

## 📋 Installation Commands Summary

Once published, users can install using:

```bash
# Homebrew (macOS/Linux)
brew install holdennguyen/tap/aws-assume-role

# Chocolatey (Windows)
choco install aws-assume-role

# APT (Debian/Ubuntu)
sudo apt update && sudo apt install aws-assume-role

# DNF (Fedora)
sudo dnf install aws-assume-role

# YUM (CentOS/RHEL)
sudo yum install aws-assume-role

# AUR (Arch Linux)
yay -S aws-assume-role

# Cargo (Any platform with Rust)
cargo install aws-assume-role

# NPM (Node.js - future)
npm install -g aws-assume-role
```

## 🔧 Package Features

All packages include:

### Core Features
- ✅ Cross-platform binary installation
- ✅ `awsr` wrapper command for easy use
- ✅ Shell integration (automatically sets credentials)
- ✅ Helper functions (`clear_aws_creds`, `aws_whoami`)
- ✅ Automatic dependency management (AWS CLI)

### Shell Integration
- **Bash/Zsh**: Source helper script automatically
- **Fish**: Fish-specific integration
- **PowerShell**: Module-based integration
- **Command Prompt**: Batch file wrapper

### User Experience
- **Simple commands**: `awsr assume role-name`
- **Automatic setup**: Credentials set in current shell
- **Clear feedback**: Success/error messages with emojis
- **Easy cleanup**: Uninstall preserves user configurations

## 🔍 Testing Packages

### Test Matrix
Test each package on:
- [ ] Fresh system installation
- [ ] Existing AWS CLI installation
- [ ] Multiple shell environments
- [ ] Upgrade scenarios
- [ ] Uninstallation cleanup

### Test Commands
```bash
# Basic functionality
awsr --help
awsr configure --name test --role-arn arn:aws:iam::123:role/Test --account-id 123
awsr list
awsr assume test  # (will fail without proper AWS setup)
awsr remove test

# Shell integration
clear_aws_creds  # or Clear-AwsCredentials on PowerShell
aws_whoami       # or Get-AwsWhoAmI on PowerShell
```

## 📚 Submission Guidelines

### Homebrew
1. Fork the homebrew-core repository
2. Add formula to `Formula/aws-assume-role.rb`
3. Submit pull request

### Chocolatey
1. Create account on chocolatey.org
2. Upload .nupkg file
3. Submit for moderation

### APT/RPM
1. Submit to distribution repositories
2. Or host in your own repository
3. Provide installation instructions

### AUR
1. Create AUR account
2. Submit PKGBUILD and .SRCINFO
3. Maintain package updates

### Crates.io
1. Create crates.io account
2. Add API token to GitHub secrets
3. Automatic publishing via CI/CD

## 🔄 Update Process

When releasing a new version:

1. **Update version numbers** in all package configs
2. **Update checksums** for new binaries
3. **Test packages** on target systems
4. **Submit updates** to package repositories
5. **Update documentation** with new installation commands

## 🆘 Troubleshooting

### Common Issues
- **Missing dependencies**: Ensure AWS CLI is listed as dependency
- **Permission errors**: Use appropriate package manager privileges
- **Shell integration**: Verify wrapper scripts are executable
- **Path issues**: Ensure binaries are in system PATH

### Debug Steps
1. Check package installation logs
2. Verify binary permissions and location
3. Test shell integration manually
4. Check dependency installation

---

**Ready to distribute?** Run `./packaging/build-packages.sh` to build all packages locally! 