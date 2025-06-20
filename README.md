# AWS Assume Role CLI

A simple command-line tool to easily switch between AWS IAM roles across different accounts, designed for SSO users.

## ✨ Features

- 🔄 Easy role switching between AWS accounts
- 🔐 SSO credential management  
- 🌍 Cross-platform support (macOS, Linux, Windows, Git Bash)
- 📋 Multiple output formats (shell exports, JSON)
- 💾 Persistent role configuration
- ⏱️ Session duration control

## 🚀 Installation

### Package Managers (Recommended)

**🍺 Homebrew (macOS/Linux)**
```bash
brew install holdennguyen/tap/aws-assume-role
```

**🍫 Chocolatey (Windows)**
```bash
choco install aws-assume-role
```

**📦 APT (Debian/Ubuntu)**
```bash
sudo apt update && sudo apt install aws-assume-role
```

**📦 DNF/YUM (Fedora/CentOS/RHEL)**
```bash
# Fedora
sudo dnf install aws-assume-role

# CentOS/RHEL
sudo yum install aws-assume-role
```

**🏗️ AUR (Arch Linux)**
```bash
yay -S aws-assume-role
```

**🦀 Cargo (Rust)**
```bash
cargo install aws-assume-role
```

### Manual Installation

**Option 1: From Release Package**
1. Download the latest release package for your platform from [GitHub Releases](https://github.com/holdennguyen/aws-assume-role/releases)
2. Extract and run the installer:
   ```bash
   # Unix/Linux/macOS/Git Bash
   ./INSTALL.sh
   
   # Windows PowerShell  
   .\\INSTALL.ps1
   ```

**Option 2: From Source**
```bash
git clone https://github.com/holdennguyen/aws-assume-role.git
cd aws-assume-role
cargo build --release
sudo cp target/release/aws-assume-role /usr/local/bin/
```

### Basic Usage

```bash
# 1. Configure a role
awsr configure --name dev --role-arn arn:aws:iam::123456789012:role/DevRole --account-id 123456789012

# 2. Assume the role
awsr assume dev

# 3. Verify
aws sts get-caller-identity
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

## 🔧 Configuration

- **Config file**: `~/.aws-assume-role/config.json`
- **Format**: JSON with role definitions
- **Auto-created**: When you add your first role

## 💡 Common Workflows

### Shell Integration
```bash
# Add to ~/.bashrc or ~/.zshrc
alias assume-dev='eval $(awsr assume dev)'
alias assume-prod='eval $(awsr assume prod)'
alias aws-whoami='aws sts get-caller-identity'
```

### Script Usage
```bash
#!/bin/bash
# Deploy script
eval $(awsr assume <role-name>)
```

## 🛠️ Development

### Prerequisites
- Rust 1.70+
- AWS CLI v2
- Valid AWS credentials

### Build
```bash
cargo build --release
cargo test
```

### Project Structure
```
src/
├── main.rs          # CLI entry point
├── cli/             # Command handling
├── aws/             # AWS SDK integration
├── config/          # Configuration management
└── error/           # Error handling
```

## 📋 Requirements

- AWS CLI v2 configured
- Valid AWS credentials (SSO or standard)
- Permission to assume target roles
- IAM roles with proper trust policies

## 🆘 Troubleshooting

**Common Issues:**
- **"Role not found"**: Check `awsr list` and reconfigure if needed
- **"Access denied"**: Verify role trust policy and your permissions
- **"No credentials"**: Run `aws configure list` to check AWS setup

**Debug Mode:**
```bash
RUST_LOG=debug awsr assume <role-name>
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Need help?** Check the documentation in the release package or open an issue on GitHub. 