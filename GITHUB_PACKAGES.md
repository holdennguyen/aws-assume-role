# 📦 GitHub Packages Integration Guide

This document explains how to use GitHub Packages alongside GitHub Releases for the AWS Assume Role CLI project.

## 🎯 Strategy Overview

### GitHub Releases 📦 (Current)
**Perfect for end-users**:
- ✅ Binary downloads (Windows .exe, macOS, Linux)
- ✅ Multi-shell distribution packages (.tar.gz, .zip)
- ✅ Release notes and changelogs
- ✅ Manual installation workflows

### GitHub Packages 🐳 (New Addition)
**Perfect for developers and automation**:
- 🐳 **Container Registry**: Docker images for containerized deployments
- 📦 **Dependency Management**: Easy integration into other projects
- 🔄 **CI/CD Integration**: Automated deployment workflows
- 👥 **Enterprise Use**: Private package distribution

## 🐳 Container Registry Usage

### For End Users
```bash
# Pull and run the container
docker run -it --rm \
  -v ~/.aws:/home/awsuser/.aws:ro \
  -e AWS_PROFILE \
  ghcr.io/holdennguyen/aws-assume-role:latest

# Or with specific version
docker run -it --rm \
  -v ~/.aws:/home/awsuser/.aws:ro \
  ghcr.io/holdennguyen/aws-assume-role:v1.0.2
```

### For CI/CD Pipelines
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

### For Development Teams
```dockerfile
# Use as base image for AWS-enabled containers
FROM ghcr.io/holdennguyen/aws-assume-role:latest

# Your application code
COPY . /app
WORKDIR /app

# AWS role switching is now available
RUN awsr configure --name dev --role-arn arn:aws:iam::123456789012:role/DevRole
```

## 🔄 Automated Publishing Workflow

Our GitHub Actions workflow automatically publishes to both:

### On Tag Push (e.g., v1.0.2):
1. **GitHub Releases**: Binaries and distribution packages
2. **GitHub Container Registry**: Docker images with multiple tags:
   - `ghcr.io/holdennguyen/aws-assume-role:v1.0.2` (specific version)
   - `ghcr.io/holdennguyen/aws-assume-role:1.0.2` (semver)
   - `ghcr.io/holdennguyen/aws-assume-role:1.0` (major.minor)
   - `ghcr.io/holdennguyen/aws-assume-role:1` (major)
   - `ghcr.io/holdennguyen/aws-assume-role:latest` (latest)

## 📦 Package Discovery

### In Your Repository
1. Go to your GitHub repository
2. Click the **"Packages"** section (right sidebar)
3. View published containers and their versions
4. Get installation commands and usage examples

### Public Registry
- **Container Registry**: `ghcr.io/holdennguyen/aws-assume-role`
- **Crates.io**: `cargo install aws-assume-role`
- **Homebrew**: `brew install holdennguyen/tap/aws-assume-role`

## 🎯 Use Cases by Audience

### 📱 End Users (GitHub Releases)
```bash
# Download and install locally
curl -L -o awsr https://github.com/holdennguyen/aws-assume-role/releases/latest/download/aws-assume-role-linux-x86_64
chmod +x awsr && sudo mv awsr /usr/local/bin/
```

### 🐳 DevOps Teams (GitHub Packages - Containers)
```bash
# Containerized AWS operations
docker run --rm -v ~/.aws:/home/awsuser/.aws:ro \
  ghcr.io/holdennguyen/aws-assume-role:latest \
  awsr assume production
```

### 🔧 Developers (Package Managers)
```bash
# Install as dependency
cargo add aws-assume-role  # Rust projects
brew install holdennguyen/tap/aws-assume-role  # Local development
```

### 🏢 Enterprise (Private Packages)
```bash
# Private container registry for internal tools
docker pull ghcr.io/holdennguyen/aws-assume-role:enterprise
```

## 🚀 Benefits of This Dual Approach

### Broader Reach
- **GitHub Releases**: Direct binary downloads, broad compatibility
- **GitHub Packages**: Integration into modern DevOps workflows

### Better User Experience
- **Casual Users**: Simple download and install
- **Power Users**: Container-based workflows, CI/CD integration
- **Developers**: Package manager integration

### Automated Distribution
- **Single Source**: One GitHub Actions workflow
- **Multiple Targets**: Releases + Packages published simultaneously
- **Version Consistency**: Same tags across all distribution methods

## 📊 Analytics and Insights

### GitHub Packages Provides:
- Download statistics per version
- Usage analytics across different registries
- Integration with GitHub's dependency graph
- Security vulnerability scanning

### Combined with GitHub Releases:
- Complete picture of distribution and usage
- Multiple installation paths for different user preferences
- Professional presentation for both end-users and developers

## 🔧 Implementation Status

### ✅ Completed
- Docker container configuration
- GitHub Actions workflow for container publishing
- Multi-tag strategy for semantic versioning
- Documentation and usage examples

### 🎯 Next Steps
1. Test the container publishing workflow
2. Verify container functionality
3. Update main README with container usage
4. Monitor package analytics and usage patterns

## 💡 Pro Tips

### For Users
- Use **GitHub Releases** for one-time installations
- Use **GitHub Packages** for automated/containerized workflows

### For Maintainers
- Packages section shows download stats and usage patterns
- Container images are automatically scanned for vulnerabilities
- Can set up automated dependency updates

This dual approach maximizes reach while providing modern DevOps integration capabilities! 🎉 