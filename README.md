# AWS Assume Role CLI

A fast, reliable command-line tool for switching between AWS IAM roles across different accounts. Designed for seamless integration with modern development workflows.

## ✨ Features

- 🔄 **Instant role switching** between AWS accounts
- 🔐 **Smart credential management** with automatic region handling
- 🌍 **Universal compatibility** (macOS, Linux, Windows, Git Bash, WSL)
- 📋 **Multiple output formats** (shell exports, JSON)
- 💾 **Persistent configuration** with simple JSON storage
- ⏱️ **Flexible session control** with custom durations
- 🐳 **Container support** via Docker and GitHub Packages
- 🚀 **Zero-config installation** via package managers

## 🚀 Installation

### Package Managers (Recommended)

**🍺 Homebrew (macOS/Linux)**
```bash
brew tap holdennguyen/tap
brew install aws-assume-role
```

**📦 APT (Debian/Ubuntu)**
```bash
sudo add-apt-repository ppa:holdennguyen/aws-assume-role
sudo apt update
sudo apt install aws-assume-role
```

**📦 DNF/YUM (Fedora/CentOS/RHEL)**
```bash
# Fedora
sudo dnf copr enable holdennguyen/aws-assume-role
sudo dnf install aws-assume-role

# CentOS/RHEL
sudo yum copr enable holdennguyen/aws-assume-role
sudo yum install aws-assume-role
```

**🦀 Cargo (Rust)**
```bash
cargo install aws-assume-role
```

**🐳 Container (Docker)**
```bash
# Pull from GitHub Container Registry
docker pull ghcr.io/holdennguyen/aws-assume-role:latest

# Run with AWS credentials
docker run --rm -v ~/.aws:/home/user/.aws ghcr.io/holdennguyen/aws-assume-role:latest awsr --help

# Use in CI/CD pipelines
docker run --rm \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN \
  ghcr.io/holdennguyen/aws-assume-role:latest \
  awsr assume production

# Use as base image for AWS-enabled containers
FROM ghcr.io/holdennguyen/aws-assume-role:latest
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
# 1. Verify prerequisites (recommended first step)
awsr verify

# 2. Configure a role
awsr configure --name dev --role-arn arn:aws:iam::123456789012:role/DevRole --account-id 123456789012

# 3. Assume the role
awsr assume dev

# 4. Verify current identity
aws sts get-caller-identity
```

## 📖 Commands

### Prerequisites Verification
```bash
awsr verify                                # Check all prerequisites
awsr verify --role dev                     # Check specific role
awsr verify --verbose                      # Detailed verification output
```

### Configure Roles
```bash
awsr configure --name <name> --role-arn <arn> --account-id <id>
awsr configure --name dev --role-arn arn:aws:iam::123456789012:role/DevRole --account-id 123456789012
```

### Assume Roles
```bash
awsr assume <role-name>                    # Shell export format
awsr assume <role-name> --format json      # JSON format
awsr assume <role-name> --duration 7200    # Custom duration (2 hours)
awsr assume <role-name> --exec "aws s3 ls" # Execute command with role
```

### Manage Roles
```bash
awsr list                                  # List configured roles
awsr remove <role-name>                    # Remove a role
```

### Understanding Commands
- **`aws-assume-role`**: The actual binary executable
- **`awsr`**: Convenient wrapper script (recommended for daily use)

Both work identically, but `awsr` provides seamless shell integration.

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

### Release Management
```bash
# Update version across all packages
./scripts/update-version.sh 1.0.3

# Create release
git tag -a v1.0.3 -m "Release v1.0.3"
git push origin master && git push origin v1.0.3
```

### Project Structure
```
src/
├── main.rs          # CLI entry point
├── cli/             # Command handling
├── aws/             # AWS SDK integration
├── config/          # Configuration management
└── error/           # Error handling

packaging/           # Package manager configurations
scripts/             # Automation scripts
.github/workflows/   # CI/CD automation
```

## 📋 Prerequisites

### 1. AWS CLI Installation
- AWS CLI v2 installed and accessible in PATH
- Verify: `aws --version`

### 2. AWS Credentials
- Valid AWS credentials configured (access keys, SSO, or profiles)
- Verify: `aws sts get-caller-identity`

### 3. IAM Permissions
- Your current identity must have `sts:AssumeRole` permission
- Example policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::*:role/YourRolePattern*"
    }
  ]
}
```

### 4. IAM Role Trust Policies
Target roles must trust your current identity:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::YOUR-ACCOUNT:user/your-user"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### ✅ Automatic Verification
Run `awsr verify` to check all prerequisites automatically!

## 🆘 Troubleshooting

### First Step: Run Verification
```bash
awsr verify                    # Check all prerequisites
awsr verify --role <name>      # Check specific role
awsr verify --verbose          # Detailed output
```

### Common Issues

**❌ "Role not found"**
- Check configured roles: `awsr list`
- Reconfigure role: `awsr configure --name <name> ...`

**❌ "Access denied" / "Cannot assume role"**
- Verify role trust policy allows your identity
- Check you have `sts:AssumeRole` permission
- Confirm role ARN and account ID are correct

**❌ "No credentials" / "AWS CLI not configured"**
- Install AWS CLI: `aws --version`
- Configure credentials: `aws configure`
- Test credentials: `aws sts get-caller-identity`

**❌ "Command not found: awsr"**
- Source the wrapper script: `source aws-assume-role-bash.sh`
- Or use direct binary: `aws-assume-role`

### Debug Mode
```bash
RUST_LOG=debug awsr assume <role-name>
```

### Getting Help
```bash
awsr --help                    # General help
awsr <command> --help          # Command-specific help
awsr verify                    # Automated troubleshooting
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📚 Documentation

- **[PREREQUISITES.md](PREREQUISITES.md)**: Complete setup guide for AWS credentials and permissions
- **[DISTRIBUTION.md](DISTRIBUTION.md)**: Enterprise deployment, containers, and package distribution
- **[RELEASE_GUIDE.md](RELEASE_GUIDE.md)**: Version management and release process (maintainers)
- **[GitHub Releases](https://github.com/holdennguyen/aws-assume-role/releases)**: Download binaries and packages

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `cargo test`
5. Submit a pull request

## 📊 Distribution

- **GitHub Releases**: Cross-platform binaries
- **GitHub Packages**: Docker containers
- **Package Managers**: Homebrew, Chocolatey, APT, RPM, AUR, Cargo
- **Container Registry**: `ghcr.io/holdennguyen/aws-assume-role`

---

**Need help?** Check the documentation above or open an issue on GitHub. 