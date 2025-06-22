# 🚀 AWS Assume Role CLI v1.3.0 Release Notes

**Release Date**: December 2024  
**Focus**: Cross-Platform Build Infrastructure & Universal Shell Integration

## 🎯 Overview

This release establishes a robust cross-compilation infrastructure and introduces a universal shell integration approach. We've implemented comprehensive toolchain setup for consistent cross-platform builds and streamlined the shell integration from multiple wrapper scripts to a single universal bash wrapper that works across all supported platforms.

## ✨ New Features

### Cross-Compilation Infrastructure
- **Complete Toolchain Setup**: Full cross-compilation support with musl-cross, mingw-w64, and cmake
- **Static Linux Builds**: Using musl target (`x86_64-unknown-linux-musl`) for maximum compatibility
- **Automated Cross-Platform Builds**: Consistent build process for Linux, macOS, and Windows
- **Proper Linker Configuration**: `.cargo/config.toml` with environment variables for cross-compilation

### Universal Shell Integration
- **Single Bash Wrapper**: Consolidated from multiple shell-specific scripts to one universal wrapper
- **Cross-Platform Detection**: Auto-detects Linux, macOS (Darwin), and Windows Git Bash environments
- **Intelligent Binary Discovery**: Finds appropriate platform binary with fallback to installed versions
- **Role Assumption Integration**: Built-in `eval` with `--format export` for seamless credential setting

### Enhanced Build Automation
- **Comprehensive Release Script**: `scripts/release.sh` handles complete lifecycle (507 lines)
- **Distribution Packaging**: Automated creation of tar.gz and zip archives with checksums
- **Universal Installation**: `scripts/install.sh` supports both development and distribution modes (355 lines)

## 🔧 Bug Fixes

### Code Quality
- **Fixed Clippy Warning**: Replaced deprecated `.last()` with `.next_back()` for better performance
- **Cross-Platform Environment Variables**: Proper handling of both HOME and USERPROFILE

## 🏗️ Improvements

### Build Infrastructure
- **Enhanced Cargo Configuration**: Complete `.cargo/config.toml` with cross-compilation linkers
- **Static Linking**: Musl builds for better Linux distribution compatibility
- **Toolchain Validation**: Automated checks for required cross-compilation tools

### Developer Experience
- **Expanded Test Suite**: 79 comprehensive tests (23 unit + 14 integration + 19 shell + 23 additional)
- **Updated Shell Integration Tests**: Reflect universal wrapper approach instead of multi-shell
- **Automated Quality Gates**: Built-in cargo fmt, clippy, and test validation

### Distribution Simplification
- **Universal Wrapper Approach**: Single `aws-assume-role-bash.sh` replaces multiple shell scripts
- **Streamlined Releases**: Automation-managed releases directory
- **Consistent User Experience**: Same functionality across all platforms and shells

## 📋 Technical Details

### Cross-Compilation Targets
- **Linux**: `x86_64-unknown-linux-musl` (static linking for maximum compatibility)
- **macOS**: `aarch64-apple-darwin` (Apple Silicon optimized)
- **Windows**: `x86_64-pc-windows-gnu` (MinGW cross-compilation)

### Universal Wrapper Features
- **Platform Detection**: `uname -s` based detection for Linux, Darwin, MINGW/MSYS/CYGWIN
- **Binary Discovery**: Local files first, then PATH fallback
- **Error Handling**: Clear messages for unsupported OS or missing binaries
- **Convenience Alias**: `awsr` alias for easy usage
- **Usage Information**: Built-in help and confirmation messages

### Test Coverage Enhancement
- **Total Tests**: 79 tests (expanded from 59)
- **Shell Integration**: 19 tests validating universal wrapper functionality
- **Cross-Platform Validation**: All platforms tested with real toolchain
- **100% Pass Rate**: All tests passing across all platforms

## 🚀 Migration Guide

### For Existing Users
- **No Action Required**: Universal wrapper maintains backward compatibility
- **Shell Integration**: Continue using `source aws-assume-role-bash.sh` and `awsr` alias
- **All Commands**: Existing commands work exactly the same

### For Developers
- **Cross-Compilation Setup**: Install toolchain with `brew install musl-cross mingw-w64 cmake`
- **Rust Targets**: Add targets with `rustup target add x86_64-unknown-linux-musl x86_64-pc-windows-gnu`
- **Build Process**: Use `./scripts/build-releases.sh` for cross-platform builds

## 📥 Installation

### Package Managers
```bash
# Cargo
cargo install aws-assume-role

# Homebrew (macOS/Linux)
brew tap holdennguyen/tap
brew install aws-assume-role
```

### Direct Download
Download platform-specific binaries from the [releases page](https://github.com/holdennguyen/aws-assume-role/releases/tag/v1.3.0).

### Universal Wrapper Usage
```bash
# Source the universal wrapper
source ./aws-assume-role-bash.sh

# Use the convenient alias
awsr assume dev
awsr list
awsr --version
```

## 🎉 What's Next (v1.4.0)

- Enhanced configuration management features
- Additional output format options
- Performance optimizations for large role sets
- Extended platform support validation

## 🙏 Acknowledgments

Special thanks to the Rust cross-compilation community for toolchain guidance and comprehensive testing across all supported platforms. The universal wrapper approach significantly simplifies maintenance while providing consistent user experience.

---

**Full Changelog**: [v1.2.1...v1.3.0](https://github.com/holdennguyen/aws-assume-role/compare/v1.2.1...v1.3.0)

<!-- 
CHECKLIST - Remove before publishing:
□ Update all {PLACEHOLDERS} with actual values
□ Remove empty sections
□ Verify all links work
□ Test installation commands
□ Check changelog link is correct
□ Proofread for typos and clarity
--> 