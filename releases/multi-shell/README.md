# AWS Assume Role CLI

A simple command-line tool to easily switch between AWS IAM roles across different accounts, designed for SSO users.

## ✨ Features

- 🔄 Easy role switching between AWS accounts
- 🔐 SSO credential management  
- 🌍 Cross-platform support (macOS, Linux, Windows, Git Bash)
- 📋 Multiple output formats (shell exports, JSON)
- 💾 Persistent role configuration
- ⏱️ Session duration control

## 📦 Installation Instructions

### Quick Installation (Recommended)

1. **Download and extract** the appropriate package for your system:
   - `aws-assume-role-cli-v1.0.0-YYYYMMDD.zip` for Windows
   - `aws-assume-role-cli-v1.0.0-YYYYMMDD.tar.gz` for Unix/Linux/macOS

2. **Run the automated installer**:
   ```bash
   # For Unix/Linux/macOS/Git Bash
   ./INSTALL.sh
   
   # For Windows PowerShell
   .\INSTALL.ps1
   ```

3. **Choose installation location** when prompted:
   - **Option 1**: Current directory (for testing)
   - **Option 2**: `/usr/local/bin` (system-wide, requires sudo)
   - **Option 3**: `~/.local/bin` (user-specific, recommended)
   - **Option 4**: Custom directory

4. **Cleanup**: If you chose option 2 or 3, you can safely delete the extracted folder after installation.

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
rm -rf aws-assume-role-cli-v1.0.0-YYYYMMDD

# Or on Windows
rmdir /s aws-assume-role-cli-v1.0.0-YYYYMMDD
```

**If you installed to current directory** (Option 1):
⚠️ **Keep the folder** - it contains your installation files.

## 🚀 Quick Start

### Configure Your First Role
```bash
awsr configure --name "dev-role" \
  --role-arn "arn:aws:iam::123456789012:role/DeveloperRole" \
  --account-id "123456789012"
```

### Assume the Role
```bash
awsr assume dev-role
```

### Verify
```bash
aws sts get-caller-identity
# Should show the assumed role
```

## 📖 Commands

### Configure Roles
```bash
awsr configure --name <name> --role-arn <arn> --account-id <id>
```

### Assume Roles
```bash
awsr assume <role-name>                    # Shell export format
awsr assume <role-name> --format json      # JSON format
awsr assume <role-name> --duration 7200    # Custom duration (2 hours)
```

### Manage Roles
```bash
awsr list                                  # List configured roles
awsr remove <role-name>                    # Remove a role
```

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

### Git Bash on Windows
- Ensure you're using the bash wrapper: `source aws-assume-role-bash.sh`
- The installer handles PowerShell format conversion automatically

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