# 📋 Project Context

**MEMORY BANK UPDATE RULE**: This file must be updated whenever significant project changes occur, including: documentation restructuring, major feature releases, architectural changes, workflow modifications, or when explicitly requested with "update memory bank" instruction.

Complete project overview, current status, and active development context for AWS Assume Role CLI.

## 🎯 Project Brief

### **Core Mission**
AWS Assume Role CLI is a cross-platform command-line tool that simplifies AWS role assumption for developers and DevOps teams. It provides a unified interface for managing temporary AWS credentials across different shells and environments.

### **Primary Goals**
1. **Simplify Role Assumption**: Replace complex AWS CLI commands with simple, memorable commands
2. **Cross-Platform Support**: Work seamlessly on Linux, macOS Apple Silicon, and Windows Git Bash
3. **Shell Integration**: Provide universal bash wrapper for consistent experience
4. **Enterprise Ready**: Support package managers and enterprise deployment scenarios
5. **Security First**: Follow AWS security best practices and maintain audit trails

### **Target Users**
- **Developers**: Need to switch between AWS roles for different projects
- **DevOps Engineers**: Manage multiple AWS accounts and environments
- **Security Teams**: Require auditable and controlled access to AWS resources
- **Enterprise IT**: Need standardized tools for AWS access management

## 🎯 Product Context

### **Problem Statement**

**Current Pain Points**:
- AWS CLI role assumption is verbose and error-prone
- Different syntax required for different shells
- No centralized role management
- Temporary credentials are difficult to manage
- Cross-platform inconsistencies

**Example of Current Complexity**:
```bash
# Current AWS CLI approach (complex)
aws sts assume-role \
  --role-arn "arn:aws:iam::123456789012:role/ProductionRole" \
  --role-session-name "my-session" \
  --duration-seconds 3600 \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
  --output text

# Extract and export credentials manually
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
```

**Our Solution**:
```bash
# AWS Assume Role CLI (simple)
awsr assume production
# Automatically exports credentials to current shell
```

### **Core Value Propositions**

1. **Simplicity**: One command replaces complex AWS CLI operations
2. **Consistency**: Same experience across all platforms and shells
3. **Productivity**: Faster role switching and credential management
4. **Safety**: Built-in validation and error handling
5. **Flexibility**: Configurable for different organizational needs

### **User Experience Goals**

**For Developers**:
- Switch roles in seconds, not minutes
- Remember simple role names, not complex ARNs
- Work the same way in any shell or environment
- Get clear error messages when something goes wrong

**For Organizations**:
- Standardize AWS access patterns across teams
- Deploy through existing package management systems
- Integrate with existing security and audit processes
- Maintain centralized role definitions

## 🚀 Current Status & Active Context

### **Version 1.3.0 Status (Latest)**
- ✅ **Core Functionality**: Complete and stable
- ✅ **Cross-Compilation Toolchain**: Full setup for Linux (musl), macOS (Apple Silicon), Windows
- ✅ **Universal Bash Wrapper**: Single wrapper for all platforms (streamlined from multi-shell approach)
- ✅ **Automated Build Pipeline**: Fully automated unified pipeline
- ✅ **Package Distribution**: Homebrew, Cargo, direct download, container (optimized)
- ✅ **CI/CD Pipeline**: Fully automated unified pipeline
- ✅ **Security**: All vulnerabilities resolved, modern cryptography
- ✅ **Documentation**: Consolidated and streamlined structure
- ✅ **Test Suite**: 79 comprehensive tests (unit, integration, shell) - all passing
- ✅ **Standardized Workflow**: The entire development and release process is now standardized and documented in `DEVELOPER_WORKFLOW.md`.
- ✅ **Unified Developer CLI**: Single `./dev-cli.sh` script for all development tasks
- ✅ **Local Distribution Testing**: `./dev-cli.sh package <version>` for end-to-end testing

### **Recent Major Achievements (v1.3.0)**

**Unified Developer Experience**:
- Created single `./dev-cli.sh` script for all development tasks
- Simplified release process: `./dev-cli.sh release <version>` (removed redundant "prepare" subcommand)
- Added local distribution testing: `./dev-cli.sh package <version>`
- Streamlined `scripts/release.sh` to focus on core backend functions
- Updated all documentation to use unified interface

**Cross-Compilation Infrastructure**:
- Installed complete cross-compilation toolchain on macOS
- `musl-cross` for Linux static linking (`x86_64-linux-musl-gcc`)
- `mingw-w64` for Windows cross-compilation (`x86_64-w64-mingw32-gcc`)
- `cmake` for native dependencies
- Added Rust targets: `x86_64-unknown-linux-musl`, `x86_64-pc-windows-gnu`
- Created `.cargo/config.toml` with proper linkers and environment variables
- Updated build scripts to use musl target for better Linux compatibility

**Universal Wrapper Script Approach**:
- Consolidated from multiple shell-specific wrappers to single universal bash wrapper
- `releases/aws-assume-role-bash.sh` works on Linux, macOS, and Windows Git Bash
- Auto-detects platform and selects appropriate binary
- Includes role assumption with `eval` and `--format export`
- Provides `awsr` convenience alias
- Comprehensive error handling and usage information

**Release Management Automation**:
- Streamlined `scripts/release.sh` for focused release preparation
- Automated build pipeline creates platform binaries and universal wrapper
- Distribution packages with tar.gz and zip archives plus checksums
- Streamlined releases directory managed by automation

**Test Suite Updates**:
- Updated shell integration tests to reflect universal wrapper approach
- 19 shell integration tests now validate single universal wrapper
- Tests verify cross-platform binary discovery, error handling, and usage
- All 79 tests passing (23 unit + 14 integration + 19 shell + 23 additional)

### **Current Architecture (v1.3.0)**

**Cross-Platform Build System**:
- **Linux**: Static musl builds (`x86_64-unknown-linux-musl`) for maximum compatibility
- **macOS**: Native Apple Silicon builds (`aarch64-apple-darwin`)
- **Windows**: MinGW cross-compilation (`x86_64-pc-windows-gnu`)
- **Universal Wrapper**: Single bash script for all platforms

**Streamlined Platform Support**:
- **Linux**: x86_64 static binary with universal bash wrapper
- **macOS**: Apple Silicon (aarch64) binary with universal bash wrapper  
- **Windows**: Git Bash support with .exe binary and universal bash wrapper

**Automated Release Pipeline**:
1. `scripts/build-releases.sh` - Cross-platform builds with proper toolchain
2. `scripts/release.sh` - Streamlined release preparation (version + notes)
3. `releases/INSTALL.sh` - Distribution installer
4. `releases/UNINSTALL.sh` - Clean uninstaller

**Documentation Structure**:
1. `README.md` - Central hub with navigation (root only)
2. `docs/DEPLOYMENT.md` - Installation and deployment guide
3. `docs/DEVELOPER_WORKFLOW.md` - The single source of truth for the development and release lifecycle.
4. `docs/ARCHITECTURE.md` - Technical architecture
5. `release-notes/` - Version history (RELEASE_NOTES_v1.3.0.md)
6. `memory-bank/` - AI agent context (this directory)

**Distribution Channels (Optimized)**:
1. **Direct Binaries**: GitHub Releases with universal bash wrapper and installer
2. **Cargo**: Official Rust package registry (crates.io)
3. **Homebrew**: Personal tap for macOS/Linux developers
4. **Container Images**: GitHub Container Registry for DevOps/CI-CD

### **Key Technical Decisions (v1.3.0)**

**Cross-Compilation Strategy**:
- **Static Linux Builds**: Using musl for maximum compatibility across distributions
- **Native macOS Builds**: Apple Silicon optimized for M1/M2/M3 Macs
- **Windows MinGW**: Cross-compiled from macOS for consistent build environment
- **Universal Wrapper**: Single bash script handles platform detection and binary selection

**Architecture Choices**:
- **Rust Language**: For performance, safety, and cross-platform compatibility
- **AWS SDK for Rust**: Direct integration with AWS APIs, replacing the previous method of shelling out to the AWS CLI.
- **Universal Bash Wrapper**: Single wrapper script for all platforms (major simplification)
- **Configuration Management**: JSON-based user configuration with sensible defaults
- **Static Linking**: Reduce runtime dependencies and improve portability

**Quality Standards**:
- **Zero Clippy Warnings**: Enforced by CI pipeline
- **Mandatory Formatting**: All code must pass `cargo fmt --check`
- **Comprehensive Testing**: 79 tests covering all functionality (expanded test coverage)
- **Cross-Platform Validation**: Every change tested on multiple platforms with real toolchain

### **Critical Patterns & Learnings (Updated v1.3.0)**

**CRITICAL PATTERN: Cross-Compilation Toolchain Management**
- Complete toolchain setup required for consistent builds across platforms
- Proper linker configuration in `.cargo/config.toml` essential
- Environment variables needed for cross-compilation (CC, AR, etc.)
- Static linking (musl) preferred for Linux distribution compatibility
- Pattern: `./dev-cli.sh build` now handles all cross-platform builds.

**Universal Wrapper Pattern**:
- Single bash script more maintainable than multiple shell-specific scripts
- Platform detection with `uname -s` covers Linux, Darwin, MINGW/MSYS/CYGWIN
- Binary discovery pattern: local files first, then PATH fallback
- Error handling pattern: clear messages for unsupported OS or missing binaries
- Role assumption pattern: `eval $($binary_path assume "$2" "${@:3}" --format export)`

**CRITICAL PATTERN: The Developer CLI is Mandatory**
- ALL code modifications must be validated with `./dev-cli.sh check` before committing.
- This single command handles formatting, linting, testing, and building, preventing CI failures.

**Cross-Platform Environment Variables**:
- Windows uses `USERPROFILE`, Unix uses `HOME`
- Production code must check both environment variables
- Tests require `#[serial_test::serial]` to prevent race conditions
- Integration tests must set both variables for cross-platform compatibility

**Automation-Driven Release Workflow**:
- The release process is initiated with `./dev-cli.sh release <version>`.
- The subsequent steps are governed by the **Safe Release Process** documented in `DEVELOPER_WORKFLOW.md`.
- This process requires a successful CI run on the `develop` branch before a release tag can be created and pushed.

**Local Distribution Testing**:
- Use `./dev-cli.sh package <version>` to create full distributable packages locally
- This creates `.tar.gz` and `.zip` archives with checksums for end-to-end testing
- Mimics the exact artifacts that will be published in GitHub releases

## 📈 Progress Summary

### **What's Working Exceptionally Well**

**Core Functionality**:
- ✅ Role assumption works reliably across all platforms
- ✅ Configuration management is robust and user-friendly
- ✅ Error handling provides actionable feedback
- ✅ Universal bash wrapper provides consistent experience

**Development Process**:
- ✅ Streamlined scripts reduce complexity and maintenance
- ✅ Unified GitHub Actions pipeline ensures quality
- ✅ Documentation consolidation improves developer experience
- ✅ Clear separation between user and maintainer documentation
- ✅ Single `./dev-cli.sh` interface simplifies all development tasks

**Distribution & Adoption**:
- ✅ Streamlined distribution (3 channels: binaries, Homebrew, containers)
- ✅ Automated publishing pipeline
- ✅ Enterprise deployment patterns documented
- ✅ Clean, professional user experience
- ✅ Local distribution testing capability

### **Current Focus Areas**

**Maintenance & Quality**:
- Keep documentation up-to-date and accurate
- Monitor and maintain streamlined script architecture
- Ensure CI/CD pipeline remains reliable
- Continue security best practices

**User Experience**:
- Gather feedback on consolidated documentation
- Monitor installation success rates
- Improve error messages based on user reports
- Expand real-world usage examples

**Technical Excellence**:
- Maintain test coverage and quality
- Monitor performance and optimize as needed
- Keep dependencies current and secure
- Plan for future feature requests

### **Known Limitations & Trade-offs**

**Platform Limitations**:
- Windows support requires Git Bash (not native PowerShell/CMD)
- macOS support focused on Apple Silicon (M1/M2)
- Linux support limited to x86_64 architecture

**Architectural Trade-offs**:
- AWS CLI dependency (pro: leverage existing tool, con: external dependency)
- Bash wrapper approach (pro: universal, con: requires bash)
- JSON configuration (pro: human-readable, con: not as flexible as YAML)

## 🎯 Strategic Direction

### **Immediate Priorities**
1. **Maintain Quality**: Keep current functionality stable and reliable
2. **User Feedback**: Gather and respond to user experience feedback
3. **Documentation**: Keep documentation current with any changes
4. **Security**: Continue monitoring and addressing security concerns

### **Future Considerations**
1. **Platform Expansion**: Consider broader platform support if demand exists
2. **Feature Enhancement**: Add features based on user requests
3. **Performance Optimization**: Optimize for speed and resource usage
4. **Community Growth**: Build contributor community and ecosystem

### **Success Metrics**
- **Quality**: Zero-defect releases, 100% test pass rate
- **Usability**: Positive user feedback, low support burden
- **Maintainability**: Low complexity, easy to update and extend
- **Adoption**: Growing usage across different environments

---

**Last Updated**: v1.3.0 release with unified developer CLI and streamlined workflow
**Next Review**: When significant changes occur or upon explicit request 