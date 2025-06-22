# 🚀 Release Guide

Complete guide for releasing AWS Assume Role CLI, including version management, testing, and distribution.

## ⚡ Quick Release Process

```bash
# 1. Update version and create release notes
./scripts/update-version.sh 1.2.1
./scripts/create-release-notes.sh 1.2.1
# (Edit release notes and commit changes)

# 2. Validate quality
cargo fmt --check && cargo clippy -- -D warnings && cargo test

# 3. Release (triggers automated publishing)
git tag -a v1.2.1 -m "Release v1.2.1"
git push origin master && git push origin v1.2.1
```

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

#### 2. Update Version & Create Release Notes
```bash
# STEP 1: Update version across all files
./scripts/update-version.sh 1.2.1

# STEP 2: Create release notes (MANDATORY)
./scripts/create-release-notes.sh 1.2.1

# STEP 3: Edit release notes and fill in all placeholders
# - Update release-notes/README.md index
# - Remove empty sections from release notes
# - Verify all links and installation commands

# CRITICAL: Commit version changes BEFORE creating git tags
# This ensures Cargo.toml version matches the tag for crates.io publishing
git add .
git commit -m "🔖 Bump version to v1.2.1"
```

### **Phase 2: Quality Validation**

#### 3. Comprehensive Testing & Validation
```bash
# Code quality (CRITICAL - must pass before release)
cargo fmt --check                    # Format validation
cargo clippy -- -D warnings          # Zero warnings policy
cargo test                          # All 59 tests must pass
cargo audit                         # Security vulnerability check
cargo bench                         # Performance regression check

# Cross-platform build testing
./build-releases.sh                  # Build all platform binaries
./releases/multi-shell/aws-assume-role-macos --version
./releases/multi-shell/aws-assume-role-unix --version
./releases/multi-shell/aws-assume-role.exe --version
```

### **Phase 3: Release & Distribution**

#### 4. Git Release Workflow
```bash
# Create and push git tag (triggers automated publishing)
git tag -a v1.2.1 -m "Release v1.2.1"
git push origin master
git push origin v1.2.1

# GitHub Actions will automatically:
# - Validate Cargo.toml version matches tag
# - Build cross-platform binaries
# - Publish to crates.io, Homebrew, APT, COPR
# - Create GitHub release with binaries
```

#### 5. Post-Release Verification
```bash
# Wait 10-30 minutes for package managers to update, then verify:
cargo search aws-assume-role         # Should show new version
brew search aws-assume-role          # Homebrew update
docker pull ghcr.io/holdennguyen/aws-assume-role:latest

# Manual GitHub release (if automated release fails):
# 1. Go to GitHub Releases
# 2. Tag v1.2.1 should have auto-created release
# 3. Edit release and copy content from release-notes/RELEASE_NOTES_v1.2.1.md
# 4. Verify all binaries are attached
```

## 🍺 Package Manager Publishing

### Homebrew Formula Maintenance

**CRITICAL**: The Homebrew formula must be updated for every release with correct SHA256 checksums.

#### Required Binaries for GitHub Release
```bash
# Create platform-specific binaries from universal builds
cd releases/multi-shell

# macOS binaries (both architectures)
cp aws-assume-role-macos aws-assume-role-macos-arm64
cp aws-assume-role-macos aws-assume-role-macos-x86_64

# Linux binary
cp aws-assume-role-unix aws-assume-role-linux-x86_64

# Calculate checksums
shasum -a 256 aws-assume-role-macos-arm64 aws-assume-role-macos-x86_64 aws-assume-role-linux-x86_64
```

#### Homebrew Formula Update Process
1. **Upload binaries to GitHub release** (required first)
2. **Clone homebrew-tap repository**:
   ```bash
   git clone https://github.com/holdennguyen/homebrew-tap.git
   ```
3. **Update formula with correct checksums**:
   ```bash
   # Update version and SHA256 checksums in Formula/aws-assume-role.rb
   # ARM64 SHA256: [calculated checksum]
   # x86_64 SHA256: [calculated checksum] 
   # Linux SHA256: [calculated checksum]
   ```
4. **Commit and push changes**:
   ```bash
   cd homebrew-tap
   git add Formula/aws-assume-role.rb
   git commit -m "Update aws-assume-role to v[VERSION]"
   git push origin main
   ```
5. **Clean up**: Remove homebrew-tap directory from main project

#### Automated Publishing Script
Use the enhanced publishing script:
```bash
./scripts/publish-to-package-managers.sh
# Choose option 1: Publish to Homebrew tap
```

**Repository**: https://github.com/holdennguyen/homebrew-tap

## ✅ Release Checklist

### **Pre-Release** 
- [ ] **Version & Release Notes**: Updated via scripts and committed
- [ ] **Quality Gates**: `cargo fmt --check && cargo clippy -- -D warnings && cargo test`
- [ ] **Binaries Built**: `./build-releases.sh` completes successfully

### **Release**
- [ ] **Git Tag**: Created and pushed (`git tag -a v1.2.x -m "Release v1.2.x"`)
- [ ] **GitHub Actions**: All workflows completed successfully
- [ ] **GitHub Release**: Auto-generated with binaries and release notes

### **Verification**
- [ ] **crates.io**: New version published (`cargo search aws-assume-role`)
- [ ] **Homebrew**: Formula updated (`brew search aws-assume-role`)
- [ ] **Docker**: New image available (`docker pull ghcr.io/holdennguyen/aws-assume-role:latest`)
- [ ] **Functionality**: Basic CLI operations work with new version

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

### Emergency Procedures

**Critical Bug in Released Version:**
1. Create hotfix: `git checkout -b hotfix/v1.2.2`
2. Fix the issue and follow abbreviated release process
3. Release as patch version (v1.2.2)

**Rollback Release:**
1. Remove Git tag: `git tag -d v1.2.1 && git push origin :refs/tags/v1.2.1`
2. Delete GitHub release
3. Yank from Cargo: `cargo yank --version 1.2.1`

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

## 📋 Release Information

**Current Version**: v1.2.0

**📖 [View All Release Notes](release-notes/)** | **🔗 [GitHub Releases](https://github.com/holdennguyen/aws-assume-role/releases)**

## 📝 Release Notes Process

### 📝 Mandatory Release Notes

**Every release requires comprehensive release notes before publication.**

#### Quick Process
```bash
# 1. Create release notes using helper script
./scripts/create-release-notes.sh 1.2.1

# 2. Edit the file and fill in all placeholders
# 3. Update release-notes/README.md with new version
# 4. Include in GitHub release
```

#### File Structure
```
release-notes/
├── README.md              # Index of all releases
├── TEMPLATE.md            # Template for new releases
└── RELEASE_NOTES_v{VERSION}.md
```

## 🚨 Troubleshooting

### Common Issues & Solutions

**❌ Version Mismatch on crates.io**
- **Problem**: Wrong version published (e.g., v1.1.2 instead of v1.2.0)
- **Cause**: Git tag created before committing version changes
- **Solution**: Always commit version changes BEFORE creating git tags
- **Prevention**: Follow Step 3 in the workflow above

**❌ Tests Failing**
- **Solution**: Fix all test failures before proceeding: `cargo test -- --nocapture`

**❌ Clippy Warnings**  
- **Solution**: Fix all warnings: `cargo clippy -- -D warnings`

**❌ Package Publishing Fails**
- **Solution**: Check GitHub Actions workflow for errors
- **Fallback**: Use manual publishing commands in sections below 