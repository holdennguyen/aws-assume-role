# 🚀 Quick Deployment Guide

## For End Users

### 1. Download & Extract
- Download the appropriate package for your system
- Extract to a temporary location

### 2. Install
```bash
# Unix/Linux/macOS/Git Bash
./INSTALL.sh

# Windows PowerShell
.\INSTALL.ps1
```

### 3. Choose Installation Location
- **Recommended**: Option 3 (`~/.local/bin`) - User-specific installation
- **System-wide**: Option 2 (`/usr/local/bin`) - Requires sudo
- **Testing**: Option 1 (Current directory) - For testing only

### 4. Configure Shell
The installer will offer to add the wrapper to your shell profile automatically.

### 5. Test Installation
```bash
awsr list
awsr --help
```

### 6. 🧹 Cleanup
**If you chose Option 2 or 3**: You can safely delete the extracted folder!

```bash
cd .. && rm -rf aws-assume-role-cli-v1.0.0-*
```

**If you chose Option 1**: Keep the folder as it contains your installation.

## Quick Configuration

```bash
# Configure a role
awsr configure --name "dev-role" \
  --role-arn "arn:aws:iam::123456789012:role/DeveloperRole" \
  --account-id "123456789012"

# Assume role
awsr assume dev-role

# Verify
aws sts get-caller-identity
```

## Troubleshooting

### Common Issues
- **Permission errors**: Use Option 3 (`~/.local/bin`)
- **Command not found**: Restart shell or source config file
- **Git Bash issues**: Installer handles format conversion automatically

### Debug Mode
```bash
RUST_LOG=debug awsr assume <role-name>
```

---

**🎉 Ready to use AWS Assume Role CLI!**

---

## 📋 Prerequisites

- AWS CLI installed
- Valid AWS credentials configured
- Permission to assume target roles

---

## 🆘 Quick Troubleshooting

**"awsr command not found"**
```bash
source aws-assume-role-bash.sh  # Load the wrapper
```

**"Role assumption failed"**
```bash
aws sts get-caller-identity  # Check your base credentials work
```

---

## 📚 Full Documentation

- **README.md** - Complete installation and usage guide
- **DELIVERY_INSTRUCTIONS.md** - IT deployment guide
- **Built-in help**: `awsr --help`

---

## ✨ Key Features

- ✅ **Direct shell integration** - no eval required
- ✅ **Multi-shell support** - Bash, Zsh, Fish, PowerShell
- ✅ **Cross-platform** - macOS, Linux, Windows
- ✅ **Secure** - temporary credentials, no storage
- ✅ **Simple** - one command to assume roles

**Ready to distribute!** Share this package with your users and they'll be assuming roles effortlessly across all their shell environments. 🚀 