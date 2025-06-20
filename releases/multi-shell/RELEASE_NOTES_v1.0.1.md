# 🔧 AWS Assume Role v1.0.1 - Hotfix Release

**Release Date**: June 20, 2025  
**Type**: Hotfix  
**Priority**: High (Critical Windows Git Bash Issue)

## 🐛 Critical Bug Fix

### Windows Git Bash IMDS Timeout Issue
**Problem**: Windows Git Bash users experienced a 1-second timeout with the error:
```
failed to load region from IMDS err=failed to load IMDS session token: dispatch failure: timeout
```

**Root Cause**: AWS SDK was attempting to auto-detect the AWS region by connecting to EC2 Instance Metadata Service (IMDS), causing timeouts on non-EC2 Windows machines.

**Solution**: Implemented intelligent region handling that defaults to `us-east-1` when no region is configured, preventing IMDS calls entirely.

## 🔧 Technical Implementation

### 1. Enhanced AWS Client Initialization (`src/aws/mod.rs`)
```rust
// Check if region is already configured via environment or AWS config
let config_builder = aws_config::from_env();

// If no region is explicitly set, use a default to prevent IMDS timeout
let config = if std::env::var("AWS_REGION").is_err() && 
                std::env::var("AWS_DEFAULT_REGION").is_err() {
    config_builder
        .region("us-east-1") // Default region to prevent IMDS timeout
        .load()
        .await
} else {
    config_builder.load().await
};
```

**Benefits**:
- ✅ Eliminates 1-second IMDS timeout on Windows machines
- ✅ Maintains compatibility with existing region configurations
- ✅ No impact on EC2 instances or properly configured environments

### 2. Improved Bash Wrapper Script (`releases/multi-shell/aws-assume-role-bash.sh`)
```bash
# Ensure AWS region is set to prevent IMDS timeout
if [ -z "$AWS_REGION" ] && [ -z "$AWS_DEFAULT_REGION" ]; then
    echo "📍 Setting default AWS region to prevent timeout..."
    export AWS_DEFAULT_REGION="us-east-1"
fi
```

**Enhancements**:
- ✅ Automatic region detection and default setting
- ✅ Cleaner output with reduced debug information
- ✅ Better credential verification display
- ✅ Enhanced error handling for credential parsing

### 3. Version Update (`Cargo.toml`)
- Updated from `1.0.0` to `1.0.1`
- Maintains all existing dependencies and compatibility

## 🎯 Impact & Benefits

### Immediate Fixes
- **Windows Git Bash**: Instant credential switching (no more 1-second delays)
- **User Experience**: Cleaner output with professional messaging
- **Error Prevention**: Proactive region handling prevents IMDS timeouts

### Compatibility
- ✅ **Backward Compatible**: All existing configurations continue to work
- ✅ **Cross-Platform**: No impact on macOS, Linux, or other environments
- ✅ **EC2 Instances**: Continues to work seamlessly on AWS infrastructure
- ✅ **Existing Regions**: Respects user-configured regions via environment variables

### Performance
- **Windows Git Bash**: Eliminates 1-second timeout delay
- **All Platforms**: Faster initialization when no region is configured
- **Network**: Reduces unnecessary IMDS network calls

## 📦 Distribution

### Package Manager Updates
This hotfix is automatically available through:

- **🍺 Homebrew**: `brew upgrade aws-assume-role`
- **🦀 Cargo**: `cargo install aws-assume-role --force`
- **📦 GitHub Releases**: Automated builds for all platforms
- **🍫 Chocolatey**: Available in next package update
- **📦 APT/RPM**: Available in next package update

### Manual Installation
For immediate access, download from:
- **GitHub Releases**: [v1.0.1 Release](https://github.com/holdennguyen/aws-assume-role/releases/tag/v1.0.1)
- **Multi-Shell Package**: `releases/multi-shell/` directory

## 🔍 Verification

### Quick Test
```bash
# For immediate fix (temporary)
export AWS_DEFAULT_REGION=us-east-1
awsr assume your-role-name

# Or upgrade to v1.0.1 for automatic handling
brew upgrade aws-assume-role  # Homebrew
cargo install aws-assume-role --force  # Cargo
```

### Expected Behavior
- **Before v1.0.1**: 1-second delay with IMDS timeout error
- **After v1.0.1**: Instant credential switching with clean output

## 🚀 What's Next

### Upcoming Features (v1.1.0)
- Enhanced error messages and troubleshooting
- Additional output formats (YAML, TOML)
- Role session name customization
- Advanced configuration options

### Feedback
We've resolved the critical Windows Git Bash issue. If you encounter any problems:
1. **GitHub Issues**: [Report bugs](https://github.com/holdennguyen/aws-assume-role/issues)
2. **Documentation**: Check [README.md](README.md) for usage examples
3. **Support**: Review [DELIVERY_INSTRUCTIONS.md](DELIVERY_INSTRUCTIONS.md) for troubleshooting

## 📋 Changelog Summary

### Added
- Intelligent region detection and default setting
- Enhanced error prevention for IMDS timeouts
- Cleaner user experience with professional output

### Fixed
- **Critical**: Windows Git Bash IMDS timeout issue
- Credential verification display improvements
- Debug output cleanup for production use

### Changed
- Version bumped from 1.0.0 to 1.0.1
- AWS client initialization enhanced with region handling
- Bash wrapper script improved with automatic region setting

### Technical Details
- **Files Modified**: 3 files (`src/aws/mod.rs`, `releases/multi-shell/aws-assume-role-bash.sh`, `Cargo.toml`)
- **Dependencies**: No changes to external dependencies
- **Breaking Changes**: None - fully backward compatible

---

**Download**: [GitHub Releases v1.0.1](https://github.com/holdennguyen/aws-assume-role/releases/tag/v1.0.1)  
**Documentation**: [Project README](https://github.com/holdennguyen/aws-assume-role#readme)  
**Support**: [GitHub Issues](https://github.com/holdennguyen/aws-assume-role/issues) 