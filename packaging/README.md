# Distribution Guide - Streamlined Approach

This directory contains configuration files for distributing AWS Assume Role CLI through our **4 supported distribution channels**: Direct binaries, Cargo, Homebrew, and Container images.

## 📦 Supported Distribution Channels

### 🍺 Homebrew (macOS/Linux)
**Installation**: `brew tap holdennguyen/tap && brew install aws-assume-role`

**Files**:
- `homebrew/aws-assume-role.rb` - Homebrew formula
- Automatically creates universal binary installation with `awsr` alias

**Features**:
- Cross-platform support (macOS Apple Silicon, Linux x86_64)
- Automatic dependency management
- Easy updates with `brew upgrade`
- Trusted package manager integration

### 🦀 Cargo (Rust Package Manager)
**Installation**: `cargo install aws-assume-role`

**Registry**: crates.io (official Rust package registry)

**Features**:
- Always latest version available
- Compiles optimized for your specific system
- No external dependencies beyond Rust toolchain
- Easy uninstall with `cargo uninstall aws-assume-role`
- Trusted by Rust developers worldwide

### 📦 Direct Binary Downloads
**Installation**: Download and run universal installer

**Files**:
- GitHub Releases with platform-specific binaries
- Universal installer script (`INSTALL.sh`)
- Cross-platform wrapper scripts

**Features**:
- Linux x86_64, macOS Apple Silicon, Windows Git Bash support
- Universal bash wrapper for consistent experience
- No package manager dependencies
- Enterprise-friendly distribution

### 🐳 Container Images
**Installation**: `docker pull ghcr.io/holdennguyen/aws-assume-role:latest`

**Registry**: GitHub Container Registry (ghcr.io)

**Features**:
- Multi-platform container images (linux/amd64, linux/arm64)
- Lightweight Debian-based images
- Includes AWS CLI for complete functionality
- CI/CD and enterprise deployment ready

## 🚀 Automated Release Pipeline

### GitHub Actions Workflow

**On Release Tag (v*):**
1. **Quality Gates**: Tests, formatting, linting, security audit
2. **Cross-Platform Builds**: Linux x86_64, macOS aarch64, Windows x86_64
3. **Cargo Publish**: Automatic publishing to crates.io
4. **GitHub Release**: Binaries and distribution packages
5. **Homebrew Update**: Automatic tap repository update
6. **Container Build**: Multi-platform images to GitHub Container Registry

### Distribution Artifacts

**GitHub Releases Include:**
```
aws-assume-role-linux              # Linux x86_64 binary
aws-assume-role-macos              # macOS Apple Silicon binary  
aws-assume-role-windows.exe        # Windows binary (Git Bash)
aws-assume-role-bash.sh            # Universal wrapper script
aws-assume-role-cli-v1.2.x.tar.gz  # Complete package with installer
aws-assume-role-cli-v1.2.x.zip     # Windows-friendly package
*.sha256                           # Checksums for verification
```

## 🔧 Local Development & Testing

### Build All Platforms
```bash
./scripts/build-releases.sh
```

### Create Distribution Packages
```bash
./scripts/release.sh package 1.2.x
```

### Test Installation Methods
```bash
# Test direct binary installation
cd releases/dist/aws-assume-role-cli-v1.2.x
./INSTALL.sh

# Test Homebrew formula locally
brew audit --strict packaging/homebrew/aws-assume-role.rb
brew install --build-from-source packaging/homebrew/aws-assume-role.rb

# Test container build
docker build -t aws-assume-role:test .
docker run --rm aws-assume-role:test awsr --version
```

## 📋 Installation Commands Summary

Once released, users can install using:

```bash
# Cargo (Rust Package Manager)
cargo install aws-assume-role

# Direct Binary Download (All Platforms)
curl -L https://github.com/holdennguyen/aws-assume-role/releases/latest/download/aws-assume-role-cli.tar.gz | tar -xz
cd aws-assume-role-cli-* && ./INSTALL.sh

# Homebrew (macOS/Linux)
brew tap holdennguyen/tap
brew install aws-assume-role

# Container (Any Docker-compatible platform)
docker pull ghcr.io/holdennguyen/aws-assume-role:latest
docker run --rm -v ~/.aws:/home/awsuser/.aws ghcr.io/holdennguyen/aws-assume-role:latest awsr --help
```

## 🎯 Why This Streamlined Approach?

### **Focused Quality**
- **4 channels** instead of 6+ reduces maintenance complexity
- Higher quality and reliability for supported methods
- Faster release cycles with fewer dependencies

### **Broad Coverage**
- **Cargo**: Native Rust ecosystem, always latest version
- **Direct binaries**: Works on any system, enterprise-friendly
- **Homebrew**: Popular choice for developers on macOS/Linux
- **Containers**: Modern deployment, CI/CD integration

### **Simplified Maintenance**
- **Single CI/CD pipeline** handles all distribution
- **Automated publishing** reduces manual work
- **Consistent experience** across all platforms

### **Enterprise Ready**
- **Direct binaries**: No external dependencies
- **Container images**: Standardized deployment
- **Homebrew**: Trusted by development teams

## 🔍 Testing Matrix

### Platforms Tested
- ✅ **Linux x86_64**: Ubuntu, CentOS, Alpine
- ✅ **macOS Apple Silicon**: M1/M2 Macs
- ✅ **Windows Git Bash**: Windows 10/11 with Git Bash

### Installation Methods Tested
- ✅ **Direct Download**: All platforms with universal installer
- ✅ **Homebrew**: macOS and Linux installation
- ✅ **Container**: Docker Desktop, Linux Docker, CI/CD systems

### Verification Steps
```bash
# After installation, verify functionality
awsr --version                     # Version information
awsr verify                        # System compatibility check
awsr configure --help              # Command availability
```

## 📚 Distribution Strategy

### **Primary Target**: Direct Binary Downloads
- **Reason**: Works everywhere, no dependencies
- **Users**: Enterprise, air-gapped environments, Windows users
- **Priority**: Highest

### **Developer Target**: Cargo
- **Reason**: Native Rust ecosystem, always latest version
- **Users**: Rust developers, CLI tool enthusiasts
- **Priority**: High

### **Secondary Target**: Homebrew
- **Reason**: Popular with developers, trusted ecosystem
- **Users**: macOS and Linux developers
- **Priority**: High

### **Specialized Target**: Container Images
- **Reason**: Modern deployment, CI/CD integration
- **Users**: DevOps teams, containerized environments
- **Priority**: Medium

---

**Maintenance**: This streamlined approach reduces maintenance burden while providing broad platform coverage and high-quality user experience across all supported distribution methods. 