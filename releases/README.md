# AWS Assume Role CLI - Distribution Package

This directory contains the distribution package for AWS Assume Role CLI v1.3.0.

## 🚀 Quick Installation

### Universal Installation (Recommended)
```bash
# Run the installer
./INSTALL.sh

# Follow the prompts to choose installation directory
# The installer will automatically detect your platform
```

### Manual Installation
```bash
# Copy the appropriate binary for your platform:
# Linux (x86_64): aws-assume-role-linux
# macOS (Apple Silicon): aws-assume-role-macos  
# Windows (Git Bash): aws-assume-role-windows.exe

# Make executable and add to PATH
chmod +x aws-assume-role-*
sudo cp aws-assume-role-* /usr/local/bin/aws-assume-role
```

## 📦 Package Contents

- **Platform-specific binaries**: Optimized for Linux, macOS, and Windows
- **Universal wrapper script**: `aws-assume-role-bash.sh` works across all platforms
- **Installation scripts**: `INSTALL.sh` and `UNINSTALL.sh` for easy management
- **Documentation**: This README and usage instructions

## 🎯 Usage

### Shell Integration (Recommended)
```bash
# Source the universal wrapper
source aws-assume-role-bash.sh

# Use the convenient alias
awsr assume my-role-name
awsr list
awsr configure --name dev --role-arn arn:aws:iam::123456789012:role/DevRole
```

### Direct Binary Usage
```bash
# Direct execution
./aws-assume-role-macos assume my-role-name --format export
eval $(./aws-assume-role-macos assume my-role-name --format export)
```

## 🔧 Supported Platforms

- **🐧 Linux** (x86_64) - Static musl binary for maximum compatibility
- **🍎 macOS** (Apple Silicon/aarch64) - Native ARM64 binary
- **🪟 Windows** (Git Bash/x86_64) - MinGW cross-compiled binary

## 📋 Requirements

- **Linux**: Any modern x86_64 Linux distribution
- **macOS**: macOS 11+ with Apple Silicon (M1/M2/M3)
- **Windows**: Git Bash, MSYS2, or similar Unix-like environment

## 🆘 Support

- **Documentation**: See the main repository for full documentation
- **Issues**: Report issues on GitHub
- **Configuration**: Run `aws-assume-role configure --help` for setup guidance

## 🔄 Uninstallation

```bash
# Use the uninstaller
./UNINSTALL.sh

# Or manually remove
rm -f ~/.local/bin/aws-assume-role  # or /usr/local/bin/aws-assume-role
```

---

**AWS Assume Role CLI v1.3.0** - Cross-platform AWS role assumption made simple. 