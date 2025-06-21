# 📋 Project Context

Complete project overview, current status, and active development context for AWS Assume Role CLI.

## 🎯 Project Brief

### **Core Mission**
AWS Assume Role CLI is a cross-platform command-line tool that simplifies AWS role assumption for developers and DevOps teams. It provides a unified interface for managing temporary AWS credentials across different shells and environments.

### **Primary Goals**
1. **Simplify Role Assumption**: Replace complex AWS CLI commands with simple, memorable commands
2. **Cross-Platform Support**: Work seamlessly on Linux, macOS, and Windows
3. **Shell Integration**: Provide native integration for Bash, Zsh, PowerShell, Fish, and CMD
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

### **Version 1.2.0 Status**
- ✅ **Core Functionality**: Complete and stable
- ✅ **Cross-Platform Support**: Linux, macOS, Windows fully supported
- ✅ **Shell Integration**: 5 shells supported (Bash, Zsh, PowerShell, Fish, CMD)
- ✅ **Package Distribution**: 4+ package managers supported
- ✅ **CI/CD Pipeline**: Fully automated testing and distribution
- ✅ **Security**: All vulnerabilities resolved, modern cryptography

### **Recent Major Achievements**

**Windows Compatibility Breakthrough (v1.2.0)**:
- Resolved all Windows-specific test failures
- Enhanced cross-platform environment variable handling
- Improved integration test coverage for Windows scenarios
- Fixed JSON parsing issues in Windows integration tests

**Testing Framework Maturity**:
- 59 comprehensive tests (14 unit + 23 integration + 22 shell integration)
- 100% test success rate across all platforms
- Automated CI/CD pipeline with zero-tolerance quality gates
- Cross-platform testing on Ubuntu, Windows, and macOS

**Security Upgrade**:
- Migrated to AWS SDK v1.x with `aws-lc-rs` cryptographic backend
- Resolved all ring vulnerabilities (RUSTSEC-2025-0009, RUSTSEC-2025-0010)
- Implemented FIPS-ready cryptography
- Clean security audit results

### **Active Development Focus**

**Current Priorities**:
1. **Documentation Consolidation**: Reducing complexity and improving developer experience
2. **Release Process Optimization**: Streamlining version management and distribution
3. **User Experience Enhancement**: Based on community feedback and usage patterns
4. **Performance Optimization**: Maintaining fast startup times and efficient operations

**Next Sprint Goals**:
- Complete documentation consolidation (17 → 8 files)
- Enhance release automation
- Improve error messages and user guidance
- Expand package manager support

### **Key Technical Decisions**

**Architecture Choices**:
- **Rust Language**: For performance, safety, and cross-platform compatibility
- **AWS CLI Integration**: Leverage existing AWS CLI rather than reimplementing
- **Shell Wrapper Strategy**: Platform-specific scripts for optimal integration
- **Configuration Management**: JSON-based user configuration with sensible defaults

**Quality Standards**:
- **Zero Clippy Warnings**: Enforced by CI pipeline
- **Mandatory Formatting**: All code must pass `cargo fmt --check`
- **Comprehensive Testing**: 59 tests covering all functionality
- **Cross-Platform Validation**: Every change tested on multiple platforms

### **Critical Patterns & Learnings**

**CRITICAL PATTERN: Formatting After Code Changes**
- ANY code modification requires immediate `cargo fmt` application
- CI has zero tolerance for formatting violations
- Pattern observed in multiple CI failure cycles
- Must be documented and enforced in development workflow

**Cross-Platform Environment Variables**:
- Windows uses `USERPROFILE`, Unix uses `HOME`
- Production code must check both environment variables
- Tests require `#[serial_test::serial]` to prevent race conditions
- Integration tests must set both variables for cross-platform compatibility

**Shell Integration Complexity**:
- Each shell requires different syntax for environment variable export
- Wrapper scripts must handle error propagation correctly
- Installation scripts need platform-specific logic
- Testing requires validation of wrapper script content and structure

## 📈 Progress Summary

### **What's Working Well**

**Core Functionality**:
- ✅ Role assumption works reliably across all platforms
- ✅ Configuration management is robust and user-friendly
- ✅ Error handling provides actionable feedback
- ✅ Shell integration feels native in each environment

**Development Process**:
- ✅ Comprehensive testing prevents regressions
- ✅ Automated CI/CD pipeline ensures quality
- ✅ Cross-platform development workflow is established
- ✅ Security practices are mature and effective

**Distribution & Adoption**:
- ✅ Multiple package managers supported
- ✅ Container images available
- ✅ Enterprise deployment patterns documented
- ✅ Installation process is streamlined

### **Areas for Continued Improvement**

**User Experience**:
- Enhance error messages with more specific guidance
- Improve first-time user onboarding experience
- Add more interactive configuration options
- Expand documentation with real-world examples

**Technical Enhancements**:
- Consider native AWS SDK integration to reduce AWS CLI dependency
- Explore caching mechanisms for improved performance
- Add audit logging capabilities for enterprise users
- Implement configuration validation and migration tools

**Community & Ecosystem**:
- Expand package manager support (Chocolatey, Scoop, etc.)
- Create integration examples for popular CI/CD platforms
- Develop plugins or extensions for popular development tools
- Build community contribution guidelines and processes

### **Known Issues & Limitations**

**Current Limitations**:
- Requires AWS CLI v2 to be installed and configured
- Configuration is local to each machine (no cloud sync)
- Limited audit logging capabilities
- No built-in role discovery mechanisms

**Planned Improvements**:
- Native AWS SDK integration (reduce AWS CLI dependency)
- Cloud-based configuration synchronization
- Enhanced audit and logging capabilities
- Automatic role discovery from AWS organizations

### **Success Metrics**

**Quality Metrics**:
- 📊 **Test Coverage**: 59/59 tests passing (100%)
- 📊 **Platform Coverage**: 3/3 platforms supported (Linux, macOS, Windows)
- 📊 **Shell Coverage**: 5/5 major shells supported
- 📊 **Security Score**: Clean audit results, zero critical vulnerabilities

**Adoption Metrics**:
- 📦 **Package Managers**: 4+ supported (Cargo, Homebrew, APT, COPR)
- 🐳 **Container Support**: Docker images available
- 📚 **Documentation**: Comprehensive guides for all use cases
- 🚀 **Release Cadence**: Regular releases with clear changelogs

## 🎯 Strategic Direction

### **Short-Term Objectives (Next 3 Months)**
1. Complete documentation consolidation and optimization
2. Enhance user onboarding experience
3. Expand package manager support
4. Improve error messages and user guidance

### **Medium-Term Goals (Next 6 Months)**
1. Native AWS SDK integration option
2. Configuration synchronization capabilities
3. Enhanced audit and logging features
4. Community contribution framework

### **Long-Term Vision (Next Year)**
1. Industry-standard tool for AWS role management
2. Enterprise feature set with advanced security
3. Plugin ecosystem for extensibility
4. Integration with major development platforms

This project context provides the foundation for understanding the current state, active priorities, and strategic direction of AWS Assume Role CLI development. 