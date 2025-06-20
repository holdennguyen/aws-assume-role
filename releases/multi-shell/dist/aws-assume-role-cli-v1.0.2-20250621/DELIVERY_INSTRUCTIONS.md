# AWS Assume Role CLI Tool - Delivery Instructions

## 📦 Package Contents

This package contains the AWS Assume Role CLI tool with multi-shell support. The tool allows users to seamlessly assume AWS IAM roles directly in their current shell environment without requiring additional eval commands or script sourcing.

### Files Included

```
aws-assume-role-multi-shell/
├── README.md                      # Comprehensive user documentation
├── INSTALL.sh                     # Automated installation script (Unix/macOS/Git Bash)
├── INSTALL.ps1                    # Automated installation script (PowerShell/Windows)
├── aws-assume-role-macos          # Binary for macOS
├── aws-assume-role-unix           # Binary for Linux/Unix
├── aws-assume-role-bash.sh        # Bash/Zsh wrapper script
├── aws-assume-role-fish.fish      # Fish shell wrapper script
├── aws-assume-role-powershell.ps1 # PowerShell wrapper script
├── aws-assume-role-cmd.bat        # Command Prompt wrapper script
└── DELIVERY_INSTRUCTIONS.md       # This file
```

---

## 🎯 Target Audience

- **DevOps Engineers** managing multiple AWS accounts
- **Software Developers** working with AWS services
- **System Administrators** requiring role-based access
- **Security Engineers** implementing least-privilege access

**Supported Environments:**
- macOS (Intel/Apple Silicon)
- Linux (x86_64)
- Windows (PowerShell, Command Prompt)
- Git Bash on Windows
- All major shells: Bash, Zsh, Fish, PowerShell

---

## 🚀 Quick Distribution Guide

### Option 1: Automated Installation (Recommended)

**For Unix/Linux/macOS/Git Bash users:**
```bash
# Download the package, extract, then run:
./INSTALL.sh
```

**For Windows PowerShell users:**
```powershell
# Download the package, extract, then run:
.\INSTALL.ps1
```

### Option 2: Manual Installation

Users can follow the detailed instructions in `README.md` for manual setup specific to their shell environment.

---

## 📋 Prerequisites for End Users

1. **AWS CLI installed** and accessible in PATH
2. **Valid AWS credentials** configured (access keys, SSO, or IAM roles)
3. **Permissions** to assume the target IAM roles
4. **Shell environment** (Bash, Zsh, Fish, PowerShell, or Command Prompt)

---

## 🔧 Core Features

### Simple Usage Pattern
```bash
# Configure a role once
awsr configure --name "dev-role" --role-arn "arn:aws:iam::123456789012:role/DevRole" --account-id "123456789012"

# Assume role (credentials set directly in current shell)
awsr assume dev-role

# Work with AWS services using assumed role
aws s3 ls  # Uses assumed role credentials

# Clear credentials when done
clear_aws_creds  # Bash/Zsh/Fish
Clear-AwsCredentials  # PowerShell
```

### Key Benefits
- **No eval commands required** - credentials set directly in shell
- **Multi-shell support** - works across all major shell environments
- **Session isolation** - credentials only affect current shell
- **Temporary credentials** - automatic expiration for security
- **Cross-platform** - single tool works on macOS, Linux, Windows

---

## 📖 User Documentation

### Primary Documentation
- **`README.md`** - Complete installation and usage guide
- **Built-in help** - `awsr --help` for command reference

### Installation Scripts
- **`INSTALL.sh`** - Interactive installer for Unix-like systems
- **`INSTALL.ps1`** - Interactive installer for Windows PowerShell

---

## 🔒 Security Considerations

### For IT/Security Teams
- **No credential storage** - tool never stores AWS credentials
- **Temporary sessions** - assumed role credentials expire (default: 1 hour)
- **Local configuration** - role definitions stored in `~/.aws-assume-role/config.json`
- **Session isolation** - each shell session is independent
- **Audit trail** - AWS CloudTrail logs all role assumptions

### User Security Best Practices
- Regularly rotate base AWS credentials
- Use least-privilege IAM policies for assumable roles
- Clear credentials when switching contexts: `clear_aws_creds`
- Verify current identity: `aws sts get-caller-identity`

---

## 🎯 Distribution Methods

### Method 1: Direct File Distribution
1. Package all files in a zip/tar archive
2. Distribute via internal file sharing, email, or download portal
3. Include this `DELIVERY_INSTRUCTIONS.md` file
4. Users extract and run installation scripts

### Method 2: Internal Repository
1. Host files in internal Git repository or artifact store
2. Users clone/download and run installation scripts
3. Enables version control and updates

### Method 3: Package Manager (Advanced)
1. Create packages for Homebrew (macOS), APT/YUM (Linux), Chocolatey (Windows)
2. Users install via package manager
3. Requires additional packaging work but provides best user experience

---

## 🚨 Troubleshooting Guide for Users

### Common Issues and Solutions

**"awsr command not found"**
- Solution: Source the wrapper script: `source aws-assume-role-bash.sh`
- Or run installation script to add to shell profile

**"Role assumption failed"**
- Check base AWS credentials: `aws sts get-caller-identity`
- Verify role ARN and account ID are correct
- Ensure current identity has permission to assume target role

**"Permission denied" on binary**
- Make binary executable: `chmod +x aws-assume-role-*`

**PowerShell execution policy errors**
- Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

---

## 🔄 Update Process

### For Future Versions
1. Replace binary files with new versions
2. Update wrapper scripts if needed
3. Update README.md with new features/changes
4. Test installation scripts with new binaries
5. Redistribute package to users

### User Update Process
- Users can simply replace binary files and re-run installation scripts
- Configuration files (`~/.aws-assume-role/config.json`) are preserved

---

## 📞 Support Information

### For End Users
- **Documentation**: Refer to `README.md` for complete usage guide
- **Built-in Help**: Use `awsr --help` for command reference
- **Troubleshooting**: Check troubleshooting section in `README.md`

### For IT Support
- **Installation Issues**: Check file permissions and PATH configuration
- **AWS Issues**: Verify user has proper AWS credentials and role permissions
- **Shell Issues**: Ensure wrapper script is properly sourced

---

## ✅ Deployment Checklist

Before distributing to users:

- [ ] Test installation on target operating systems
- [ ] Verify all shell environments work correctly
- [ ] Test with actual AWS credentials and roles
- [ ] Review security implications with security team
- [ ] Prepare internal documentation/training materials
- [ ] Set up support process for user questions
- [ ] Plan update/maintenance process

---

## 🎉 Success Metrics

After deployment, expect:
- **Reduced complexity** in AWS role management
- **Improved developer productivity** with seamless role switching
- **Better security posture** through temporary credentials
- **Cross-platform consistency** in AWS tooling

---

## 📝 License and Distribution

This tool is designed for internal enterprise use. Ensure compliance with:
- Your organization's software distribution policies
- AWS service terms and conditions
- Any applicable security and compliance requirements

---

**Ready to deploy!** 🚀

Users can now enjoy seamless AWS role assumption across all their favorite shell environments. 