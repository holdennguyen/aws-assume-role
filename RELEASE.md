# 🚀 Release Guide

Complete guide for releasing AWS Assume Role CLI, including version management, testing, and distribution.

## 📋 Release Process Overview

### Release Types

**Major Release (x.0.0)**
- Breaking changes
- Major new features
- API changes

**Minor Release (1.x.0)**
- New features
- Enhancements
- Backward compatible

**Patch Release (1.2.x)**
- Bug fixes
- Security updates
- Documentation updates

## 🔄 Release Workflow

### **Phase 1: Pre-Release Preparation**

#### 1. Version Planning
```bash
# Determine next version based on changes
# Current: v1.2.0
# Next examples:
# - v1.2.1 (patch: bug fixes)
# - v1.3.0 (minor: new features)
# - v2.0.0 (major: breaking changes)
```

#### 2. Update Version
```bash
# Use automated version updater
./scripts/update-version.sh 1.2.1

# This updates:
# - Cargo.toml version
# - Documentation references
# - Package configurations (Homebrew, APT, RPM)
# - Docker tags
```

#### 3. Create Release Notes
```bash
# Create comprehensive release notes
# Location: releases/multi-shell/RELEASE_NOTES_v1.2.1.md
# Include:
# - New features
# - Bug fixes
# - Breaking changes
# - Migration guide (if needed)
# - Known issues
```

### **Phase 2: Quality Assurance**

#### 4. Complete Testing Suite
```bash
# Run all tests (59 total)
cargo test

# Expected output:
# test result: ok. 59 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

# Run with verbose output
cargo test -- --nocapture

# Platform-specific testing
cargo test --test integration_tests
cargo test --test shell_integration_tests
```

#### 5. Code Quality Validation
```bash
# Format check (CRITICAL)
cargo fmt --check

# Clippy validation (zero warnings policy)
cargo clippy -- -D warnings

# Security audit
cargo audit

# Performance benchmarks
cargo bench
```

#### 6. Cross-Platform Build Testing
```bash
# Build all release binaries
./build-releases.sh

# Verify binaries work correctly
./releases/multi-shell/aws-assume-role-macos --version
./releases/multi-shell/aws-assume-role-unix --version
./releases/multi-shell/aws-assume-role.exe --version

# Test installation scripts
./releases/multi-shell/INSTALL.sh --test
./releases/multi-shell/INSTALL.ps1 -Test
```

### **Phase 3: Release Creation**

#### 7. Git Workflow
```bash
# Ensure on develop branch with latest changes
git checkout develop
git pull origin develop

# Create release branch
git checkout -b release/v1.2.1

# Commit version updates and release notes
git add .
git commit -m "release: prepare v1.2.1"
git push origin release/v1.2.1

# Create pull request to master
# Title: "Release v1.2.1"
# Include release notes in PR description
```

#### 8. Master Branch Merge
```bash
# After PR approval, merge to master
git checkout master
git pull origin master
git merge release/v1.2.1
git push origin master

# Create and push git tag
git tag -a v1.2.1 -m "Release v1.2.1"
git push origin v1.2.1

# Merge back to develop
git checkout develop
git merge master
git push origin develop
```

### **Phase 4: Distribution**

#### 9. GitHub Release
1. Go to [GitHub Releases](https://github.com/holdennguyen/aws-assume-role/releases)
2. Click "Draft a new release"
3. Choose tag: `v1.2.1`
4. Release title: `AWS Assume Role CLI v1.2.1`
5. Copy release notes from `RELEASE_NOTES_v1.2.1.md`
6. Upload binaries from `releases/multi-shell/`:
   - `aws-assume-role-cli-v1.2.1-YYYYMMDD.tar.gz`
   - Individual binaries and scripts
7. Publish release

#### 10. Automated Package Publishing

**GitHub Actions automatically publishes to:**

- ✅ **Cargo (crates.io)**: Rust package manager
- ✅ **Homebrew**: macOS/Linux package manager
- ✅ **APT (Launchpad PPA)**: Debian/Ubuntu packages
- ✅ **COPR**: Fedora/CentOS/RHEL packages
- ✅ **Docker**: Container images

**Manual Verification:**
```bash
# Verify package manager updates (wait 10-30 minutes)
brew search aws-assume-role
apt search aws-assume-role
dnf search aws-assume-role
cargo search aws-assume-role

# Verify container images
docker pull ghcr.io/holdennguyen/aws-assume-role:v1.2.1
docker pull ghcr.io/holdennguyen/aws-assume-role:latest
```

## ✅ Release Checklist

### **Pre-Release Validation**
- [ ] **Version Updated**: All files show correct version number
- [ ] **Release Notes Created**: Comprehensive notes in `RELEASE_NOTES_v1.2.x.md`
- [ ] **All Tests Pass**: 59/59 tests passing (`cargo test`)
- [ ] **Code Formatted**: No formatting issues (`cargo fmt --check`)
- [ ] **No Clippy Warnings**: Clean clippy output (`cargo clippy -- -D warnings`)
- [ ] **Security Audit Clean**: No critical vulnerabilities (`cargo audit`)
- [ ] **Binaries Built**: All platform binaries generated and tested
- [ ] **Installation Scripts Tested**: Unix and Windows installers work
- [ ] **Documentation Updated**: README and guides reflect current version

### **Release Creation**
- [ ] **Release Branch Created**: `release/v1.2.x` branch exists
- [ ] **Pull Request Created**: PR from release branch to master
- [ ] **PR Approved**: Code review completed
- [ ] **Master Updated**: Release merged to master branch
- [ ] **Git Tag Created**: Version tag `v1.2.x` pushed
- [ ] **Develop Updated**: Changes merged back to develop

### **Distribution Validation**
- [ ] **GitHub Release Published**: Release visible on GitHub
- [ ] **Binaries Uploaded**: All release artifacts attached
- [ ] **Cargo Published**: Package available on crates.io
- [ ] **Homebrew Updated**: Formula updated in tap
- [ ] **APT Package Available**: PPA updated with new version
- [ ] **COPR Package Available**: Fedora COPR updated
- [ ] **Docker Images Published**: Containers available in registry

### **Post-Release Verification**
- [ ] **Installation Testing**: Package managers install correctly
- [ ] **Functionality Testing**: Basic CLI operations work
- [ ] **Documentation Links**: All links point to correct versions
- [ ] **CI/CD Pipeline**: All checks passing on master
- [ ] **User Communication**: Release announced (if applicable)

## 🔧 Manual Publishing (Backup)

If automated publishing fails, use manual processes:

### Cargo (crates.io)
```bash
# Ensure logged in
cargo login

# Publish to crates.io
cargo publish

# Verify publication
cargo search aws-assume-role
```

### Homebrew
```bash
# Update Homebrew formula
cd packaging/homebrew
# Edit aws-assume-role.rb with new version and SHA256
brew audit --strict aws-assume-role.rb
brew test aws-assume-role.rb

# Submit to personal tap
git add aws-assume-role.rb
git commit -m "Update aws-assume-role to v1.2.1"
git push origin main
```

### APT (Launchpad PPA)
```bash
# Build source package
cd packaging/apt
debuild -S -sa

# Upload to Launchpad
dput ppa:holdennguyen/aws-assume-role aws-assume-role_1.2.1-1_source.changes
```

### COPR (Fedora)
```bash
# Submit build to COPR
copr build-package holdennguyen/aws-assume-role \
  --name aws-assume-role \
  --git-url https://github.com/holdennguyen/aws-assume-role.git \
  --git-branch v1.2.1
```

## 🚨 Release Troubleshooting

### Common Issues

**❌ Tests Failing**
- **Solution**: Fix all test failures before proceeding
- **Command**: `cargo test -- --nocapture` for detailed output

**❌ Formatting Issues**
- **Solution**: Run `cargo fmt` and commit changes
- **Prevention**: Always run `cargo fmt --check` before release

**❌ Clippy Warnings**
- **Solution**: Fix all warnings, don't suppress them
- **Command**: `cargo clippy -- -D warnings`

**❌ Binary Build Failures**
- **Solution**: Check cross-compilation setup
- **Command**: `cargo build --release --target <target-triple>`

**❌ Package Manager Publishing Fails**
- **Solution**: Check credentials and repository access
- **Fallback**: Use manual publishing methods above

### Emergency Procedures

**Critical Bug in Released Version:**
1. Create hotfix branch from master: `git checkout -b hotfix/v1.2.2`
2. Fix the critical issue
3. Follow abbreviated release process (skip feature testing)
4. Release as patch version (v1.2.2)
5. Communicate urgency to users

**Rollback Release:**
1. Remove Git tag: `git tag -d v1.2.1 && git push origin :refs/tags/v1.2.1`
2. Delete GitHub release
3. Yank from Cargo: `cargo yank --version 1.2.1`
4. Contact package maintainers for removal

## 📊 Release Metrics

### Success Criteria
- [ ] **Download Statistics**: Monitor GitHub release downloads
- [ ] **Package Manager Adoption**: Track installations via different channels
- [ ] **User Feedback**: Monitor issues and discussions
- [ ] **Performance**: No regression in benchmarks
- [ ] **Security**: No new vulnerabilities introduced

### Monitoring
```bash
# Check download statistics
# GitHub Insights > Traffic > Releases

# Monitor package manager stats
brew analytics --install aws-assume-role
# (APT and COPR stats available in respective dashboards)

# Monitor for issues
# GitHub Issues, Discussions, and community feedback
```

## 🎯 Release Strategy

### Release Cadence
- **Patch Releases**: As needed for bug fixes (monthly)
- **Minor Releases**: Quarterly for new features
- **Major Releases**: Annually or for breaking changes

### Version Support
- **Current Version**: Full support and updates
- **Previous Minor**: Security fixes only
- **Older Versions**: Community support only

### Communication Channels
- GitHub Releases (primary)
- Package manager changelogs
- Documentation updates
- Community discussions (if applicable)

## 📚 Resources

- [Semantic Versioning](https://semver.org/)
- [Cargo Publishing Guide](https://doc.rust-lang.org/cargo/reference/publishing.html)
- [GitHub Releases Documentation](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Launchpad PPA Guide](https://help.launchpad.net/Packaging/PPA) 