# 🚀 AWS Assume Role CLI v1.3.1 Release Notes

**Release Date**: June 24, 2025  
**Focus**: Installation Script Fixes & Quality Improvements

## 🎯 Overview

Version 1.3.1 addresses a critical installation script issue that caused unnecessary error messages when installing to the current directory. This maintenance release improves the user experience during installation while maintaining all the robust functionality and cross-platform compatibility established in v1.3.0.

## ✨ New Features
<!-- No new features in this maintenance release -->

## 🔧 Bug Fixes

### Installation Scripts
- **Fixed INSTALL.sh Copy Error**: Resolved unnecessary `cp` error messages when installing to the same directory as the distribution files
- **Enhanced File Copy Logic**: Added intelligent checks to prevent copying files to identical locations
- **Improved User Experience**: Eliminated confusing error messages during installation process

### Development Workflow
- **Streamlined Quality Gates**: Enhanced error handling in development CLI to prevent similar issues
- **Better Error Reporting**: Improved feedback when source and destination paths are identical

## 🏗️ Improvements

### Installation Experience
- **Smarter File Operations**: Installation script now detects when source and destination are the same
- **Cleaner Output**: Removed unnecessary error messages that could confuse users
- **Better User Guidance**: Enhanced installation flow with clearer success indicators

## ⚠️ Breaking Changes
<!-- No breaking changes in this release -->

## 🔒 Security
<!-- No security updates in this release -->

## 📋 Technical Details

### Dependencies Updated
- All dependencies remain at current stable versions
- No dependency changes in this maintenance release

### Test Coverage
- **Total Tests**: 60 tests (23 unit + 14 integration + 23 additional)
- **Platforms**: Ubuntu ✅ | Windows ✅ | macOS ✅
- **Installation Testing**: Enhanced validation of installation script behavior

### Installation Script Fix Details
```bash
# Enhanced file copy logic in INSTALL.sh
if [[ "$SOURCE_DIR/$BINARY_NAME" != "$INSTALL_DIR/$target_name" ]]; then
    log_info "Installing binary: $BINARY_NAME → $target_name"
    $copy_cmd "$SOURCE_DIR/$BINARY_NAME" "$INSTALL_DIR/$target_name"
    # ... chmod operations
else
    log_info "Binary already in target location, skipping copy"
    chmod +x "$INSTALL_DIR/$target_name"
fi

# Similar logic for bash wrapper
if [[ "$SOURCE_DIR/aws-assume-role-bash.sh" != "$INSTALL_DIR/aws-assume-role-bash.sh" ]]; then
    $copy_cmd "$SOURCE_DIR/aws-assume-role-bash.sh" "$INSTALL_DIR/"
    # ... chmod operations
else
    log_info "Bash wrapper already in target location, skipping copy"
    chmod +x "$INSTALL_DIR/aws-assume-role-bash.sh"
fi
```


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
Download the .zip package for v1.3.1:

```bash
curl -L https://github.com/holdennguyen/aws-assume-role/releases/download/v1.3.1/aws-assume-role-cli-v1.3.1.zip -o aws-assume-role-cli-v1.3.1.zip
unzip aws-assume-role-cli-v1.3.1.zip && cd aws-assume-role-cli-v1.3.1
./INSTALL.sh
```

## 🙏 Acknowledgments

Thank you to the users who reported the installation script issue and the development community for maintaining high quality standards. This maintenance release ensures a smoother installation experience for all users.

---

**Full Changelog**: [v1.3.0...v1.3.1](https://github.com/holdennguyen/aws-assume-role/compare/v1.3.0...v1.3.1)

<!-- 
CHECKLIST - Remove before publishing:
□ Update all {PLACEHOLDERS} with actual values
□ Remove empty sections
□ Verify all links work
□ Test installation commands
□ Check changelog link is correct
□ Proofread for typos and clarity
--> 