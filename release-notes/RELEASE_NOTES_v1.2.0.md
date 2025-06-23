# 🚀 AWS Assume Role CLI v1.2.0 Release Notes

**Release Date**: June 22, 2025  
**Focus**: Windows Compatibility & CI/CD Reliability

## 🎯 Overview

Version 1.2.0 is a critical stability release that resolves Windows compatibility issues in our CI/CD pipeline and enhances cross-platform reliability. This release ensures consistent behavior across all supported platforms (Ubuntu, Windows, macOS) with comprehensive test coverage.

## 🔧 Critical Fixes

### Windows Compatibility Resolution
- **Fixed Windows CI/CD Pipeline**: Resolved all Windows test failures in GitHub Actions
- **Environment Variable Handling**: Enhanced `get_config_path()` to properly handle `USERPROFILE` on Windows
- **Cross-Platform Testing**: Added Windows-specific environment variable support in integration tests
- **Test Isolation**: Improved test isolation with proper environment variable restoration

### Code Quality & Testing
- **Clippy Compliance**: Resolved all clippy warnings with `-D warnings` policy
- **Formatting Consistency**: Applied comprehensive `cargo fmt` across all code
- **Test Coverage**: All 59 tests now pass consistently across all platforms
  - 23 Unit Tests ✅
  - 14 Integration Tests ✅  
  - 22 Shell Integration Tests ✅

## 🧪 Testing Improvements

### Enhanced Test Framework
- **Serial Test Execution**: Added `#[serial_test::serial]` for environment-dependent tests
- **Environment Variable Testing**: Robust cross-platform environment variable handling
- **Test Utilities**: Improved test isolation and cleanup procedures
- **CI/CD Reliability**: Zero-flake test execution across all platforms

### Cross-Platform Validation
- **Ubuntu**: All tests passing ✅
- **Windows**: All tests passing ✅ (Fixed in this release)
- **macOS**: All tests passing ✅

## 🏗️ Architecture Enhancements

### Configuration Management
```rust
// Enhanced cross-platform home directory detection
fn get_config_path() -> AppResult<PathBuf> {
    // Check environment variables first for cross-platform compatibility
    if let Ok(home_path) = std::env::var("HOME") {
        return Ok(PathBuf::from(home_path)
            .join(".aws-assume-role")
            .join("config.json"));
    }
    
    #[cfg(windows)]
    if let Ok(userprofile_path) = std::env::var("USERPROFILE") {
        return Ok(PathBuf::from(userprofile_path)
            .join(".aws-assume-role")
            .join("config.json"));
    }
    
    // Fallback to dirs::home_dir() for standard behavior
    let home_dir = dirs::home_dir()
        .ok_or_else(|| AppError::ConfigError("Could not find home directory".to_string()))?;

    Ok(home_dir.join(".aws-assume-role").join("config.json"))
}
```

### Integration Test Improvements
- **Environment Setup**: Consistent environment variable setup across all integration tests
- **Windows Support**: Added `USERPROFILE` environment variable support for Windows tests
- **Test Reliability**: Enhanced test isolation and cleanup procedures

## 📦 Distribution Updates

### Multi-Shell Release Binaries (Updated)
- ✅ **macOS Binary**: `aws-assume-role-macos` - Updated with latest fixes
- ✅ **Unix/Linux Binary**: `aws-assume-role-unix` - Updated with latest fixes
- ⚠️ **Windows Binary**: `aws-assume-role.exe` - Requires cross-compilation update

### Installation Scripts
- All installation and uninstallation scripts remain compatible
- Enhanced error handling and cross-platform support

## 🔒 Security & Dependencies

### Maintained Security Posture
- **AWS SDK v1.x**: Continues with modern AWS SDK (v1.75.0/v1.73.0)
- **Cryptographic Backend**: `aws-lc-rs` for secure cryptographic operations
- **Clean Security Audit**: No known vulnerabilities
- **Modern Dependencies**: All dependencies up-to-date

## 🚀 Performance & Reliability

### CI/CD Pipeline
- **Zero-Failure Testing**: All platforms now pass consistently
- **Automated Quality Gates**: Formatting, linting, and testing automated
- **Cross-Platform Builds**: Reliable builds across Ubuntu, Windows, macOS

### Development Workflow
- **Git Flow**: Proper branching strategy maintained
- **Code Quality**: Comprehensive linting and formatting enforcement
- **Documentation**: Enhanced development guides and testing documentation

## 📋 Technical Details

### Test Matrix
| Platform | Unit Tests | Integration Tests | Shell Tests | Status |
|----------|------------|-------------------|-------------|---------|
| Ubuntu   | 23/23 ✅   | 14/14 ✅          | 22/22 ✅    | PASS ✅  |
| Windows  | 23/23 ✅   | 14/14 ✅          | 22/22 ✅    | PASS ✅  |
| macOS    | 23/23 ✅   | 14/14 ✅          | 22/22 ✅    | PASS ✅  |

### Fixed Issues
- Windows `test_config_path` failure ✅
- Windows integration test failures ✅
- CI/CD formatting failures ✅
- Clippy warnings with `-D warnings` ✅

## 🎉 What's Next

### v1.2.1 Planning
- Cross-compilation setup for Windows binaries
- Enhanced error messaging
- Performance optimizations

### Future Enhancements
- MFA support integration
- Enhanced SSO compatibility
- Advanced session management

## 📥 Installation

### Package Managers
```bash
# Cargo
cargo install aws-assume-role

# Homebrew (macOS/Linux)
brew tap holdennguyen/tap
brew install aws-assume-role

# APT (Ubuntu/Debian)
sudo add-apt-repository ppa:holdennguyen/aws-assume-role
sudo apt install aws-assume-role
```

### Direct Download
Download platform-specific binaries from the [releases page](https://github.com/holdennguyen/aws-assume-role/releases/tag/v1.2.0).

## 🙏 Acknowledgments

Special thanks to the comprehensive testing framework that caught these cross-platform issues early and enabled confident resolution.

---

**Full Changelog**: [v1.1.2...v1.2.0](https://github.com/holdennguyen/aws-assume-role/compare/v1.1.2...v1.2.0) 