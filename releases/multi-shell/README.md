# AWS Assume Role CLI - Multi-Shell Distribution

This directory contains platform-specific binaries and shell integration scripts for AWS Assume Role CLI.

## 📦 Quick Installation

1. **Download and extract** the appropriate package:
   - `aws-assume-role-cli-v{VERSION}-YYYYMMDD.zip` for Windows
   - `aws-assume-role-cli-v{VERSION}-YYYYMMDD.tar.gz` for Unix/Linux/macOS

2. **Run the installer**:
   ```bash
   # Unix/Linux/macOS/Git Bash
   ./INSTALL.sh
   
   # Windows PowerShell  
   .\INSTALL.ps1
   ```

3. **Choose installation location**:
   - **System-wide**: `/usr/local/bin` (requires sudo)
   - **User-specific**: `~/.local/bin` (recommended)  
   - **Current directory**: For testing only

### 🧹 After Installation

The installer copies all necessary files to your chosen directory and updates the wrapper scripts to use absolute paths. This means:

- ✅ **You can delete the extracted folder** (if you didn't install to current directory)
- ✅ **The `awsr` command works from anywhere**
- ✅ **All files are properly installed and configured**

**If you installed to a system directory** (Option 2 or 3):
```bash
# Go back to parent directory
cd ..

# Remove the extracted folder
rm -rf aws-assume-role-cli-v1.0.1-YYYYMMDD

# Or on Windows
rmdir /s aws-assume-role-cli-v1.0.1-YYYYMMDD
```

**If you installed to current directory** (Option 1):
⚠️ **Keep the folder** - it contains your installation files.

## 🚀 Quick Start

After installation, configure and use roles:

```bash
# Configure a role
awsr configure --name dev --role-arn arn:aws:iam::123456789012:role/DevRole --account-id 123456789012

# Assume the role  
awsr assume dev

# Verify current identity
aws sts get-caller-identity
```

**→ [Complete usage guide in main README](../../README.md)**

## 💡 Shell Integration

### Bash/Zsh Users (Linux, macOS, Git Bash on Windows)

The installer automatically configures your shell. If you need to do it manually:

```bash
# Source the wrapper script
source /path/to/aws-assume-role-bash.sh

# Add to your shell profile for permanent use
echo 'source /path/to/aws-assume-role-bash.sh' >> ~/.bashrc  # or ~/.zshrc
```

### Fish Shell Users

```fish
# Source the wrapper script
source /path/to/aws-assume-role-fish.fish

# Add to your Fish config
echo 'source /path/to/aws-assume-role-fish.fish' >> ~/.config/fish/config.fish
```

### PowerShell Users (Windows)

```powershell
# Source the wrapper script
. .\aws-assume-role-powershell.ps1

# Add to your PowerShell profile
Add-Content $PROFILE '. /path/to/aws-assume-role-powershell.ps1'
```

### Command Prompt Users (Windows)

```cmd
# Run the batch file
aws-assume-role-cmd.bat assume dev-role
```

## 🔧 Configuration

- **Config file**: `~/.aws-assume-role/config.json`
- **Format**: JSON with role definitions
- **Auto-created**: When you add your first role

## 💡 Common Workflows

### Shell Aliases
```bash
# Add to ~/.bashrc or ~/.zshrc
alias assume-dev='awsr assume dev'
alias assume-prod='awsr assume prod'
alias aws-whoami='aws sts get-caller-identity'
```

### Script Usage
```bash
#!/bin/bash
# Deploy script
awsr assume prod
aws s3 sync ./dist s3://my-bucket
```

## 🆘 Troubleshooting

### Installation Issues

If you encounter "❌ AWS Assume Role binary not found" or similar errors:

1. **Run the debug script** to diagnose the issue:
   ```bash
   ./debug-environment.sh
   ```
   This will show detailed information about your environment and help identify the problem.

2. **For Git Bash on Windows**:
   - Ensure you extracted the complete package
   - Check that `aws-assume-role.exe` exists in the directory
   - Try: `OSTYPE=msys ./INSTALL.sh` if auto-detection fails
   - Alternative: Use PowerShell instead: `.\INSTALL.ps1`

### Git Bash on Windows
- Ensure you're using the bash wrapper: `source aws-assume-role-bash.sh`
- The installer handles PowerShell format conversion automatically
- If installation fails, run `./debug-environment.sh` for detailed diagnostics

### Permission Issues
- Use Option 3 (`~/.local/bin`) to avoid sudo requirements
- Ensure `~/.local/bin` is in your PATH

### Command Not Found
- Restart your shell or run: `source ~/.bashrc` (or your shell's config file)
- Check if the wrapper was added to your shell profile

### Debug Mode
```bash
# Enable debug output
RUST_LOG=debug awsr assume <role-name>
```

## 📋 Requirements

- AWS CLI v2 configured
- Valid AWS credentials (SSO or standard)
- Permission to assume target roles
- IAM roles with proper trust policies

## 🗑️ Uninstallation

If you need to uninstall later:

```bash
# Unix/Linux/macOS/Git Bash
./UNINSTALL.sh

# Windows PowerShell  
.\UNINSTALL.ps1
```

**Note**: Keep the uninstall scripts if you might need them later, or download the package again when needed.

---

**🎉 That's it! You're ready to use AWS Assume Role CLI.**

For advanced usage and development information, see the project repository. 