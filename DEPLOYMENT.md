# 🚀 Deployment Guide

Complete guide for installing, distributing, and deploying AWS Assume Role CLI across different environments and platforms.

## 📋 Prerequisites Setup

### Quick Verification
Before starting, run the built-in verification:
```bash
awsr verify
```
This automatically checks all prerequisites and provides specific guidance for any issues.

### 1. AWS CLI Installation

**macOS (Homebrew)**:
```bash
brew install awscli
```

**macOS/Linux (Official)**:
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows**: Download MSI installer from [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

**Verify**: `aws --version` (should show aws-cli/2.x.x)

### 2. AWS Credentials Configuration

**Method 1: Access Keys (Basic)**
```bash
aws configure
```

**Method 2: AWS SSO (Recommended)**
```bash
aws configure sso
```

**Method 3: Multiple Profiles**
```ini
# ~/.aws/credentials
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY

[my-profile]
aws_access_key_id = ANOTHER_ACCESS_KEY
aws_secret_access_key = ANOTHER_SECRET_KEY
```

**Verify**: `aws sts get-caller-identity`

### 3. IAM Permissions Setup

**Your Identity Needs Permission to Assume Roles:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "arn:aws:iam::123456789012:role/DevRole",
        "arn:aws:iam::987654321098:role/ProdRole",
        "arn:aws:iam::*:role/MyRolePattern*"
      ]
    }
  ]
}
```

**Target Roles Must Trust Your Identity:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::YOUR-ACCOUNT:user/your-username",
          "arn:aws:iam::YOUR-ACCOUNT:role/your-role"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

## 📦 Installation Methods

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

### Container Installation

**🐳 Docker**
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

# Use as base image
FROM ghcr.io/holdennguyen/aws-assume-role:latest
```

### Manual Installation

**From Release Package**
1. Download from [GitHub Releases](https://github.com/holdennguyen/aws-assume-role/releases)
2. Extract and run installer:
   ```bash
   # Unix/Linux/macOS/Git Bash
   ./INSTALL.sh
   
   # Windows PowerShell  
   .\INSTALL.ps1
   ```

**From Source**
```bash
git clone https://github.com/holdennguyen/aws-assume-role.git
cd aws-assume-role
cargo build --release
sudo cp target/release/aws-assume-role /usr/local/bin/
```

## 🏢 Enterprise Deployment

### Direct Package Distribution

**Package Contents:**
```
aws-assume-role-cli-v1.2.0-YYYYMMDD/
├── aws-assume-role-macos          # macOS binary (universal)
├── aws-assume-role-unix           # Linux binary (x86_64)
├── aws-assume-role.exe            # Windows binary
├── aws-assume-role-bash.sh        # Bash/Zsh wrapper
├── aws-assume-role-fish.fish      # Fish shell wrapper
├── aws-assume-role-powershell.ps1 # PowerShell wrapper
├── aws-assume-role-cmd.bat        # Command Prompt wrapper
├── INSTALL.sh                     # Unix installer
├── INSTALL.ps1                    # Windows installer
├── UNINSTALL.sh                   # Unix uninstaller
├── UNINSTALL.ps1                  # Windows uninstaller
└── README.md                      # End-user documentation
```

**Installation Options:**
- **Option 1**: Current directory (testing)
- **Option 2**: `/usr/local/bin` (system-wide, requires admin)
- **Option 3**: `~/.local/bin` (user-specific, recommended)

### Enterprise Automation

**Ansible Example:**
```yaml
- name: Download and install AWS Assume Role CLI
  unarchive:
    src: "{{ internal_repo }}/aws-assume-role-cli-v1.2.0-YYYYMMDD.tar.gz"
    dest: /tmp
    remote_src: yes

- name: Run installer
  command: ./INSTALL.sh
  args:
    chdir: /tmp/aws-assume-role-cli-v1.2.0-YYYYMMDD
```

**Internal Repository Distribution:**
1. Host packages in internal artifact repository
2. Deploy via configuration management tools
3. Customize installation scripts for organizational requirements

## 📦 Package Publishing

### Supported Package Managers

| Package Manager | Status | Repository |
|----------------|--------|------------|
| 🦀 **Cargo** | ✅ Automated | crates.io |
| 🍺 **Homebrew** | ✅ Automated | holdennguyen/tap |
| 📦 **APT** | ✅ Automated | ppa:holdennguyen/aws-assume-role |
| 📦 **YUM/DNF** | ✅ Automated | holdennguyen/aws-assume-role COPR |

### Automated Publishing

**GitHub Actions Workflow** automatically publishes to all package managers on release:

1. **Homebrew**: Updates personal tap repository
2. **APT**: Builds and uploads to Launchpad PPA
3. **COPR**: Submits build to Fedora COPR
4. **Cargo**: Publishes to crates.io

**Required Secrets:**
```bash
PPA_GPG_PRIVATE_KEY     # GPG private key for signing packages
PPA_GPG_PASSPHRASE      # GPG key passphrase
COPR_CONFIG             # COPR configuration file content
```

### Manual Publishing

```bash
# Use helper script
./scripts/publish-to-package-managers.sh

# Options:
# 1. Publish to Homebrew tap
# 2. Prepare PPA package
# 3. Publish to COPR
# 4. Update documentation
# 5. Publish to all
```

## 🐳 Container Distribution

### Container Tags Strategy
- `ghcr.io/holdennguyen/aws-assume-role:latest` - Latest stable
- `ghcr.io/holdennguyen/aws-assume-role:v1.2.0` - Specific version
- `ghcr.io/holdennguyen/aws-assume-role:1.2.0` - Semver
- `ghcr.io/holdennguyen/aws-assume-role:1.2` - Major.minor
- `ghcr.io/holdennguyen/aws-assume-role:1` - Major version

### Container Usage Patterns

**Interactive Usage:**
```bash
docker run -it --rm \
  -v ~/.aws:/home/user/.aws:ro \
  -e AWS_PROFILE \
  ghcr.io/holdennguyen/aws-assume-role:latest
```

**CI/CD Pipelines:**
```yaml
# GitHub Actions example
- name: Assume AWS Role
  run: |
    docker run --rm \
      -v ${{ github.workspace }}:/workspace \
      -e AWS_ACCESS_KEY_ID \
      -e AWS_SECRET_ACCESS_KEY \
      -e AWS_SESSION_TOKEN \
      ghcr.io/holdennguyen/aws-assume-role:latest \
      awsr assume production
```

## 🚨 Troubleshooting

### Common Issues

**❌ "AWS CLI not found"**
- **Solution**: Install AWS CLI v2
- **Verify**: `aws --version`

**❌ "Unable to locate credentials"**
- **Solution**: Configure AWS credentials
- **Verify**: `aws sts get-caller-identity`

**❌ "Access Denied" when assuming role**
- **Cause**: Missing sts:AssumeRole permission
- **Solution**: Add IAM policy to your user/role

**❌ "Not authorized to perform: sts:AssumeRole"**
- **Cause**: Target role doesn't trust your identity
- **Solution**: Update target role's trust policy

**❌ "Token has expired"**
- **Cause**: Temporary credentials have expired
- **Solution**: Refresh credentials (re-run `aws configure` or SSO login)

### Debug Commands

```bash
# Test Homebrew formula
brew audit --strict packaging/homebrew/aws-assume-role.rb

# Validate PPA package
debuild -S -sa --lintian-opts --profile debian

# Test COPR spec
rpmlint packaging/rpm/aws-assume-role.spec

# Debug mode
RUST_LOG=debug awsr assume <role-name>
```

## ✅ Deployment Checklist

### Pre-Distribution
- [ ] All binaries built and tested on target platforms
- [ ] Installation scripts tested (Unix/Linux/macOS/Windows)
- [ ] Documentation updated with current version
- [ ] Container images built and pushed
- [ ] Package manager configurations updated

### Distribution Validation
- [ ] Download links working
- [ ] Installation scripts execute successfully
- [ ] Binary permissions and signatures correct
- [ ] Container images pull and run correctly
- [ ] Package manager installations work

### Post-Distribution
- [ ] Monitor download statistics
- [ ] Collect user feedback
- [ ] Document any issues discovered
- [ ] Update support documentation as needed

## 📚 Resources

- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Launchpad PPA Documentation](https://help.launchpad.net/Packaging/PPA)
- [COPR Documentation](https://docs.pagure.org/copr.copr/)
- [Cargo Publishing Guide](https://doc.rust-lang.org/cargo/reference/publishing.html) 