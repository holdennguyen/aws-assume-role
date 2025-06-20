# 🚀 Release Guide

This guide covers the complete process for releasing new versions of AWS Assume Role CLI.

## 🎯 Release Process Overview

### 1. Version Management

**Automated Version Updates**:
```bash
# Use the automated script for consistency
./scripts/update-version.sh 1.0.3

# This updates ALL version references:
# - Cargo.toml
# - All package manager configs (10+ files)
# - GitHub Actions workflow
# - Documentation
# - Docker labels
```

**Manual Verification**:
```bash
# Verify version consistency
grep -r "1\.0\.3" packaging/ | wc -l  # Should show multiple matches
grep -r "1\.0\.2" packaging/ | wc -l  # Should show 0 matches after update
```

### 2. Pre-Release Checklist

**Code Quality**:
- [ ] All tests pass: `cargo test`
- [ ] Code builds successfully: `cargo build --release`
- [ ] Binary works correctly: `./target/release/aws-assume-role --version`
- [ ] No linting errors: `cargo clippy`

**Documentation**:
- [ ] README.md updated with new features
- [ ] DEPLOYMENT.md reflects current installation methods
- [ ] Memory bank files updated with latest changes
- [ ] Release notes prepared

**Version Consistency**:
- [ ] All package manager configs use same version
- [ ] GitHub Actions workflow updated
- [ ] Documentation references correct version

### 3. Release Creation

**Tag and Push**:
```bash
# 1. Commit all changes
git add .
git commit -m "🔖 Bump version to v1.0.3"

# 2. Create annotated tag
git tag -a v1.0.3 -m "Release v1.0.3: [Brief description]"

# 3. Push to trigger CI/CD
git push origin master
git push origin v1.0.3
```

**GitHub Actions Automation**:
The workflow automatically:
- ✅ Builds cross-platform binaries
- ✅ Creates GitHub Release with assets
- ✅ Publishes to GitHub Container Registry
- ✅ Publishes to crates.io
- ✅ Builds all package manager packages
- ✅ Creates multi-shell distribution

### 4. Post-Release Tasks

**Package Manager Updates**:
- [ ] Homebrew formula (automated via GitHub Actions)
- [ ] Chocolatey package (automated)
- [ ] APT/RPM packages (automated)
- [ ] AUR package (automated)
- [ ] Cargo/crates.io (automated)

**Verification**:
- [ ] GitHub Release created successfully
- [ ] Container images published to ghcr.io
- [ ] Package managers show new version
- [ ] Download links work correctly

**Communication**:
- [ ] Update project README if needed
- [ ] Announce release in relevant channels
- [ ] Update documentation websites

## 📦 Distribution Channels

### Automated (via GitHub Actions)
1. **GitHub Releases**: Binaries and distribution packages
2. **GitHub Container Registry**: Docker images
3. **Crates.io**: Rust package
4. **Package Managers**: APT, RPM, Chocolatey, AUR

### Manual Updates Required
1. **Homebrew Tap**: Usually automated, but verify
2. **Documentation Sites**: If any external docs exist

## 🔄 Hotfix Process

For critical fixes (like v1.0.1 → v1.0.2):

```bash
# 1. Create hotfix branch (optional)
git checkout -b hotfix/v1.0.3

# 2. Make minimal fixes
# Edit only necessary files

# 3. Update version
./scripts/update-version.sh 1.0.3

# 4. Test thoroughly
cargo test
cargo build --release

# 5. Merge and release
git checkout master
git merge hotfix/v1.0.3
git tag -a v1.0.3 -m "Hotfix v1.0.3: [Critical fix description]"
git push origin master && git push origin v1.0.3
```

## 📋 Release Notes Template

```markdown
# 🚀 AWS Assume Role CLI v1.0.3

**Release Date**: [Date]  
**Type**: [Feature/Hotfix/Major]

## 🎯 What's New

### ✨ New Features
- Feature 1 description
- Feature 2 description

### 🐛 Bug Fixes
- Fix 1 description
- Fix 2 description

### 🔧 Improvements
- Improvement 1
- Improvement 2

## 📦 Installation

### Package Managers
```bash
# Homebrew (macOS/Linux)
brew upgrade aws-assume-role

# Cargo (Rust)
cargo install aws-assume-role --force

# Chocolatey (Windows)
choco upgrade aws-assume-role
```

### Container
```bash
docker pull ghcr.io/holdennguyen/aws-assume-role:v1.0.3
```

## 🔧 Breaking Changes
- None / List any breaking changes

## 📊 Distribution
- **GitHub Releases**: Cross-platform binaries
- **GitHub Packages**: Docker containers
- **Package Managers**: All major platforms
- **Source**: Available for manual compilation

---
**Download**: [GitHub Releases](https://github.com/holdennguyen/aws-assume-role/releases/tag/v1.0.3)
```

## 🛠️ Troubleshooting Release Issues

### Common Problems

**1. Crates.io Version Conflict**
```bash
# Error: crate aws-assume-role@X.X.X already exists
# Solution: Increment version number (can't republish same version)
./scripts/update-version.sh 1.0.4
```

**2. GitHub Actions Failure**
```bash
# Check workflow logs in GitHub Actions tab
# Common fixes:
# - Update secrets (CARGO_REGISTRY_TOKEN)
# - Fix permission issues
# - Verify file paths in workflow
```

**3. Package Manager Issues**
```bash
# APT/RPM: Check package building logs
# Chocolatey: Verify nuspec file format
# Homebrew: Check formula syntax
```

### Emergency Rollback

If a release has critical issues:

```bash
# 1. Delete the problematic tag
git tag -d v1.0.3
git push origin :refs/tags/v1.0.3

# 2. Delete GitHub Release (via web interface)

# 3. Fix issues and re-release with incremented version
./scripts/update-version.sh 1.0.4
```

## 📈 Version Strategy

### Semantic Versioning
- **Major (X.0.0)**: Breaking changes
- **Minor (0.X.0)**: New features, backward compatible
- **Patch (0.0.X)**: Bug fixes, backward compatible

### Current Status
- **Latest**: v1.0.2
- **Next Planned**: v1.0.3 (patch) or v1.1.0 (minor)
- **Breaking Changes**: None planned for 1.x series

### Release Frequency
- **Patch releases**: As needed for critical fixes
- **Minor releases**: Monthly or when significant features accumulate
- **Major releases**: Rarely, only for breaking changes

---

This guide ensures consistent, reliable releases across all distribution channels. The automated tooling minimizes human error and maintains version consistency across the entire ecosystem. 