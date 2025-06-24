# 📋 Installation & Deployment Guide

Complete guide for installing, configuring, and deploying AWS Assume Role CLI across different environments and platforms.

## 🚀 Quick Installation

### **Recommended Methods**

```bash
# 🍺 Homebrew (macOS/Linux)
brew tap holdennguyen/tap
brew install aws-assume-role

# 🦀 Cargo (Rust Users)
cargo install aws-assume-role

# 📦 Universal Installer (Linux/macOS)
curl -L https://github.com/holdennguyen/aws-assume-role/releases/download/v1.3.0/aws-assume-role-cli-v1.3.0.zip -o aws-assume-role-cli-v1.3.0.zip
unzip aws-assume-role-cli-v1.3.0.zip && cd aws-assume-role-cli-v1.3.0
./INSTALL.sh
```

**⚡ Quick Test**: `awsr --version` should show the installed version.

## 📋 Prerequisites

### **Required Dependencies**

| Requirement | Version | Purpose | Installation |
|-------------|---------|---------|--------------|
| **AWS CLI** | v2.0+ | Core AWS operations | [AWS CLI Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) |
| **Bash/Zsh**| Any recent| Shell integration | Pre-installed on most systems |

### **Platform Requirements**

| Platform | Architecture | Status | Notes |
|----------|-------------|--------|-------|
| **Linux** | x86_64 | ✅ Fully Supported | Statically linked binary for broad compatibility. |
| **macOS** | Apple Silicon & Intel | ✅ Fully Supported | Universal binary for M1/M2 and Intel. |
| **Windows** | x86_64 | ✅ Fully Supported | Requires Git Bash, WSL, or another bash-like environment. |

### **AWS Prerequisites**

1. **AWS CLI v2 Installed and Configured**:
   ```bash
   aws --version  # Should show AWS CLI 2.x
   aws sts get-caller-identity  # Should return your AWS identity
   ```

2. **AWS Credentials Configured**:
   - Via `aws configure` (access keys)
   - Via AWS SSO (`aws sso login`)
   - Via environment variables

3. **IAM Permissions**:
   Your AWS identity needs `sts:AssumeRole` permission for target roles.

## 🔧 Installation Methods

### **Method 1: Homebrew (Recommended for macOS & Linux)**

```bash
# Add our tap
brew tap holdennguyen/tap

# Install
brew install aws-assume-role

# Verify installation
awsr --version
```

**Advantages**:
- ✅ Automatic dependency management
- ✅ Easy updates with `brew upgrade`
- ✅ Trusted package manager
- ✅ Automatic `PATH` configuration

### **Method 2: Cargo (Rust Package Manager)**

```bash
# Install from crates.io
cargo install aws-assume-role

# Verify installation
awsr --version
```

**Advantages**:
- ✅ Always latest version
- ✅ Compiles optimized for your system
- ✅ No external dependencies
- ✅ Easy uninstall with `cargo uninstall`

**Requirements**:
- Rust toolchain installed (`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`)

### **Method 3: Universal Installer (Linux & macOS)**

```bash
# Download and extract
curl -L https://github.com/holdennguyen/aws-assume-role/releases/download/v1.3.0/aws-assume-role-cli-v1.3.0.zip -o aws-assume-role-cli-v1.3.0.zip
unzip aws-assume-role-cli-v1.3.0.zip && cd aws-assume-role-cli-v1.3.0

# Run installer
./INSTALL.sh

# Follow interactive prompts for:
# - Installation directory selection
# - Shell integration setup
# - PATH configuration
```

**Advantages**:
- ✅ Works on any Unix-like system
- ✅ No package manager required
- ✅ Interactive configuration
- ✅ Includes all required binaries

### **Method 4: Container/Docker**

```bash
# Pull the image
docker pull ghcr.io/holdennguyen/aws-assume-role:latest

# Create an alias for easy use
echo 'alias awsr="docker run --rm -v ~/.aws:/home/awsuser/.aws -v ~/.aws-assume-role:/home/awsuser/.aws-assume-role ghcr.io/holdennguyen/aws-assume-role:latest awsr"' >> ~/.bashrc
source ~/.bashrc

# Use normally
awsr --version
```

**Advantages**:
- ✅ Isolated environment
- ✅ Consistent across systems
- ✅ No local installation required
- ✅ Easy cleanup

## 🏢 Enterprise Deployment

### **Centralized Installation**

**Option 1: Package Repository**
```bash
# Set up internal package repository
# Add aws-assume-role packages to your repo
# Deploy via existing package management

# Example for APT-based systems
echo "deb [trusted=yes] https://your-repo.company.com/apt stable main" | sudo tee /etc/apt/sources.list.d/company.list
sudo apt update
sudo apt install aws-assume-role
```

**Option 2: Configuration Management**
```yaml
# Ansible example
- name: Install AWS Assume Role CLI
  get_url:
    url: "https://github.com/holdennguyen/aws-assume-role/releases/latest/download/aws-assume-role-linux"
    dest: "/usr/local/bin/awsr"
    mode: '0755'
  become: yes

- name: Verify installation
  command: awsr --version
  register: version_check
  changed_when: false
```

**Option 3: Container Deployment**
```dockerfile
# Add to your base images
FROM ubuntu:22.04
RUN curl -L https://github.com/holdennguyen/aws-assume-role/releases/latest/download/aws-assume-role-linux -o /usr/local/bin/awsr \
    && chmod +x /usr/local/bin/awsr
```

### **Centralized Configuration**

**Organization-wide Role Definitions**:
```bash
# Create organization config template
mkdir -p /etc/aws-assume-role/
cat > /etc/aws-assume-role/org-roles.json << 'EOF'
{
  "roles": {
    "dev": {
      "role_arn": "arn:aws:iam::123456789012:role/DeveloperRole",
      "account_id": "123456789012",
      "region": "us-east-1"
    },
    "staging": {
      "role_arn": "arn:aws:iam::234567890123:role/StagingRole", 
      "account_id": "234567890123",
      "region": "us-east-1"
    },
    "prod": {
      "role_arn": "arn:aws:iam::345678901234:role/ProductionRole",
      "account_id": "345678901234", 
      "region": "us-west-2"
    }
  },
  "default_duration": 3600,
  "default_region": "us-east-1"
}
EOF

# Users can import organization roles
awsr configure --import /etc/aws-assume-role/org-roles.json
```

### **Security Considerations**

**File Permissions**:
```bash
# Secure configuration directory
chmod 700 ~/.aws-assume-role/
chmod 600 ~/.aws-assume-role/config.json

# For shared systems
umask 077  # Ensures restrictive permissions
```

**Audit Logging**:
```bash
# Enable CloudTrail for role assumption tracking
# Monitor AWS STS AssumeRole API calls
# Set up alerts for unusual role usage patterns
```

**Network Security**:
- Ensure HTTPS-only communication with AWS APIs
- Configure appropriate VPC endpoints if needed
- Monitor network traffic for AWS API calls

## 🔧 Configuration

### **Initial Setup**

1. **Verify Prerequisites**:
   ```bash
   awsr verify
   ```

2. **Configure Your First Role**:
   ```bash
   awsr configure --name dev \
     --role-arn arn:aws:iam::123456789012:role/DevRole \
     --account-id 123456789012 \
     --region us-east-1
   ```

3. **Test Role Assumption**:
   ```bash
   awsr assume dev
   aws sts get-caller-identity  # Should show assumed role
   ```

### **Configuration File Location**

| Platform | Location | Notes |
|----------|----------|-------|
| **Linux/macOS** | `~/.aws-assume-role/config.json` | Respects `$HOME` environment |
| **Windows** | `%USERPROFILE%\.aws-assume-role\config.json` | Git Bash compatible |

### **Advanced Configuration**

**Custom Default Settings**:
```json
{
  "roles": {
    "dev": {
      "role_arn": "arn:aws:iam::123456789012:role/DevRole",
      "account_id": "123456789012",
      "region": "us-east-1",
      "duration": 7200,
      "external_id": "optional-external-id"
    }
  },
  "default_duration": 3600,
  "default_region": "us-east-1",
  "default_session_name": "aws-assume-role-session"
}
```

**Environment-Specific Roles**:
```bash
# Development environment
awsr configure --name dev-api --role-arn arn:aws:iam::123456789012:role/APIRole
awsr configure --name dev-db --role-arn arn:aws:iam::123456789012:role/DatabaseRole

# Production environment  
awsr configure --name prod-api --role-arn arn:aws:iam::345678901234:role/APIRole
awsr configure --name prod-db --role-arn arn:aws:iam::345678901234:role/DatabaseRole
```

## 🛠️ Shell Integration

### **Bash/Zsh Integration**

Add to `~/.bashrc` or `~/.zshrc`:
```bash
# AWS Assume Role CLI aliases
alias assume-dev='awsr assume dev'
alias assume-staging='awsr assume staging'
alias assume-prod='awsr assume prod'
alias aws-whoami='aws sts get-caller-identity --query "Arn" --output text'
alias aws-unset='unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN'
```

### **Fish Shell Integration**

Add to `~/.config/fish/config.fish`:
```fish
# AWS Assume Role CLI aliases
alias assume-dev='awsr assume dev | source'
alias assume-staging='awsr assume staging | source'
alias assume-prod='awsr assume prod | source'
alias aws-whoami='aws sts get-caller-identity --query "Arn" --output text'

# Auto-completion
if command -v awsr >/dev/null 2>&1
  awsr completion fish | source
end
```

## 🔍 Troubleshooting

### **Common Issues**

**1. "AWS CLI not found"**
```bash
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify
aws --version
```

**2. "Unable to locate credentials"**
```bash
# Configure base AWS credentials
aws configure
# OR
aws sso login
# OR
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
```

**3. "Access denied for role assumption"**
```bash
# Check your current AWS identity
aws sts get-caller-identity

# Verify role ARN and permissions
aws iam get-role --role-name YourRoleName
aws iam list-attached-role-policies --role-name YourRoleName
```

**4. "Command not found: awsr"**
```bash
# Check if binary is in PATH
which awsr
echo $PATH

# If not found, check installation
ls -la /usr/local/bin/awsr
ls -la ~/.cargo/bin/awsr

# Add to PATH if needed
export PATH="$PATH:/usr/local/bin"
# OR
export PATH="$PATH:$HOME/.cargo/bin"
```

### **Debug Mode**

Enable verbose logging:
```bash
# Set debug environment variable
export RUST_LOG=debug
awsr assume dev

# Or use verbose flag
awsr --verbose assume dev
```

### **Configuration Issues**

**Check configuration file**:
```bash
# View current configuration
awsr list

# Validate configuration file
cat ~/.aws-assume-role/config.json | python -m json.tool

# Reset configuration (if corrupted)
rm ~/.aws-assume-role/config.json
awsr configure --name dev --role-arn arn:aws:iam::123456789012:role/DevRole
```

## 📊 Health Checks

### **System Health Verification**

```bash
# Comprehensive health check
awsr verify --verbose

# Check specific components
awsr verify --aws-cli      # AWS CLI installation
awsr verify --credentials  # AWS credentials
awsr verify --permissions  # File permissions
awsr verify --connectivity # AWS API connectivity
```

### **Performance Testing**

```bash
# Measure role assumption time
time awsr assume dev

# Test multiple role switches
for role in dev staging prod; do
  echo "Testing $role..."
  time awsr assume $role
done
```

### **Monitoring Setup**

**CloudTrail Integration**:
```json
{
  "eventVersion": "1.05",
  "userIdentity": {
    "type": "AssumedRole",
    "principalId": "AIDACKCEVSQ6C2EXAMPLE",
    "arn": "arn:aws:sts::123456789012:assumed-role/DevRole/aws-assume-role-session",
    "accountId": "123456789012"
  },
  "eventTime": "2024-01-15T10:30:00Z",
  "eventSource": "sts.amazonaws.com",
  "eventName": "AssumeRole"
}
```

**Metrics Collection**:
```bash
# Custom metrics for role usage
aws cloudwatch put-metric-data \
  --namespace "AWS/AssumeRole" \
  --metric-data MetricName=RoleAssumptions,Value=1,Unit=Count
```

## 🚀 Updates & Maintenance

### **Updating**

```bash
# Homebrew
brew upgrade aws-assume-role

# Cargo
cargo install aws-assume-role

# Universal installer
curl -L https://github.com/holdennguyen/aws-assume-role/releases/download/v1.3.0/aws-assume-role-cli-v1.3.0.zip -o aws-assume-role-cli-v1.3.0.zip
unzip aws-assume-role-cli-v1.3.0.zip && cd aws-assume-role-cli-v1.3.0
./INSTALL.sh --upgrade
```

### **Uninstallation**

```bash
# Homebrew
brew uninstall aws-assume-role

# Cargo
cargo uninstall aws-assume-role

# Manual removal
sudo rm /usr/local/bin/awsr
rm -rf ~/.aws-assume-role/

# Remove shell integration
# Edit ~/.bashrc, ~/.zshrc, etc. to remove aliases
```

## 📞 Support

**Getting Help**:
- 📖 **Documentation**: This guide and [README.md](../README.md)
- 🐛 **Issues**: [GitHub Issues](https://github.com/holdennguyen/aws-assume-role/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/holdennguyen/aws-assume-role/discussions)
- 📧 **Contact**: Create an issue for support

**Before Reporting Issues**:
1. Run `awsr verify --verbose`
2. Check the [troubleshooting section](#-troubleshooting)
3. Search existing GitHub issues
4. Include version info: `awsr --version`

---

**🎉 Ready to Go!** Once installed, head back to the [README](../README.md) for usage examples and advanced features. 