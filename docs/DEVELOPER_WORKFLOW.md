# 🛠️ Developer Workflow Guide

Complete development workflow for AWS Assume Role CLI, including the critical safe release process.

## 📋 Table of Contents

- [Development Setup](#-development-setup)
- [Daily Development Flow](#-daily-development-flow)
- [Testing & Quality Gates](#-testing--quality-gates)
- [Safe Release Process](#-safe-release-process-critical)
- [GitHub Actions Integration](#-github-actions-integration)
- [Troubleshooting](#-troubleshooting)

## 🚀 Development Setup

### Cross-Compilation Toolchain (Required for v1.3.0+)

```bash
# Install cross-compilation tools (macOS)
brew install musl-cross mingw-w64 cmake

# Add Rust targets
rustup target add x86_64-unknown-linux-musl
rustup target add x86_64-pc-windows-gnu

# Verify .cargo/config.toml exists with proper linker configuration
```

### Environment Setup

```bash
# Clone and setup
git clone https://github.com/holdennguyen/aws-assume-role.git
cd aws-assume-role

# Build and test
cargo build --release
cargo test  # Should pass all 79 tests

# Test cross-platform builds
./scripts/build-releases.sh
```

## 🔄 Daily Development Flow

### Feature Development Cycle

```bash
# 1. Start clean
git checkout main && git pull origin main
git checkout -b feature/your-feature

# 2. Test-driven development
# - Write failing tests first
# - Implement incrementally
# - Keep commits focused

# 3. MANDATORY quality gates (run frequently)
cargo fmt                          # Format code (ZERO TOLERANCE)
cargo clippy -- -D warnings        # Linting (ZERO TOLERANCE)
cargo test                         # All 79 tests must pass

# 4. Cross-platform validation
./scripts/build-releases.sh        # Build all platforms
./releases/aws-assume-role-macos --version
./releases/aws-assume-role-linux --version
./releases/aws-assume-role-windows.exe --version

# 5. Test universal wrapper
source ./releases/aws-assume-role-bash.sh
awsr --version
```

### Pull Request Workflow

```bash
# Pre-PR checklist (ALL MANDATORY)
git rebase main
cargo test                         # All 79 tests pass
cargo fmt && cargo clippy -- -D warnings
./scripts/build-releases.sh        # Cross-platform validation

# Create PR with conventional commits
# Title: feat:, fix:, docs:, etc.
# CI will run comprehensive validation
```

## 🧪 Testing & Quality Gates

### Test Suite Structure (79 Tests Total)

- **Unit Tests**: 23 tests (core functionality)
- **Integration Tests**: 14 tests (AWS integration)
- **Shell Integration**: 19 tests (universal wrapper)
- **Additional Tests**: 23 tests (utilities)

### Quality Standards (Zero Tolerance)

```bash
# These MUST pass before any commit
cargo fmt --check                  # Zero formatting violations
cargo clippy -- -D warnings       # Zero linting warnings
cargo test                         # 100% test success rate
cargo audit                        # Zero security vulnerabilities
```

## 🎯 Safe Release Process (CRITICAL)

### ⚠️ CRITICAL RULE: Never Tag Before CI Passes

The GitHub Actions workflow can fail for various reasons. **ALWAYS** wait for CI validation before creating release tags.

### Phase 1: Prepare Release

```bash
# 1. Prepare release with unified script
./scripts/release.sh prepare 1.3.0

# This automatically:
# - Updates version in Cargo.toml
# - Creates/updates release notes
# - Validates version consistency
# - Stages changes for commit
```

### Phase 2: Push and Wait for CI ⚠️ CRITICAL

```bash
# 2. Commit and push to develop (NOT main, NOT tagged yet)
git add . && git commit -m "🔖 Prepare release v1.3.0"
git push origin develop

# 3. CRITICAL: Wait for GitHub Actions to PASS
# Visit: https://github.com/holdennguyen/aws-assume-role/actions
# 
# Wait for ALL these to complete successfully:
# ✅ Code Quality & Testing (Ubuntu, Windows, macOS)
# ✅ Cross-Platform Build (Linux musl, macOS, Windows)
# ✅ Security Audit (advisory but should complete)
# 
# DO NOT proceed until you see: ✅ All checks have passed
```

### Phase 3: Create Release Tag

```bash
# 4. ONLY after CI passes, create and push tag
git tag -a v1.3.0 -m "Release v1.3.0

🚀 Major Release: Cross-Platform Build Infrastructure

Key Features:
- Cross-compilation toolchain setup
- Universal bash wrapper for all platforms
- Automated build pipeline
- Enhanced test suite (79 tests)"

git push origin v1.3.0
```

### Phase 4: Automated Release Pipeline

The tag push triggers the full automated release pipeline:

1. **GitHub Release**: Automatic creation with binaries
2. **Cargo Publishing**: If `CARGO_REGISTRY_TOKEN` available
3. **Homebrew Update**: If `HOMEBREW_TAP_TOKEN` available
4. **Container Images**: Multi-platform Docker images
5. **Distribution Packages**: tar.gz/zip with checksums

### ❌ What NOT to Do

```bash
# WRONG - This can cause failed releases
git tag v1.3.0 && git push origin v1.3.0  # DON'T DO THIS

# WRONG - Tagging without CI validation
./scripts/release.sh prepare 1.3.0
git add . && git commit -m "Release v1.3.0"
git tag v1.3.0 && git push origin v1.3.0  # DANGEROUS

# RIGHT - Safe release process
./scripts/release.sh prepare 1.3.0
git add . && git commit -m "🔖 Prepare release v1.3.0"
git push origin develop                    # Push first
# Wait for ✅ GitHub Actions success
git tag v1.3.0 && git push origin v1.3.0  # Then tag
```

## 🤖 GitHub Actions Integration

### Workflow Triggers

- **Every Push/PR**: Quality gates (tests, clippy, format)
- **Push to main/develop**: + Cross-platform builds + Security audit
- **Tag push (v*)**: + Full release pipeline

### Monitoring Workflows

```bash
# Check recent workflow runs (requires gh auth login)
gh run list --limit 5

# Watch current workflow
gh run watch

# View failed run details
gh run view <run-id> --log
```

### Common CI Failures and Fixes

| Failure Type | Common Cause | Fix |
|-------------|--------------|-----|
| Format Check | Unformatted code | `cargo fmt` |
| Clippy Warnings | Linting violations | `cargo clippy -- -D warnings` |
| Test Failures | Broken functionality | Fix code, `cargo test` |
| Cross-Compilation | Missing toolchain | Install musl-cross, mingw-w64 |
| Missing Files | Incomplete build | Ensure all required files exist |

## 🔧 Troubleshooting

### Release Process Issues

**Problem**: GitHub Actions failed after pushing to develop
```bash
# Solution: Fix issues and push again (don't tag yet)
cargo fmt && cargo clippy -- -D warnings && cargo test
git add . && git commit -m "fix: resolve CI issues"
git push origin develop
# Wait for ✅ success, then proceed with tagging
```

**Problem**: Accidentally tagged before CI passed
```bash
# Solution: Remove tag and restart process
git tag -d v1.3.0                    # Delete local tag
git push origin :refs/tags/v1.3.0    # Delete remote tag
# Fix issues, push to develop, wait for CI, then re-tag
```

### Cross-Compilation Issues

**Problem**: Linux musl build fails
```bash
# Check toolchain installation
brew list musl-cross
rustup target list --installed | grep musl

# Reinstall if needed
brew reinstall musl-cross
rustup target add x86_64-unknown-linux-musl
```

**Problem**: Windows cross-compilation fails
```bash
# Check MinGW installation
brew list mingw-w64
rustup target list --installed | grep windows-gnu

# Reinstall if needed
brew reinstall mingw-w64
rustup target add x86_64-pc-windows-gnu
```

### Test Failures

**Problem**: Shell integration tests fail
```bash
# Ensure universal wrapper exists
ls -la releases/aws-assume-role-bash.sh

# Rebuild if missing
./scripts/build-releases.sh

# Test wrapper manually
source ./releases/aws-assume-role-bash.sh
awsr --version
```

## 📊 Quality Metrics

### Current Standards (v1.3.0)

- **Test Coverage**: 79 tests (100% must pass)
- **Code Quality**: Zero clippy warnings, perfect formatting
- **Security**: Zero known vulnerabilities
- **Cross-Platform**: Linux musl, macOS aarch64, Windows MSVC
- **Performance**: < 100ms startup, < 50MB memory usage

### Release Checklist

- [ ] All 79 tests pass locally
- [ ] Code formatted (`cargo fmt`)
- [ ] No clippy warnings (`cargo clippy -- -D warnings`)
- [ ] Cross-platform builds successful
- [ ] Universal wrapper tested
- [ ] Release notes updated
- [ ] Version bumped in Cargo.toml
- [ ] Pushed to develop branch
- [ ] **GitHub Actions passed** ✅
- [ ] Tag created and pushed
- [ ] Release pipeline completed

---

**Remember**: The safe release process is critical. Always wait for GitHub Actions to pass before creating release tags. This prevents failed releases and maintains the project's quality standards. 