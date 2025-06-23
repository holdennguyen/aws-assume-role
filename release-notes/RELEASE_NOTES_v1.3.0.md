# 🚀 AWS Assume Role CLI v1.3.0 Release Notes

**Release Date**: 2025-06-23
**Focus**: Developer Experience and CI/CD Streamlining

## 🎯 Overview

This release overhauls the developer workflow by introducing a unified `dev-cli.sh` script, which simplifies building, testing, and packaging. We've eliminated multiple disparate scripts in favor of a single, intuitive entry point. This version also includes critical bug fixes to the CI pipeline and test suite, making the development process more robust and reliable. The primary goal was to streamline all development and release operations, preparing the project for more consistent and faster updates.

## ✨ New Features

### Developer Experience
- **Unified Developer CLI (`dev-cli.sh`)**: Introduced a single, powerful script to handle all common development tasks (`check`, `build`, `package`, `release`). This replaces the previous collection of individual scripts, creating one source of truth for all operations.
- **Local Distribution Packaging (`./dev-cli.sh package`)**: Added a new command to build and package the application into `.tar.gz` and `.zip` archives, complete with SHA256 checksums. This allows for end-to-end testing of release artifacts locally before a final release.

## 🔧 Bug Fixes

### Platform Compatibility
- **Windows Path Resolution**: Fixed a critical bug where the application failed to resolve configuration paths correctly on Windows. This ensures that the CLI now functions reliably across all supported operating systems.

### CI/CD and Testing
- **Robust Shell Integration Tests**: Reworked the shell integration tests to be more resilient. The tests now focus on functional validation rather than brittle string matching, preventing failures due to minor changes in script comments or output formatting.
- **Corrected Build Script Logic**: Fixed a critical bug in the `build-releases.sh` script that was overwriting the correct, universal `aws-assume-role-bash.sh` wrapper with an older, incorrect version during the build process.
- **CLI Argument Handling**: Resolved a bug in `dev-cli.sh` where version arguments were not being correctly passed to the backend release and packaging scripts, causing the commands to fail silently.

## ️ Improvements

### Installation
- **Apple Silicon (ARM64) Homebrew Support**: The Homebrew formula has been updated to provide a native binary for Apple Silicon (M1/M2/M3) Macs, resulting in better performance and removing the need for Rosetta 2 for this application.

### Tooling and Automation
- **Automated Code Formatting**: The pre-commit check (`./dev-cli.sh check`) now automatically formats all code using `cargo fmt`, ensuring consistent style across the codebase without manual intervention.
- **Build-time Environment Checks**: The `build-releases.sh` script now includes validation checks to ensure the required cross-compilation toolchains (e.g., `zig`) are installed, preventing build failures due to a misconfigured environment.
- **Simplified Release Command**: The release preparation command was simplified from `./dev-cli.sh release prepare <version>` to the more intuitive `./dev-cli.sh release <version>`.

### Documentation
- **Rewritten Developer Workflow**: The `docs/DEVELOPER_WORKFLOW.md` has been completely rewritten to be more concise and is now centered around the new `dev-cli.sh`, providing a clear and simple guide for contributors.
- **Consolidated Memory Bank**: Updated and consolidated the `memory-bank/` documentation to accurately reflect the new, streamlined architecture and development processes.

## ⚠️ Breaking Changes

There are no breaking changes for end-users of the `aws-assume-role` CLI. The changes in this release are focused on the developer and contribution workflow.

## 📥 Installation

Installation methods remain unchanged.

### Package Managers
\`\`\`bash
# Cargo
cargo install aws-assume-role

# Homebrew (macOS/Linux)
brew tap holdennguyen/tap
brew install aws-assume-role
\`\`\`

### Direct Download
Download platform-specific binaries from the [releases page](https://github.com/holdennguyen/aws-assume-role/releases/tag/v1.3.0).

---

**Full Changelog**: [v1.2.0...v1.3.0](https://github.com/holdennguyen/aws-assume-role/compare/v1.2.0...v1.3.0)

<!-- 
CHECKLIST - Remove before publishing:
□ Update all {PLACEHOLDERS} with actual values
□ Remove empty sections
□ Verify all links work
□ Test installation commands
□ Check changelog link is correct
□ Proofread for typos and clarity
--> 