# 🚀 Release Guide

This guide covers the complete process for releasing new versions of AWS Assume Role CLI, from local development to public distribution.

## 🎯 Complete Release Process Overview

### Phase 1: Local Development & Version Management

#### 1.1 Update Version Across All Components
```bash
# Use the automated script for consistency across ALL files
./scripts/update-version.sh 1.2.0

# This updates ALL version references:
# - Cargo.toml
# - All package manager configs (RPM, APT, Homebrew, etc.)
# - GitHub Actions workflow
# - Dockerfile labels
# - Documentation references
```

#### 1.2 Rebuild Local Binaries for New Version
**CRITICAL**: The `/releases/multi-shell` directory contains pre-built binaries that must be regenerated:

```bash
# Build new release binaries
cargo build --release

# Copy new binaries to multi-shell releases (macOS example)
cp target/release/aws-assume-role releases/multi-shell/aws-assume-role-macos

# For cross-platform builds (if needed locally):
# cargo build --release --target x86_64-unknown-linux-gnu
# cargo build --release --target x86_64-pc-windows-gnu
# cp target/x86_64-unknown-linux-gnu/release/aws-assume-role releases/multi-shell/aws-assume-role-unix
# cp target/x86_64-pc-windows-gnu/release/aws-assume-role.exe releases/multi-shell/
```

#### 1.3 Update Multi-Shell Distribution Scripts
The `create-distribution.sh` script uses git tags, so we need to either:

**Option A: Create temporary local tag for testing**
```bash
git tag -a v1.2.0-local -m "Local testing tag"
cd releases/multi-shell
./create-distribution.sh
git tag -d v1.2.0-local  # Clean up after testing
```

**Option B: Update fallback version in script**
```bash
# Temporarily update the fallback version for local testing
sed -i.bak 's/v1\.1\.2/v1.2.0/' releases/multi-shell/create-distribution.sh
```

#### 1.4 Validate Version Consistency
```bash
# Verify all components show correct version
echo "🔍 Version Validation:"
echo "Cargo.toml: $(grep '^version = ' Cargo.toml)"
echo "Binary: $(./target/release/aws-assume-role --version)"
echo "Multi-shell binary: $(releases/multi-shell/aws-assume-role-macos --version)"
echo "RPM: $(grep '^Version:' packaging/rpm/aws-assume-role.spec)"
echo "APT: $(grep '^Version:' packaging/apt/DEBIAN/control)"
echo "Homebrew: $(grep 'version' packaging/homebrew/aws-assume-role.rb | head -1)"
```

#### 1.5 Create Release Notes (MANDATORY)
**⚠️ CRITICAL**: Always create comprehensive release notes BEFORE merging to master

```bash
# Create release notes file
touch releases/multi-shell/RELEASE_NOTES_v1.2.0.md

# Use the comprehensive template (see memory-bank/development-workflow.md)
# Include:
# - Overview of changes
# - Critical fixes and improvements
# - Testing results matrix
# - Architecture enhancements
# - Security updates
# - Installation instructions
# - Binary update status
```

**Release Notes Must Include:**
- **User Impact**: How changes benefit users
- **Technical Details**: Code examples for major changes
- **Test Matrix**: Platform-specific test results
- **Binary Status**: Which binaries are updated with latest changes
- **Installation Methods**: Updated installation instructions
- **Security Information**: Any security improvements or dependency updates

#### 1.6 Commit Pre-Release Artifacts
```bash
# Commit all pre-release changes together
git add releases/multi-shell/
git commit -m "📦 Prepare v1.2.0 release artifacts

- Updated multi-shell binaries with latest Windows compatibility fixes
- Created comprehensive release notes for v1.2.0
- Verified all local artifacts contain latest code changes
- Ready for production release to master"
```

### Phase 2: Quality Validation

#### 2.1 Comprehensive Testing
```bash
# Run complete test suite (55 tests)
cargo test

# Test categories breakdown:
cargo test --lib                           # Unit tests (23)
cargo test --test integration_tests        # Integration tests (14)
cargo test --test shell_integration_tests  # Shell integration tests (18)

# Performance benchmarks
cargo bench

# Security audit
cargo audit
```

#### 2.2 Build Validation
```bash
# Build release binary
cargo build --release

# Verify binary functionality
./target/release/aws-assume-role --version
./target/release/aws-assume-role --help
```

#### 2.3 Code Quality Checks
```bash
# Formatting check
cargo fmt --all -- --check

# Linting with zero warnings policy
cargo clippy -- -D warnings

# Documentation check
cargo doc --no-deps
```

### Phase 3: Git Flow & CI/CD Validation

#### 3.1 Commit Version Updates
```bash
# Commit all version-related changes
git add .
git commit -m "🔖 Bump version to v1.2.0 across all components

- Updated Cargo.toml version to 1.2.0
- Updated all package manager configurations
- Updated Dockerfile and GitHub Actions
- Regenerated multi-shell release binaries
- Verified all 55 tests passing"
```

#### 3.2 Push to Develop for CI/CD Validation
```bash
# Push to develop branch for CI/CD testing
git push origin develop

# Monitor GitHub Actions:
# 1. All tests pass on Ubuntu, Windows, macOS
# 2. Security audit clean
# 3. Cross-compilation successful
# 4. All quality gates pass
```

### Phase 4: Production Release

#### 4.1 Merge to Master
```bash
# After CI/CD validation passes on develop:
git checkout master
git merge develop
```

#### 4.2 Create Release Tag
```bash
# Create annotated tag for release
git tag -a v1.2.0 -m "Release v1.2.0: Enhanced Security & Comprehensive Testing

🔒 Security Enhancements:
- AWS SDK v1.x with aws-lc-rs cryptographic backend
- Resolved all ring vulnerabilities (RUSTSEC-2025-0009, RUSTSEC-2025-0010)
- Clean security audit with modern dependencies

🧪 Testing Excellence:
- 55 comprehensive tests (23 unit + 14 integration + 18 shell integration)
- Cross-platform validation (Ubuntu, Windows, macOS)
- Shell compatibility testing (Bash, Zsh, PowerShell, Fish, CMD)

📦 Distribution Ready:
- Updated package manager configurations
- Enhanced documentation and development guides
- Complete CI/CD automation"
```

#### 4.3 Push Release
```bash
# Push to trigger automated release process
git push origin master
git push origin v1.2.0

# This triggers GitHub Actions to:
# ✅ Build cross-platform binaries
# ✅ Create GitHub Release with assets
# ✅ Publish to GitHub Container Registry
# ✅ Publish to crates.io
# ✅ Build all package manager packages
# ✅ Create multi-shell distribution
```

## 📁 Understanding the Multi-Shell Releases Directory

### What's in `/releases/multi-shell`?
```
releases/multi-shell/
├── aws-assume-role-macos          # Pre-built macOS binary (ARM64)
├── aws-assume-role-unix           # Pre-built Linux binary (x86_64)
├── aws-assume-role.exe            # Pre-built Windows binary
├── aws-assume-role-bash.sh        # Bash/Zsh wrapper script
├── aws-assume-role-fish.fish      # Fish shell wrapper script
├── aws-assume-role-powershell.ps1 # PowerShell wrapper script
├── aws-assume-role-cmd.bat        # CMD batch wrapper script
├── INSTALL.sh                     # Unix installation script
├── INSTALL.ps1                    # Windows installation script
├── UNINSTALL.sh                   # Unix uninstallation script
├── UNINSTALL.ps1                  # Windows uninstallation script
├── create-distribution.sh         # Distribution package creator
├── README.md                      # Installation instructions
└── dist/                          # Generated distribution packages
    ├── aws-assume-role-cli-v1.2.0-YYYYMMDD.tar.gz
    ├── aws-assume-role-cli-v1.2.0-YYYYMMDD.zip
    └── *.sha256                   # Checksum files
```

### Why These Files Need Manual Updates

1. **Pre-built Binaries**: These are actual compiled executables from previous releases
2. **Version Dependencies**: Scripts reference specific versions
3. **Distribution Packages**: Generated packages contain old binaries
4. **Local Testing**: Allows testing complete distribution before GitHub release

### Automated vs Manual Updates

**Automated by GitHub Actions (on release)**:
- Cross-platform binary compilation
- GitHub Release creation
- Package manager publishing
- Container image publishing

**Manual for Local Development**:
- Local binary regeneration for testing
- Multi-shell distribution validation
- Version consistency verification
- Local testing of complete distribution

## 🔄 Local Development Workflow

### Daily Development
```bash
# 1. Feature development on feature branch
git checkout -b feature/new-feature

# 2. Write tests first (TDD approach)
cargo test test_new_feature -- --ignored

# 3. Implement feature
# ... code changes ...

# 4. Validate all tests
cargo test                              # All 55 tests

# 5. Commit and push feature
git add .
git commit -m "feat: implement new feature"
git push origin feature/new-feature
```

### Pre-Release Preparation
```bash
# 1. Update version across all components
./scripts/update-version.sh 1.2.0

# 2. Rebuild local binaries
cargo build --release
cp target/release/aws-assume-role releases/multi-shell/aws-assume-role-macos

# 3. Validate version consistency
./target/release/aws-assume-role --version
releases/multi-shell/aws-assume-role-macos --version

# 4. Run comprehensive tests
cargo test
cargo audit

# 5. Commit version updates
git add .
git commit -m "🔖 Bump version to v1.2.0"

# 6. Push to develop for CI/CD validation
git push origin develop
```

### Release Execution
```bash
# 1. After CI/CD validation passes
git checkout master
git merge develop

# 2. Create release tag
git tag -a v1.2.0 -m "Release v1.2.0: [description]"

# 3. Push to trigger automated release
git push origin master && git push origin v1.2.0
```

## 🛠️ Troubleshooting Common Issues

### Issue: Multi-Shell Binaries Show Wrong Version
**Cause**: Pre-built binaries not regenerated after version update
**Solution**:
```bash
# Rebuild and replace binaries
cargo build --release
cp target/release/aws-assume-role releases/multi-shell/aws-assume-role-macos
# Repeat for other platforms if cross-compiling locally
```

### Issue: Distribution Script Uses Wrong Version
**Cause**: No git tag exists yet, falls back to default
**Solution**:
```bash
# Option A: Create temporary tag for local testing
git tag -a v1.2.0-local -m "Local testing"
cd releases/multi-shell && ./create-distribution.sh
git tag -d v1.2.0-local

# Option B: Update fallback version temporarily
sed -i.bak 's/v1\.1\.2/v1.2.0/' releases/multi-shell/create-distribution.sh
```

### Issue: Version Inconsistency Across Components
**Cause**: Manual version updates missed some files
**Solution**:
```bash
# Always use the automated script
./scripts/update-version.sh 1.2.0

# Validate all components
grep -r "1\.2\.0" packaging/ Cargo.toml Dockerfile .github/
```

## 📋 Release Checklist Template

### Pre-Release Validation
- [ ] Version updated across all components (`./scripts/update-version.sh`)
- [ ] Local binaries regenerated (`cargo build --release`)
- [ ] Multi-shell binaries updated (`cp target/release/aws-assume-role releases/multi-shell/`)
- [ ] All 55 tests passing (`cargo test`)
- [ ] Security audit clean (`cargo audit`)
- [ ] Binary shows correct version (`./target/release/aws-assume-role --version`)
- [ ] Code quality checks pass (`cargo fmt`, `cargo clippy`)

### CI/CD Validation
- [ ] Changes committed to develop branch
- [ ] Pushed to GitHub (`git push origin develop`)
- [ ] GitHub Actions CI/CD passes
- [ ] All platforms build successfully
- [ ] Cross-platform tests pass

### Release Execution
- [ ] Merged to master (`git checkout master && git merge develop`)
- [ ] Release tag created (`git tag -a v1.2.0 -m "..."`)
- [ ] Pushed to trigger release (`git push origin master && git push origin v1.2.0`)
- [ ] GitHub Release created automatically
- [ ] Package managers updated automatically
- [ ] Container images published

### Post-Release Verification
- [ ] GitHub Release shows correct assets
- [ ] Package managers show new version
- [ ] Container images available
- [ ] Download links work
- [ ] Installation instructions updated

This comprehensive process ensures that every component is properly versioned and validated before release, preventing the multi-shell directory version inconsistency issue. 