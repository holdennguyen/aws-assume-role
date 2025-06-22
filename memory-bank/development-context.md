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

### **Current Streamlined Architecture (v1.3.0)**

**Cross-Compilation Infrastructure**:
- `musl-cross` toolchain for Linux static builds
- `mingw-w64` toolchain for Windows cross-compilation  
- `cmake` for native dependencies
- `.cargo/config.toml` with proper linker configuration
- Rust targets: `x86_64-unknown-linux-musl`, `x86_64-pc-windows-gnu`

**Scripts (5 total)**:
1. `scripts/build-releases.sh` - Cross-platform builds with toolchain
2. `scripts/release.sh` - Unified release management (507 lines)
3. `scripts/install.sh` - Universal installer (355 lines)
4. `releases/INSTALL.sh` - Distribution installer (direct binary)
5. `releases/UNINSTALL.sh` - Clean uninstaller

**Documentation (4 core files)**:
1. `README.md` - Central navigation hub
2. `docs/DEPLOYMENT.md` - Installation & deployment guide
3. `docs/DEVELOPER_WORKFLOW.md` - Complete development guide
4. `docs/ARCHITECTURE.md` - Technical architecture

**GitHub Actions**: Single `ci-cd.yml` with smart triggers and unified pipeline

## 🔄 Enhanced Development Workflow (v1.3.0)

### **⚡ Cross-Platform Development Flow**

```bash
# Enhanced Development Lifecycle with Cross-Compilation
Phase 1: Development → Feature branch → Cross-platform build → Test → PR → Merge to main
Phase 2: Release     → Version bump → Cross-compile → Package → Tag → Automated release
Phase 3: Maintenance → Monitor → Bug fixes → Documentation updates
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

# 3. MANDATORY Quality Gates (run frequently)
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

**CRITICAL PATTERN: Formatting Requirements**
```bash
# ANY code modification requires immediate formatting
# CI has ZERO TOLERANCE for formatting violations
# This pattern has been observed in multiple CI failure cycles

# After ANY code change:
cargo fmt                          # MANDATORY - never skip this
git add . && git commit -m "feat: your change"
```

**Pull Request Workflow:**
```bash
# 1. Pre-PR checklist (ALL MANDATORY)
git rebase main                     # Clean history
cargo test                         # All 79 tests pass (expanded from 59)
cargo fmt && cargo clippy -- -D warnings # Code quality gates
./scripts/build-releases.sh        # Cross-platform build validation

# 2. Create PR to main branch
# Title: Use conventional commits (feat:, fix:, docs:, etc.)
# Description: Link issues, describe changes, testing done
# CI will run comprehensive validation automatically

# 3. Address review feedback and re-validate
```

### **🎯 Phase 2: Release Process (Enhanced v1.3.0)**

**Enhanced Release Workflow with Cross-Compilation:**
```bash
# 1. Prepare release with unified script
./scripts/release.sh prepare 1.3.0

# This automatically:
# - Updates version in Cargo.toml
# - Creates release notes from template
# - Validates version consistency
# - Stages changes for commit

# 2. Build cross-platform binaries
./scripts/release.sh build

# This automatically:
# - Builds Linux static (musl) binary
# - Builds macOS Apple Silicon binary
# - Builds Windows binary via MinGW
# - Creates universal bash wrapper
# - Validates all binaries

# 3. Create distribution packages
./scripts/release.sh package 1.3.0

# This automatically:
# - Creates distribution directory structure
# - Packages tar.gz and zip archives
# - Generates checksums
# - Includes documentation and installation scripts

# 4. Commit, tag, and push
git add . && git commit -m "🔖 Release v1.3.0"
git tag -a v1.3.0 -m "Release v1.3.0"
git push origin main && git push origin v1.3.0

# 5. GitHub Actions automatically handles:
# - Quality gates (tests, clippy, format)
# - Cross-platform builds (Linux, macOS, Windows)
# - Package publishing (Cargo, GitHub releases)
# - Release artifact creation
```

**GitHub Actions Pipeline (Enhanced)**:
```yaml
# Smart trigger system:
# - Every push/PR: Quality gates (test, clippy, format)
# - Push to main/develop: + Cross-platform builds
# - Tag push (v*): + Release pipeline with publishing

# Enhanced pipeline handles:
# 1. Quality Gates: 79 tests, formatting, linting, security audit
# 2. Cross-Platform Builds: Linux musl, macOS aarch64, Windows MinGW
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
# - Check GitHub Actions for failures
# - Review automated releases
# - Monitor package manager publishing
# - Validate cross-platform builds

# 4. Documentation maintenance
# - Keep README.md current with features
# - Update DEPLOYMENT.md for new installation methods
# - Maintain memory-bank/ for AI context
# - Update release notes for each version
```

## 🎯 Critical Development Patterns (Enhanced v1.3.0)

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

### **Automated Release Pattern (Enhanced)**
```bash
# Three-phase automated release process:
# 1. Preparation (local)
./scripts/release.sh prepare 1.3.0  # Version update + release notes

# 2. Building (local or CI)
./scripts/release.sh build          # Cross-platform builds
./scripts/release.sh package 1.3.0 # Distribution packaging

# 3. Publishing (automated via GitHub Actions)
git tag v1.3.0 && git push origin v1.3.0  # Triggers full pipeline

# Local development and CI use identical tools and processes
# Same validation, build, and packaging logic everywhere
```

## 📊 Quality Standards & Metrics (Enhanced v1.3.0)

### **Zero-Tolerance Quality Gates**
- ✅ **Formatting**: `cargo fmt --check` must pass (zero violations)
- ✅ **Linting**: `cargo clippy -- -D warnings` must pass (zero warnings)  
- ✅ **Testing**: All 79 tests must pass (100% success rate)
- ✅ **Security**: `cargo audit` must pass (zero vulnerabilities)
- ✅ **Cross-Platform**: All 3 platforms must build successfully

### **Test Coverage (79 Tests Total)**
- **Unit Tests**: 23 tests covering core functionality
- **Integration Tests**: 14 tests covering AWS integration
- **Shell Integration**: 19 tests covering wrapper scripts
- **Cross-Platform**: Tests run on Ubuntu, Windows, macOS

### **Performance Standards**
- **Startup Time**: < 100ms for basic commands
- **Memory Usage**: < 10MB peak memory usage
- **Binary Size**: < 5MB for release binaries
- **Build Time**: < 2 minutes for complete cross-platform build

## 🛠️ Development Environment Setup

### **Required Tools**
```bash
# Rust toolchain
rustup update stable
rustup target add x86_64-pc-windows-gnu
rustup target add aarch64-apple-darwin

# Development tools
cargo install cargo-audit          # Security auditing
cargo install cross               # Cross-platform builds

# Platform-specific requirements
# macOS: Xcode command line tools
# Windows: Git Bash (for testing)
# Linux: Standard build tools
```

### **IDE Configuration**
```json
// VS Code settings.json
{
    "rust-analyzer.checkOnSave.command": "clippy",
    "rust-analyzer.checkOnSave.extraArgs": ["--", "-D", "warnings"],
    "editor.formatOnSave": true,
    "[rust]": {
        "editor.defaultFormatter": "rust-lang.rust-analyzer"
    }
}
```

## 🎯 Future Development Considerations

### **Immediate Focus**
1. **Maintain Quality**: Zero-defect releases, comprehensive testing
2. **User Experience**: Gather feedback on consolidated documentation
3. **Stability**: Monitor streamlined architecture for issues
4. **Security**: Continue proactive security practices

### **Architectural Decisions**
- **Universal Bash Wrapper**: Consistent experience across platforms
- **Streamlined Scripts**: Reduced complexity and maintenance burden
- **Unified CI/CD**: Single source of truth for automation
- **Focused Platforms**: Quality over quantity approach

### **Technical Debt Management**
- **Documentation**: Keep consolidated docs current and accurate
- **Dependencies**: Regular updates and security monitoring
- **Testing**: Maintain comprehensive coverage as features grow
- **Performance**: Monitor and optimize for speed and resource usage

---

**Last Updated**: December 2024 - Post cross-compilation setup and test suite expansion
**Next Review**: When development workflows change or upon explicit request 