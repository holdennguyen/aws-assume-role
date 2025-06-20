# AWS Assume Role - Deployment Guide

This guide covers how to deploy and distribute the AWS Assume Role CLI application.

## 📦 Current Distribution

The application is distributed as a comprehensive multi-shell package that supports all major platforms and shells.

### Package Contents

```
aws-assume-role-cli-v1.0.0-YYYYMMDD/
├── aws-assume-role-macos          # macOS binary
├── aws-assume-role-unix           # Linux binary  
├── aws-assume-role.exe            # Windows binary
├── aws-assume-role-bash.sh        # Bash/Zsh wrapper (with Git Bash support)
├── aws-assume-role-fish.fish      # Fish shell wrapper
├── aws-assume-role-powershell.ps1 # PowerShell wrapper
├── aws-assume-role-cmd.bat        # Command Prompt wrapper
├── INSTALL.sh                     # Unix/Linux/macOS installer
├── INSTALL.ps1                    # Windows PowerShell installer
├── UNINSTALL.sh                   # Unix/Linux/macOS uninstaller
├── UNINSTALL.ps1                  # Windows PowerShell uninstaller
├── README.md                      # End-user documentation
├── CLEANUP_GUIDE.md               # Cleanup instructions
└── QUICK_START_DEPLOYMENT.md      # Quick deployment guide
```

## 🚀 Distribution Methods

### 1. Direct Package Distribution (Recommended)

**For End Users:**
1. Download the appropriate package:
   - `aws-assume-role-cli-v1.0.0-YYYYMMDD.zip` (Windows)
   - `aws-assume-role-cli-v1.0.0-YYYYMMDD.tar.gz` (Unix/Linux/macOS)

2. Extract and install:
   ```bash
   # Unix/Linux/macOS/Git Bash
   tar -xzf aws-assume-role-cli-v1.0.0-YYYYMMDD.tar.gz
   cd aws-assume-role-cli-v1.0.0-YYYYMMDD
   ./INSTALL.sh
   
   # Windows PowerShell
   # Extract the zip file, then:
   .\INSTALL.ps1
   ```

3. Clean up (optional):
   ```bash
   # Can safely delete extracted folder after installation
   cd .. && rm -rf aws-assume-role-cli-v1.0.0-YYYYMMDD
   ```

### 2. Enterprise Distribution

**For Organizations:**

1. **Internal Package Repository**: Host the distribution packages in your internal artifact repository
2. **Configuration Management**: Deploy via automation tools:
   ```bash
   # Ansible example
   - name: Download and install AWS Assume Role CLI
     unarchive:
       src: "{{ internal_repo }}/aws-assume-role-cli-v1.0.0-YYYYMMDD.tar.gz"
       dest: /tmp
       remote_src: yes
     
   - name: Run installer
     command: ./INSTALL.sh
     args:
       chdir: /tmp/aws-assume-role-cli-v1.0.0-YYYYMMDD
   ```

3. **Custom Installation**: Modify `INSTALL.sh` for organizational requirements

### 3. GitHub Releases (Future)

When published to GitHub:
```bash
# Direct download and install
curl -sSL https://github.com/org/aws-assume-role/releases/latest/download/install.sh | bash
```

## 🔧 Building New Releases

### Prerequisites
- Rust toolchain with cross-compilation targets
- Build script: `build-releases.sh`

### Build Process
```bash
# Build all platform binaries
./build-releases.sh

# Create distribution package
cd releases/multi-shell
./create-distribution.sh
```

### Cross-Platform Targets
The build process creates binaries for:
- **macOS**: Both Intel and Apple Silicon (universal binary)
- **Linux**: x86_64 GNU/Linux
- **Windows**: x86_64 Windows with MSVC

## 📋 Deployment Checklist

### Pre-Release
- [ ] All binaries built and tested
- [ ] Installation scripts tested on target platforms
- [ ] Documentation updated
- [ ] Version numbers updated
- [ ] Checksums generated

### Distribution
- [ ] Package created with `create-distribution.sh`
- [ ] Archives uploaded to distribution channel
- [ ] Installation instructions provided
- [ ] Support documentation available

### Post-Release
- [ ] Installation tested on clean systems
- [ ] User feedback collected
- [ ] Issues documented and tracked

## 🔍 Testing Installation

### Test Matrix
Test the installation on:
- [ ] macOS (Intel)
- [ ] macOS (Apple Silicon) 
- [ ] Ubuntu Linux
- [ ] Windows 10/11 (PowerShell)
- [ ] Windows 10/11 (Git Bash)
- [ ] Windows 10/11 (Command Prompt)

### Test Script
```bash
#!/bin/bash
# test-installation.sh

# Test basic functionality
awsr --help
awsr configure --name test --role-arn arn:aws:iam::123:role/Test --account-id 123
awsr list
awsr remove test
```

## 🆘 Support

### Common Deployment Issues

1. **Permission Errors**: Use user-specific installation (`~/.local/bin`)
2. **Path Issues**: Ensure installation directory is in PATH
3. **Shell Integration**: Verify wrapper scripts are sourced correctly
4. **Git Bash on Windows**: Ensure PowerShell format conversion is working

### Debug Information
Collect this information for troubleshooting:
- Operating system and version
- Shell type and version
- Installation method used
- Error messages
- Output of `awsr --version` (if working)

---

**Ready to Deploy?** Use the latest package from `releases/multi-shell/dist/` 