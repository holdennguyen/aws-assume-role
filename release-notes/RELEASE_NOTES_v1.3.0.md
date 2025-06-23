# 🚀 AWS Assume Role CLI v1.3.0 Release Notes

**Release Date**: June 24, 2025  
**Focus**: Developer Experience & Critical Windows Compatibility

## 🎯 Overview

Version 1.3.0 introduces a unified developer experience with streamlined tooling, enhanced installation scripts, and **critical Windows Git Bash compatibility fixes**. This release resolves a major compatibility issue that prevented proper credential export on Windows Git Bash while maintaining the robust security and reliability established in previous versions.

## ✨ New Features

### Developer Experience
- **Unified Developer CLI**: Single `./dev-cli.sh` script for all development tasks
- **Local Distribution Testing**: `./dev-cli.sh package <version>` for end-to-end testing
- **Simplified Release Process**: Streamlined release preparation with `./dev-cli.sh release <version>`

### Installation & Distribution
- **Enhanced Installer Script**: Improved `INSTALL.sh` with step-by-step guidance and better user experience
- **Professional Uninstaller**: Comprehensive `UNINSTALL.sh` with clear cleanup instructions
- **Cross-Platform Build System**: Complete cross-compilation toolchain for Linux (musl), macOS, and Windows

## 🔧 Bug Fixes

### Windows Git Bash Compatibility
- **Fixed Credential Export Issue**: Resolved critical compatibility problem preventing proper credential export in Git Bash on Windows
- **Enhanced Shell Detection**: Improved platform detection logic for MINGW/MSYS/CYGWIN environments
- **Universal Wrapper Fix**: Updated `aws-assume-role-bash.sh` to properly handle Windows Git Bash credential export
- **Cross-Platform Testing**: Added comprehensive Windows Git Bash testing to prevent regression

### Installation & Uninstallation
- **Fixed Uninstaller Logic**: Improved file removal and user guidance in `UNINSTALL.sh`
- **Enhanced Error Handling**: Better permission checking and user feedback in installation scripts
- **Updated Test Coverage**: Fixed shell integration tests to match new script behavior

### Development Workflow
- **Streamlined Release Process**: Removed redundant "prepare" subcommand for cleaner workflow
- **Improved Quality Gates**: Enhanced pre-commit checks with better error reporting

## 🏗️ Improvements

### Developer Tooling
- **Unified Interface**: Single `./dev-cli.sh` script replaces multiple development commands
- **Enhanced Documentation**: Updated `DEVELOPER_WORKFLOW.md` with correct Git Flow patterns
- **Local Testing**: Added `./dev-cli.sh package <version>` for complete distribution testing

### Installation Experience
- **Professional Scripts**: Enhanced `INSTALL.sh` and `UNINSTALL.sh` with color-coded output and step-by-step guidance
- **Better User Guidance**: Clear instructions for shell profile management and cleanup
- **Cross-Platform Compatibility**: Improved support for bash, zsh, and Git Bash on Windows

### Build System
- **Cross-Compilation Infrastructure**: Complete toolchain setup for consistent builds across platforms
- **Static Linux Builds**: Using musl for maximum distribution compatibility
- **Native macOS Builds**: Optimized for Apple Silicon (M1/M2/M3)
- **Windows MinGW**: Cross-compiled from macOS for consistent build environment

## ⚠️ Breaking Changes
<!-- No breaking changes in this release -->

## 🔒 Security
<!-- No security updates in this release -->

## 📋 Technical Details

### Dependencies Updated
- All dependencies remain at current stable versions
- AWS SDK v1.x maintained for security and performance

### Test Coverage
- **Total Tests**: 79 tests (23 unit + 14 integration + 19 shell + 23 additional)
- **Platforms**: Ubuntu ✅ | Windows ✅ | macOS ✅
- **Shell Integration**: Enhanced tests for universal wrapper and installation scripts
- **Windows Git Bash**: Comprehensive testing for MINGW/MSYS/CYGWIN environments

### Build Infrastructure
- **Cross-Compilation**: musl-cross, mingw-w64, cmake toolchain
- **Rust Targets**: x86_64-unknown-linux-musl, x86_64-pc-windows-gnu
- **Universal Wrapper**: Single bash script for all platforms with enhanced Windows support

### Windows Compatibility Fix Details
```bash
# Enhanced platform detection in universal wrapper
case "$(uname -s)" in
    Linux*)   os_type="linux" ;;
    Darwin*)  os_type="macos" ;;
    MINGW*|MSYS*|CYGWIN*) os_type="windows" ;;  # Fixed Windows detection
    *)        echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

# Proper credential export handling for Windows Git Bash
if [ "$1" = "assume" ]; then
    local output
    if output=$("$binary_path" "$@" --format export); then
        eval "$output"  # Fixed credential application
    else
        echo "$output" >&2
        return 1
    fi
fi
```

## 🎉 What's Next

### Next Release Planning
- Enhanced error messaging and user feedback
- Additional shell integration options
- Performance optimizations and benchmarking

### Future Enhancements
- MFA support integration
- Enhanced SSO compatibility
- Advanced session management features

## 📥 Installation

### Package Managers
```bash
# Cargo
cargo install aws-assume-role

# Homebrew (macOS/Linux)
brew tap holdennguyen/tap
brew install aws-assume-role
```

### Universal Installer
Download the .zip package for v1.3.0:

```bash
curl -L https://github.com/holdennguyen/aws-assume-role/releases/download/v1.3.0/aws-assume-role-cli-v1.3.0.zip -o aws-assume-role-cli-v1.3.0.zip
unzip aws-assume-role-cli-v1.3.0.zip && cd aws-assume-role-cli-v1.3.0
./INSTALL.sh
```

## 🙏 Acknowledgments

Special thanks to the Windows Git Bash users who reported the compatibility issues and the development community for feedback on the installation experience. The comprehensive testing framework ensures reliable cross-platform compatibility.

---

**Full Changelog**: [v1.2.0...v1.3.0](https://github.com/holdennguyen/aws-assume-role/compare/v1.2.0...v1.3.0)

<!-- 
CHECKLIST - Remove before publishing:
□ Update all {PLACEHOLDERS} with actual values
□ Remove empty sections
□ Verify all links work
□ Test installation commands
□ Check changelog link is correct
□ Proofread for typos and clarity
--> 