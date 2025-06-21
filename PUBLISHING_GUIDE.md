# 📦 AWS Assume Role CLI - Package Publishing Guide

This guide covers publishing the AWS Assume Role CLI to various package managers with automation.

## 🎯 **Supported Package Managers**

- **🦀 Cargo** (Rust Package Manager) - Automated via GitHub Actions
- **🍺 Homebrew** (macOS/Linux) - Personal tap with automation
- **📦 APT** (Debian/Ubuntu) - Launchpad PPA: `ppa:holdennguyen/aws-assume-role`
- **📦 YUM/DNF** (Fedora/CentOS/RHEL) - COPR repository

## 🚀 **Automated Publishing**

### GitHub Actions Workflow

The `.github/workflows/publish-packages.yml` workflow automatically publishes to all package managers when a new release is created:

1. **Homebrew**: Updates personal tap repository
2. **APT**: Builds and uploads to Launchpad PPA
3. **COPR**: Submits build to Fedora COPR
4. **Documentation**: Updates installation commands

### Required Secrets

Configure these secrets in GitHub repository settings:

```bash
# PPA Publishing
PPA_GPG_PRIVATE_KEY     # GPG private key for signing packages
PPA_GPG_PASSPHRASE      # GPG key passphrase

# COPR Publishing  
COPR_CONFIG             # COPR configuration file content
```

## 🔧 **Manual Publishing**

Use the helper script for manual publishing or testing:

```bash
./scripts/publish-to-package-managers.sh
```

### Options:
1. **Publish to Homebrew tap** - Updates personal tap
2. **Prepare PPA package** - Creates source package for PPA
3. **Publish to COPR** - Submits to Fedora COPR
4. **Update documentation** - Updates installation commands
5. **Publish to all** - Runs all publishing steps

## 📋 **Package Manager Setup**

### 1. Homebrew Tap

**Repository**: `https://github.com/holdennguyen/homebrew-tap`

**Formula Location**: `Formula/aws-assume-role.rb`

**Installation**:
```bash
brew tap holdennguyen/tap
brew install aws-assume-role
```

### 2. Launchpad PPA

**PPA**: `ppa:holdennguyen/aws-assume-role`

**Supported Distributions**: Ubuntu 22.04 (Jammy), 24.04 (Noble)

**Installation**:
```bash
sudo add-apt-repository ppa:holdennguyen/aws-assume-role
sudo apt update
sudo apt install aws-assume-role
```

### 3. COPR (YUM/DNF)

**Repository**: `holdennguyen/aws-assume-role`

**Supported Distributions**: Fedora 38, 39, EPEL 9

**Installation**:
```bash
# Fedora
sudo dnf copr enable holdennguyen/aws-assume-role
sudo dnf install aws-assume-role

# CentOS/RHEL
sudo yum copr enable holdennguyen/aws-assume-role  
sudo yum install aws-assume-role
```

### 4. Cargo

**Package**: `aws-assume-role`

**Auto-published**: GitHub Actions publishes to crates.io on release

**Installation**:
```bash
cargo install aws-assume-role
```

## 🔑 **Setup Requirements**

### GPG Key for PPA

1. **Generate GPG key**:
```bash
gpg --full-generate-key
```

2. **Export private key**:
```bash
gpg --export-secret-keys --armor YOUR_EMAIL > private.key
```

3. **Add to GitHub Secrets**:
   - `PPA_GPG_PRIVATE_KEY`: Content of private.key
   - `PPA_GPG_PASSPHRASE`: GPG key passphrase

### COPR Configuration

1. **Create COPR account**: https://copr.fedorainfracloud.org/
2. **Generate API token**: https://copr.fedorainfracloud.org/api/
3. **Create config file**:
```ini
[copr-cli]
login = YOUR_LOGIN
username = holdennguyen
token = YOUR_TOKEN
copr_url = https://copr.fedorainfracloud.org
```
4. **Add to GitHub Secrets**: `COPR_CONFIG` with file content

## 📊 **Publishing Status**

| Package Manager | Status | Installation Command |
|----------------|--------|---------------------|
| 🦀 **Cargo** | ✅ Automated | `cargo install aws-assume-role` |
| 🍺 **Homebrew** | ✅ Automated | `brew tap holdennguyen/tap && brew install aws-assume-role` |
| 📦 **APT** | ✅ Automated | `sudo add-apt-repository ppa:holdennguyen/aws-assume-role && sudo apt install aws-assume-role` |
| 📦 **YUM/DNF** | ✅ Automated | `sudo dnf copr enable holdennguyen/aws-assume-role && sudo dnf install aws-assume-role` |

## 🔄 **Release Process**

1. **Update version** in `Cargo.toml`
2. **Create release** via GitHub (triggers automation)
3. **Monitor workflows** in GitHub Actions
4. **Verify packages** are available in all repositories

## 🐛 **Troubleshooting**

### Common Issues

**PPA Build Failures**:
- Check GPG key is valid and not expired
- Verify changelog format in debian/changelog
- Ensure binary download URLs are correct

**COPR Build Failures**:
- Check RPM spec file syntax
- Verify COPR configuration
- Review build logs in COPR dashboard

**Homebrew Formula Issues**:
- Verify SHA256 checksums match binaries
- Check formula syntax with `brew audit`
- Test installation locally

### Debug Commands

```bash
# Test Homebrew formula
brew audit --strict packaging/homebrew/aws-assume-role.rb

# Validate PPA package
cd aws-assume-role-VERSION
debuild -S -sa --lintian-opts --profile debian

# Test COPR spec
rpmlint packaging/rpm/aws-assume-role.spec
```

## 📚 **Resources**

- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Launchpad PPA Documentation](https://help.launchpad.net/Packaging/PPA)
- [COPR Documentation](https://docs.pagure.org/copr.copr/)
- [Cargo Publishing Guide](https://doc.rust-lang.org/cargo/reference/publishing.html)

---

**Last Updated**: January 2025  
**Version**: 1.1.2 