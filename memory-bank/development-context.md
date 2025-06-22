# 🛠️ Development Context

**MEMORY BANK UPDATE RULE**: This file must be updated whenever development workflows change, new patterns are discovered, tooling is modified, or when explicitly requested with "update memory bank" instruction.

Complete development workflow, patterns, and best practices for AWS Assume Role CLI development.

## 🚀 Current Development Status (December 2024 - v1.3.0)

### **Recent Major Changes (v1.3.0)**
- ✅ **Cross-Compilation Toolchain**: Complete setup for Linux (musl), macOS, Windows
- ✅ **Universal Bash Wrapper**: Consolidated to single wrapper for all platforms
- ✅ **Build Automation**: Enhanced scripts with cross-platform toolchain integration
- ✅ **Test Suite Expansion**: 79 comprehensive tests (updated shell integration tests)
- ✅ **Release Process**: Fully automated with distribution packaging
- ✅ **Documentation Updated**: All docs reflect universal wrapper approach
- ✅ **GitHub Actions Fixed**: Upgraded deprecated actions (v3 to v4) and resolved artifact naming conflicts.
- ✅ **Pre-Commit Script**: Automated quality gates preventing CI failures (Dec 2024)
- ✅ **Windows CI Fix**: Cross-platform test compatibility resolved with conditional compilation

### **Current Streamlined Architecture (v1.3.0)**

**Cross-Compilation Infrastructure**:
- `musl-cross` toolchain for Linux static builds
- `mingw-w64` toolchain for Windows cross-compilation  
- `cmake` for native dependencies
- `.cargo/config.toml` with proper linker configuration
- Rust targets: `x86_64-unknown-linux-musl`, `x86_64-pc-windows-gnu`

**Scripts (6 total)**:
1. `scripts/build-releases.sh` - Cross-platform builds with toolchain
2. `scripts/release.sh` - Unified release management (507 lines)
3. `scripts/install.sh` - Universal installer (355 lines)
4. `scripts/pre-commit-hook.sh` - **NEW**: Automated quality gates (prevents CI failures)
5. `releases/INSTALL.sh` - Distribution installer (direct binary)
6. `releases/UNINSTALL.sh` - Clean uninstaller

**Documentation (4 core files)**:
1. `README.md` - Central navigation hub
2. `docs/DEPLOYMENT.md` - Installation & deployment guide
3. `docs/DEVELOPER_WORKFLOW.md` - Complete development guide
4. `docs/ARCHITECTURE.md` - Technical architecture

**GitHub Actions**: Single `ci-cd.yml` with smart triggers and unified pipeline

### **🎯 Real-World Success Story: Windows CI Fix (Dec 2024)**

**Problem**: Windows CI compilation failure due to Unix-specific file permissions code
```rust
// Failed on Windows CI:
use std::os::unix::fs::PermissionsExt;  // ❌ Unix-only module
let mode = permissions.mode();          // ❌ Unix-only method
```

**Detection**: Pre-commit script caught formatting issues before push
```bash
./scripts/pre-commit-hook.sh
# 🔍 Running pre-commit quality checks...
# ❌ Code formatting issues found!
# 💡 Fix with: cargo fmt
```

**Solution**: Cross-platform conditional compilation
```rust
// Fixed with platform-specific compilation:
#[cfg(unix)]
fn test_unix_executable_permissions() { /* Unix-specific code */ }

#[cfg(windows)]  
fn test_windows_file_existence() { /* Windows-compatible code */ }
```

**Outcome**: 
- ✅ Pre-commit script prevented CI failure by catching formatting early
- ✅ Cross-platform compatibility maintained
- ✅ All 79 tests pass on Windows, macOS, and Linux
- ✅ Safe release process validated - no broken CI pipeline

**Key Learning**: Pre-commit script is essential for cross-platform development

## 🔄 The Standard Development Workflow (v1.3.0)

### **The "Safe Release Process"**

This process, enforced by the `DEVELOPER_WORKFLOW.md` and the `release.sh` script, is the required method for creating new releases. It is designed to be robust and prevent broken releases.

**Core Principles**:
1.  **Single Quality Gate**: `scripts/pre-commit-hook.sh` is the one command to run for all local validation.
2.  **Release from `develop`**: The `develop` branch is the integration point for releases.
3.  **CI Before Tagging**: A release tag is **only** created after all checks have passed on the `develop` branch.
4.  **`master` is Production**: The `master` branch contains the history of successful, tagged releases.

### **📋 Phase 1: Feature Development**

**The Standard Daily Cycle:**
```bash
# 1. Start from a clean master branch
git checkout master && git pull origin master
git checkout -b feature/your-feature

# 2. Implement your changes and add tests

# 3. Run the standard quality checks
#    This is the only validation command you need.
./scripts/pre-commit-hook.sh

# 4. Commit when all checks pass
git add .
git commit -m "feat: your descriptive commit message"

# 5. Push and create a pull request to the 'develop' branch
git push origin feature/your-feature
```

### **🎯 Phase 2: The SAFE Release Workflow**

This workflow begins after all features for a release have been merged into the `develop` branch.

**The Official Release Steps:**
```bash
# 1. Prepare the release with the unified script
#    This updates the version in Cargo.toml and other files.
./scripts/release.sh prepare 1.3.0

# 2. Commit the version bump
git add . && git commit -m "🔖 Prepare release v1.3.0"

# 3. Push to the 'develop' branch to trigger CI
git push origin develop

# 4. CRITICAL: Wait for GitHub Actions to PASS
#    Do not proceed until all checks are green for your commit on the 'develop' branch.

# 5. ONLY after CI passes, create and push the release tag
git tag -a v1.3.0 -m "Release v1.3.0"
git push origin v1.3.0

# The tag push triggers the automated release pipeline in GitHub Actions.

# 6. Finalize by merging 'develop' into 'master'
git checkout master
git pull origin master
git merge develop
git push origin master
```

**CRITICAL PATTERN: Never Tag Before CI Passes**
The entire safety of the workflow depends on this rule. Pushing a tag to `develop` before CI has validated the commit can lead to a broken release.

```bash
# WRONG:
git push origin develop && git push origin v1.3.0 # Pushing tag immediately is dangerous

# RIGHT:
git push origin develop
# ... wait for CI ...
git push origin v1.3.0 # Push tag only after CI passes
```

### **📋 Phase 1: Feature Development (Enhanced)**

**Daily Development Cycle with Cross-Compilation:**
```bash
# 1. Start with clean environment
git checkout main && git pull origin main
git checkout -b feature/your-feature

# 2. Test-Driven Development
# - Write failing tests first
# - Implement incrementally
# - Keep commits focused

# 3. RECOMMENDED: Pre-Commit Script (ENHANCED v1.3.0)
./scripts/pre-commit-hook.sh        # ✅ Comprehensive quality gates in one command

# Alternative manual approach (more error-prone):
cargo fmt                          # Format code (ZERO TOLERANCE)
cargo clippy -- -D warnings        # Linting (ZERO TOLERANCE)
cargo test                         # All 79 tests must pass
cargo test --test integration_tests # Integration validation
cargo test --test shell_integration_tests # Shell wrapper validation

# 4. Cross-platform validation (enhanced)
./scripts/build-releases.sh        # Build all platforms with toolchain
./releases/aws-assume-role-macos --version
./releases/aws-assume-role-linux --version
./releases/aws-assume-role-windows.exe --version

# 5. Test universal wrapper
source ./releases/aws-assume-role-bash.sh
awsr --version                     # Test convenience alias
```

**CRITICAL PATTERN: Cross-Compilation Setup**
```bash
# Ensure cross-compilation toolchain is available
brew install musl-cross mingw-w64 cmake  # macOS setup

# Add Rust targets if not present
rustup target add x86_64-unknown-linux-musl
rustup target add x86_64-pc-windows-gnu

# Verify .cargo/config.toml has proper linker configuration
# Must have CC and AR environment variables for cross-compilation
```

**CRITICAL PATTERN: Pre-Commit Script Usage (NEW - v1.3.0)**
```bash
# RECOMMENDED: Use pre-commit script for all changes
# Prevents CI failures by catching issues locally
# Successfully prevented Windows CI failure in v1.3.0 release

# After ANY code change:
./scripts/pre-commit-hook.sh        # ✅ Comprehensive validation
# If all checks pass:
git add . && git commit -m "feat: your change"

# Real example from v1.3.0:
# Problem: Windows CI failed on Unix-specific permissions code
# Detection: Pre-commit script caught formatting issue before push
# Solution: Fixed formatting, re-ran script, successful commit
```

**LEGACY PATTERN: Manual Formatting (Error-Prone)**
```bash
# Alternative manual approach (more error-prone):
# ANY code modification requires immediate formatting
# CI has ZERO TOLERANCE for formatting violations

# After ANY code change:
cargo fmt                          # MANDATORY - never skip this
git add . && git commit -m "feat: your change"
```

**Pull Request Workflow:**
```bash
# 1. Pre-PR checklist (ENHANCED v1.3.0)
git rebase main                     # Clean history
./scripts/pre-commit-hook.sh        # ✅ Comprehensive quality gates
./scripts/build-releases.sh        # Cross-platform build validation

# Alternative manual approach (more error-prone):
cargo test                         # All 79 tests pass (expanded from 59)
cargo fmt && cargo clippy -- -D warnings # Code quality gates

# 2. Create PR to main branch
# Title: Use conventional commits (feat:, fix:, docs:, etc.)
# Description: Link issues, describe changes, testing done
# CI will run comprehensive validation automatically

# 3. Address review feedback and re-validate
```

### **🎯 Phase 2: SAFE Release Process (CRITICAL - Updated v1.3.0)**

**SAFE Release Workflow - ALWAYS Wait for CI:**
```bash
# 1. Prepare release with unified script
./scripts/release.sh prepare 1.3.0

# This automatically:
# - Updates version in Cargo.toml
# - Creates release notes from template
# - Validates version consistency
# - Stages changes for commit

# 2. Commit and push to develop (NOT main, NOT tagged yet)
git add . && git commit -m "🔖 Prepare release v1.3.0"
git push origin develop

# 3. CRITICAL: Wait for GitHub Actions to PASS
# Check GitHub Actions status at: https://github.com/holdennguyen/aws-assume-role/actions
# - Quality gates must pass (tests, clippy, format)
# - Cross-platform builds must succeed
# - Security audit should complete (advisory)
# 
# DO NOT proceed until you see: ✅ All checks have passed

# 4. ONLY after CI passes, create and push tag
git tag -a v1.3.0 -m "Release v1.3.0

🚀 Major Release: Cross-Platform Build Infrastructure & Universal Shell Integration

Key Features:
- Complete cross-compilation toolchain setup
- Universal bash wrapper for all platforms
- Automated build pipeline with distribution packaging
- Static Linux builds for maximum compatibility"

git push origin v1.3.0

# 5. Tag push triggers full automated release pipeline:
# - GitHub release creation
# - Cargo publishing (if CARGO_REGISTRY_TOKEN available)
# - Homebrew tap update (if HOMEBREW_TAP_TOKEN available)
# - Container image publishing
```

**CRITICAL PATTERN: Never Tag Before CI Passes**
```bash
# WRONG - This can cause failed releases:
git tag v1.3.0 && git push origin v1.3.0  # DON'T DO THIS

# RIGHT - Wait for CI validation:
git push origin develop                    # Push first
# Wait for ✅ GitHub Actions success
git tag v1.3.0 && git push origin v1.3.0  # Then tag
```

**GitHub Actions Pipeline (Enhanced)**:
```yaml
# Smart trigger system:
# - Every push/PR: Quality gates (test, clippy, format)
# - Push to main/develop: + Cross-platform builds + Security audit
# - Tag push (v*): + Release pipeline with publishing

# Enhanced pipeline handles:
# 1. Quality Gates: 79 tests, formatting, linting, security audit
# 2. Cross-Platform Builds: Linux musl, macOS aarch64, Windows MSVC
# 3. Universal Wrapper: Single bash script for all platforms
# 4. Release Pipeline: GitHub releases, Cargo publishing, distribution packages
# 5. Graceful Handling: Missing secrets, build failures, clear errors
```

### **🔧 Phase 3: Maintenance & Monitoring (Enhanced)**

**Ongoing Maintenance Tasks:**
```bash
# 1. Keep dependencies current
cargo update && cargo audit         # Security and dependency updates
cargo test                         # Validate after updates (79 tests)

# 2. Maintain cross-compilation toolchain
brew update && brew upgrade musl-cross mingw-w64 cmake
rustup update                      # Keep Rust toolchain current

# 3. Monitor CI/CD pipeline
# - Check GitHub Actions for failures: https://github.com/holdennguyen/aws-assume-role/actions
# - Review automated releases: https://github.com/holdennguyen/aws-assume-role/releases
# - Monitor package manager publishing
# - Validate cross-platform builds

# 4. Documentation maintenance
# - Keep README.md current with features
# - Update DEPLOYMENT.md for new installation methods
# - Maintain memory-bank/ for AI context
# - Update release notes for each version
```

**GitHub Actions Monitoring:**
```bash
# Check workflow status
gh run list --limit 5              # Recent runs (requires gh auth login)

# Monitor specific workflow
gh run watch                       # Watch current run

# View failed run details
gh run view <run-id> --log         # Detailed logs for debugging
```

## 🎯 Critical Development Patterns (Enhanced v1.3.0)

### **CRITICAL: Safe Release Pattern (NEW)**
```bash
# The ONLY safe way to release:
# 1. Prepare release locally
./scripts/release.sh prepare X.Y.Z

# 2. Push to develop and WAIT for CI
git add . && git commit -m "🔖 Prepare release vX.Y.Z"
git push origin develop

# 3. Check GitHub Actions status
# Visit: https://github.com/holdennguyen/aws-assume-role/actions
# Wait for ✅ All checks have passed

# 4. ONLY after CI success, create tag
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z

# 5. Tag triggers automated release pipeline
```

### **CRITICAL: Cross-Compilation Toolchain Pattern**
```bash
# Complete toolchain setup required for consistent builds
# 1. Install native tools
brew install musl-cross mingw-w64 cmake

# 2. Add Rust targets
rustup target add x86_64-unknown-linux-musl
rustup target add x86_64-pc-windows-gnu

# 3. Configure linkers in .cargo/config.toml
[target.x86_64-unknown-linux-musl]
linker = "x86_64-linux-musl-gcc"

[target.x86_64-pc-windows-gnu]
linker = "x86_64-w64-mingw32-gcc"

# 4. Set environment variables for cross-compilation
export CC_x86_64_unknown_linux_musl=x86_64-linux-musl-gcc
export AR_x86_64_unknown_linux_musl=x86_64-linux-musl-ar
export CC_x86_64_pc_windows_gnu=x86_64-w64-mingw32-gcc
export AR_x86_64_pc_windows_gnu=x86_64-w64-mingw32-ar

# 5. Build with specific targets
cargo build --release --target x86_64-unknown-linux-musl
cargo build --release --target x86_64-pc-windows-gnu
cargo build --release  # Native macOS build
```

### **Universal Wrapper Development Pattern**
```bash
# Single wrapper script approach (major simplification from v1.2.x)
# File: releases/aws-assume-role-bash.sh

# Platform detection pattern:
case "$(uname -s)" in
    Linux*)   binary_path="./aws-assume-role-linux" ;;
    Darwin*)  binary_path="./aws-assume-role-macos" ;;
    MINGW*|MSYS*|CYGWIN*) binary_path="./aws-assume-role-windows.exe" ;;
esac

# Role assumption pattern with eval:
eval $($binary_path assume "$2" "${@:3}" --format export 2>/dev/null)

# Testing pattern for universal wrapper:
source ./releases/aws-assume-role-bash.sh
awsr --version                     # Test alias
awsr list                         # Test functionality
```

### **CRITICAL: Code Formatting Pattern**
```bash
# This pattern has been observed multiple times in CI failures:
# 1. Developer makes code changes
# 2. Forgets to run cargo fmt
# 3. CI fails with formatting violations
# 4. Must fix and re-commit

# SOLUTION: Always format after ANY code change
cargo fmt                          # After every edit session
git add . && git commit            # Never commit unformatted code
```

### **Enhanced Testing Pattern (79 Tests)**
```bash
# Comprehensive test suite structure:
# - 23 unit tests (src/lib.rs, src/main.rs)
# - 14 integration tests (tests/integration_tests.rs)
# - 19 shell integration tests (tests/shell_integration_tests.rs)
# - 23 additional tests (common utilities)

# Cross-platform testing requirements:
#[cfg(test)]
use serial_test::serial;

#[test]
#[serial]
fn test_cross_platform() {
    std::env::set_var("HOME", "/tmp/test");           # Unix
    std::env::set_var("USERPROFILE", "C:\\tmp\\test"); # Windows
    // Test logic here
}

# Shell integration testing pattern:
# Tests now validate single universal wrapper instead of multiple shells
# Focus on cross-platform binary discovery and error handling
# Verify role assumption with eval and --format export
```