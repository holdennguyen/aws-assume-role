# 🛠️ Development Context

**MEMORY BANK UPDATE RULE**: This file must be updated whenever development workflows change, new patterns are discovered, tooling is modified, or when explicitly requested with "update memory bank" instruction.

Complete development workflow, patterns, and best practices for AWS Assume Role CLI development.

## 🚀 Current Development Status (v1.3.0)

### **Recent Major Changes (v1.3.0)**
- ✅ **Cross-Compilation Toolchain**: Complete setup for Linux (musl), macOS, Windows
- ✅ **Universal Bash Wrapper**: Consolidated to single wrapper for all platforms
- ✅ **Build Automation**: Enhanced scripts with cross-platform toolchain integration
- ✅ **Test Suite Expansion**: 79 comprehensive tests (updated shell integration tests)
- ✅ **Release Process**: Fully automated with distribution packaging
- ✅ **Documentation Updated**: All docs reflect universal wrapper approach
- ✅ **GitHub Actions Fixed**: Upgraded deprecated actions (v3 to v4) and resolved artifact naming conflicts
- ✅ **Unified Developer CLI**: Single `./dev-cli.sh` script for all development tasks
- ✅ **Local Distribution Testing**: `./dev-cli.sh package <version>` for end-to-end testing
- ✅ **Windows CI Fix**: Cross-platform test compatibility resolved with conditional compilation
- ✅ **Simplified Release Interface**: `./dev-cli.sh release <version>` (removed redundant "prepare" subcommand)
- ✅ **Git Flow Documentation**: Corrected branch strategy documentation to reflect proper Git Flow workflow

### **Current Streamlined Architecture (v1.3.0)**

**Cross-Compilation Infrastructure**:
- `musl-cross` toolchain for Linux static builds
- `mingw-w64` toolchain for Windows cross-compilation  
- `cmake` for native dependencies
- `.cargo/config.toml` with proper linker configuration
- Rust targets: `x86_64-unknown-linux-musl`, `x86_64-pc-windows-gnu`

**Developer Tooling (4 core components)**:
1. `./dev-cli.sh` - **NEW**: The unified developer script for all tasks. This is the primary entry point for developers.
2. `scripts/release.sh` - Streamlined backend for release preparation and local packaging
3. `releases/INSTALL.sh` - Distribution installer for end-users.
4. `releases/UNINSTALL.sh` - Clean uninstaller for end-users.

**Documentation (4 core files)**:
1. `README.md` - Central navigation hub
2. `docs/DEPLOYMENT.md` - Installation & deployment guide
3. `docs/DEVELOPER_WORKFLOW.md` - Complete development guide (updated with correct Git Flow)
4. `docs/ARCHITECTURE.md` - Technical architecture

**GitHub Actions**: Single `ci-cd.yml` with smart triggers and unified pipeline

### **🎯 Real-World Success Story: Windows CI Fix (Dec 2024)**

**Problem**: Windows CI compilation failure due to Unix-specific file permissions code
```rust
// Failed on Windows CI:
use std::os::unix::fs::PermissionsExt;  // ❌ Unix-only module
let mode = permissions.mode();          // ❌ Unix-only method
```

**Detection**: Developer CLI caught formatting issues before push
```bash
./dev-cli.sh check
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
- ✅ Developer CLI prevented CI failure by catching formatting early
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
./dev-cli.sh release <version>

# 2. Commit the version bump and push to 'develop' to trigger CI
git add . && git commit -m "🔖 Prepare release v<version>"
git push origin develop

# 3. CRITICAL: Wait for GitHub Actions to PASS on 'develop'.

# 4. ONLY after CI passes, create and push the release tag
git tag -a v<version> -m "Release v<version>"
git push origin v<version>

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

### **Local Distribution Testing**
Before creating an official release, you can test the complete end-to-end user experience locally.

```bash
# Create a full distributable package for testing
./dev-cli.sh package <version>

# This creates releases/dist/ with .tar.gz and .zip archives
# Test the installation process with these local artifacts
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
./dev-cli.sh release <version>

# 2. Push to develop and WAIT for CI
git add . && git commit -m "🔖 Prepare release v<version>"
git push origin develop

# 3. Check GitHub Actions status
# Visit: https://github.com/holdennguyen/aws-assume-role/actions
# Wait for ✅ All checks have passed

# 4. ONLY after CI success, create tag
git tag -a v<version> -m "Release v<version>"
git push origin v<version>

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

# 5. Build with unified command
./dev-cli.sh build
```

### **Universal Wrapper Development Pattern**
```bash
# Single wrapper script approach (major simplification from v1.2.x)
# File: releases/aws-assume-role-bash.sh

# Platform detection pattern:
case "$(uname -s)" in
    Linux*)     os_type="linux" ;;
    Darwin*)    os_type="macos" ;;
    MINGW*|MSYS*|CYGWIN*) os_type="windows" ;;
    *)          echo "Unsupported operating system" >&2; exit 1 ;;
esac

# Binary selection pattern:
local binary_name="aws-assume-role-$os_type"
if [ "$os_type" = "windows" ]; then
    binary_name="aws-assume-role-windows.exe"
fi

# Role assumption pattern:
if [ "$1" = "assume" ]; then
    eval $("$binary_path" assume "$2" "${@:3}" --format export)
else
    "$binary_path" "$@"
fi
```

### **CRITICAL: Quality Gate Pattern**
```bash
# The developer CLI is the single quality gate
./dev-cli.sh check

# This command:
# 1. Formats code automatically (cargo fmt)
# 2. Runs linting (cargo clippy -- -D warnings)
# 3. Runs all tests (cargo test)
# 4. Validates build (cargo build --release)
# 5. Provides clear feedback on any issues

# MUST be run before every commit to prevent CI failures
```

### **Local Distribution Testing Pattern**
```bash
# Create full distributable package for end-to-end testing
./dev-cli.sh package <version>

# This creates:
# - releases/dist/aws-assume-role-cli-v<version>.tar.gz
# - releases/dist/aws-assume-role-cli-v<version>.zip
# - SHA256 checksums for both archives
# - All required binaries and scripts

# Test the complete user experience:
# 1. Extract the archive
# 2. Run the installer
# 3. Test the awsr command
# 4. Verify role assumption works
```

## 🔧 Development Environment Setup

### **Required Tools (macOS)**
```bash
# Install cross-compilation toolchain
brew install musl-cross mingw-w64 cmake

# Add Rust targets
rustup target add x86_64-unknown-linux-musl
rustup target add x86_64-pc-windows-gnu

# Verify setup
rustup target list --installed | grep -E "(musl|windows-gnu)"
```

### **Development Commands Reference**
```bash
# Quality checks (run before every commit)
./dev-cli.sh check

# Build binaries for all platforms
./dev-cli.sh build

# Create local distribution package for testing
./dev-cli.sh package <version>

# Prepare for release
./dev-cli.sh release <version>

# Show help
./dev-cli.sh help
```

## 📊 Quality Metrics & Standards

### **Current Standards (v1.3.0)**
- **Test Coverage**: 79 tests (100% must pass)
- **Code Quality**: Zero clippy warnings, perfect formatting
- **Security**: Zero known vulnerabilities
- **Cross-Platform**: Linux musl, macOS aarch64, Windows MSVC
- **Performance**: < 100ms startup, < 50MB memory usage

### **Release Checklist**
- [ ] All 79 tests pass locally (`./dev-cli.sh check`)
- [ ] Cross-platform builds successful (`./dev-cli.sh build`)
- [ ] Local distribution package tested (`./dev-cli.sh package <version>`)
- [ ] Release preparation complete (`./dev-cli.sh release <version>`)
- [ ] Pushed to develop branch
- [ ] **GitHub Actions passed** ✅
- [ ] Tag created and pushed
- [ ] Release pipeline completed

---

**Last Updated**: December 2024 - Unified developer CLI and local distribution testing complete
**Next Review**: When significant changes occur or upon explicit request

## 🎯 Development Setup (Consolidated)

### **One-Time Setup**

**Prerequisites**:
- **Rust**: Version 1.70 or newer
- **Git**: For source control
- **Homebrew** (macOS): For installing the cross-compilation toolchain

**Repository Setup**:
```bash
git clone https://github.com/holdennguyen/aws-assume-role.git
cd aws-assume-role
```

**Cross-Compilation Toolchain (Required for Release Builds)**:
```bash
# Install required tools via Homebrew
brew install musl-cross mingw-w64 cmake

# Add the Rust target platforms
rustup target add x86_64-unknown-linux-musl
rustup target add x86_64-pc-windows-gnu
```

**Project Structure**:
```bash
# Verify project structure
tree
```