# 🚀 AWS Assume Role CLI - Distribution Guide

This guide covers enterprise deployment, package distribution, and container usage for the AWS Assume Role CLI.

## 📦 Distribution Overview

### Multiple Distribution Channels
- **📦 GitHub Releases**: Cross-platform binaries and packages
- **🐳 GitHub Packages**: Docker containers for CI/CD
- **📋 Package Managers**: Homebrew, Chocolatey, APT, RPM, AUR, Cargo
- **🏢 Enterprise**: Internal distribution packages

### Package Contents
```
aws-assume-role-cli-v1.0.3-YYYYMMDD/
├── aws-assume-role-macos          # macOS binary (universal)
├── aws-assume-role-unix           # Linux binary (x86_64)
├── aws-assume-role.exe            # Windows binary
├── aws-assume-role-bash.sh        # Bash/Zsh wrapper (Git Bash support)
├── aws-assume-role-fish.fish      # Fish shell wrapper
├── aws-assume-role-powershell.ps1 # PowerShell wrapper
├── aws-assume-role-cmd.bat        # Command Prompt wrapper
├── INSTALL.sh                     # Unix/Linux/macOS installer
├── INSTALL.ps1                    # Windows PowerShell installer
├── UNINSTALL.sh                   # Unix/Linux/macOS uninstaller
├── UNINSTALL.ps1                  # Windows PowerShell uninstaller
└── README.md                      # End-user documentation
```

## 🏢 Enterprise Deployment

### Method 1: Direct Package Distribution (Recommended)

**For End Users:**
1. Download the appropriate package for your platform
2. Extract to a temporary location
3. Run the installer:
   ```bash
   # Unix/Linux/macOS/Git Bash
   ./INSTALL.sh
   
   # Windows PowerShell
   .\INSTALL.ps1
   ```
4. Choose installation location:
   - **Recommended**: Option 3 (`~/.local/bin`) - User-specific
   - **System-wide**: Option 2 (`/usr/local/bin`) - Requires admin
   - **Testing**: Option 1 (Current directory) - For testing only

### Method 2: Enterprise Automation

**For Organizations:**
```bash
# Ansible example
- name: Download and install AWS Assume Role CLI
  unarchive:
    src: "{{ internal_repo }}/aws-assume-role-cli-v1.0.3-YYYYMMDD.tar.gz"
    dest: /tmp
    remote_src: yes
  
- name: Run installer
  command: ./INSTALL.sh
  args:
    chdir: /tmp/aws-assume-role-cli-v1.0.3-YYYYMMDD
```

**Internal Repository Distribution:**
1. Host packages in internal artifact repository
2. Deploy via configuration management tools
3. Customize installation scripts for organizational requirements

### Method 3: Package Managers (Production)

**Available Channels:**
```bash
# Homebrew (macOS/Linux)
brew install holdennguyen/tap/aws-assume-role

# Chocolatey (Windows)
choco install aws-assume-role

# APT (Debian/Ubuntu)
sudo apt install aws-assume-role

# DNF/YUM (Fedora/CentOS/RHEL)
sudo dnf install aws-assume-role

# AUR (Arch Linux)
yay -S aws-assume-role

# Cargo (Rust)
cargo install aws-assume-role
```

## 🐳 Container Distribution

### GitHub Container Registry
```bash
# Pull latest version
docker pull ghcr.io/holdennguyen/aws-assume-role:latest

# Pull specific version
docker pull ghcr.io/holdennguyen/aws-assume-role:v1.0.3
```

### Container Usage Patterns

**1. Interactive Usage**
```bash
# Run with AWS credentials mounted
docker run -it --rm \
  -v ~/.aws:/home/user/.aws:ro \
  -e AWS_PROFILE \
  ghcr.io/holdennguyen/aws-assume-role:latest
```

**2. CI/CD Pipelines**
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

**3. Base Image for AWS-Enabled Containers**
```dockerfile
FROM ghcr.io/holdennguyen/aws-assume-role:latest

# Your application code
COPY . /app
WORKDIR /app

# AWS role switching is now available
RUN awsr configure --name dev --role-arn arn:aws:iam::123456789012:role/DevRole
```

### Container Tags Strategy
- `ghcr.io/holdennguyen/aws-assume-role:latest` - Latest stable
- `ghcr.io/holdennguyen/aws-assume-role:v1.0.3` - Specific version
- `ghcr.io/holdennguyen/aws-assume-role:1.0.3` - Semver
- `ghcr.io/holdennguyen/aws-assume-role:1.0` - Major.minor
- `ghcr.io/holdennguyen/aws-assume-role:1` - Major version

## 📋 Deployment Checklist

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

## 🔧 Building New Releases

### Prerequisites
- Rust toolchain with cross-compilation targets
- Docker for container builds
- Access to package manager repositories

### Build Process
```bash
# Build all platform binaries
./build-releases.sh

# Create distribution package
cd releases/multi-shell
./create-distribution.sh

# Build and push containers (automated via GitHub Actions)
```

### Cross-Platform Targets
- **macOS**: Universal binary (Intel + Apple Silicon)
- **Linux**: x86_64 GNU/Linux
- **Windows**: x86_64 Windows with MSVC

## 🎯 Distribution by Audience

### 📱 End Users
- **GitHub Releases**: Direct binary downloads
- **Package Managers**: Simple installation commands
- **Containers**: For containerized environments

### 🏢 Enterprise/IT Teams
- **Distribution Packages**: Comprehensive installation bundles
- **Automation Scripts**: Ansible, Puppet, Chef integration
- **Internal Repositories**: Host packages internally

### 👨‍💻 Developers
- **Cargo**: Rust dependency management
- **Containers**: Base images for AWS-enabled applications
- **Source**: Build from source for customization

### 🔄 DevOps/CI-CD
- **Container Registry**: Automated pipeline integration
- **Package Managers**: Consistent environment setup
- **GitHub Actions**: Direct integration examples

## 🔒 Security Considerations

### Distribution Security
- **Checksums**: Verify package integrity
- **Signatures**: GPG signing for critical packages
- **Container Scanning**: Automated vulnerability detection
- **Access Control**: Secure internal distribution channels

### Deployment Security
- **No Credential Storage**: Tool never stores AWS credentials
- **Temporary Sessions**: Assumed role credentials expire
- **Local Configuration**: Role definitions stored locally
- **Audit Trail**: AWS CloudTrail logs all role assumptions

## 🆘 Enterprise Support

### Common Deployment Issues
1. **Permission Errors**: Use user-specific installation paths
2. **PATH Configuration**: Ensure installation directory is in PATH
3. **Shell Integration**: Verify wrapper scripts are properly sourced
4. **Multi-user Environments**: Consider system-wide vs user-specific installs

### Support Information
- **Installation Issues**: Check file permissions and PATH
- **AWS Configuration**: Verify credentials and role permissions
- **Shell Integration**: Ensure wrapper scripts are sourced
- **Container Issues**: Check volume mounts and environment variables

### Debug Information Collection
For troubleshooting, collect:
- Operating system and version
- Shell type and version
- Installation method used
- Error messages and logs
- Output of `awsr --version` and `awsr verify`

## 📊 Distribution Analytics

### Tracking Metrics
- **GitHub Releases**: Download counts per platform
- **Container Registry**: Pull statistics and usage patterns
- **Package Managers**: Installation metrics where available
- **User Feedback**: Issues, feature requests, and success stories

### Success Indicators
- Cross-platform installation success rates
- User adoption across different distribution channels
- Reduced support tickets for installation issues
- Positive feedback on ease of deployment

---

**Ready to Deploy?** Choose the distribution method that best fits your organization's needs and infrastructure. All methods provide the same core functionality with different deployment and management characteristics. 