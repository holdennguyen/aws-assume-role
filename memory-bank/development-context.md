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

**Developer Tooling (3 core components)**:
1. `./dev-cli.sh` - **NEW**: The unified developer script for all tasks. This is the primary entry point for developers.
2. `releases/INSTALL.sh` - Distribution installer for end-users.
3. `releases/UNINSTALL.sh` - Clean uninstaller for end-users.

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

**Key Learning**: A unified developer CLI (`./dev-cli.sh`) is essential for maintaining quality and simplifying cross-platform development.

## 🔄 The Standard Development Workflow (v1.3.0)

The entire development lifecycle is managed through the `./dev-cli.sh` script, as documented in `docs/DEVELOPER_WORKFLOW.md`.

### 📋 Phase 1: Daily Development

**The Standard Cycle:**
```bash
# 1. Start a new feature branch
git checkout main && git pull && git checkout -b feature/your-feature

# 2. Implement changes and add tests

# 3. CRITICAL: Run the standard quality checks before every commit
./dev-cli.sh check

# 4. Commit when all checks pass
git add . && git commit -m "feat: your descriptive commit message"

# 5. Push and create a pull request to 'develop'
git push origin feature/your-feature
```

### 🎯 Phase 2: The SAFE Release Workflow

This workflow begins after all features for a release have been merged into the `develop` branch.

**The Official Release Steps:**
```bash
# 1. Prepare the release with the unified script
./dev-cli.sh release prepare 1.4.0

# 2. Commit the version bump and push to 'develop' to trigger CI
git add . && git commit -m "🔖 Prepare release v1.4.0"
git push origin develop

# 3. CRITICAL: Wait for GitHub Actions to PASS on 'develop'.

# 4. ONLY after CI passes, create and push the release tag
git tag -a v1.4.0 -m "Release v1.4.0"
git push origin v1.4.0

# 5. Finalize by merging 'develop' into 'main'
git checkout main && git merge develop && git push
```

**CRITICAL PATTERN: Never Tag Before CI Passes**
The entire safety of the workflow depends on this rule. Pushing a tag to `develop` before CI has validated the commit can lead to a broken release.

### **Cross-Platform Validation**
To ensure your changes work on all target operating systems, you can build the binaries locally.

```bash
# Build all cross-platform binaries
./dev-cli.sh build

# Verify the binaries were created
ls -l releases/aws-assume-role-*
```

**CRITICAL PATTERN: Developer CLI Usage**
- The `./dev-cli.sh check` command is the **single source of truth** for code quality.
- It prevents CI failures by running the exact same checks locally.
- It must be run before every commit.
- The command will automatically fix formatting issues and report any other errors.

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