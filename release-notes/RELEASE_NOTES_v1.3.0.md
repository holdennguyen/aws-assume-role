# 🚀 AWS Assume Role CLI v1.3.0 Release Notes

**Release Date**: December 2024
**Focus**: CI/CD Resilience, Developer Workflow Automation & Cross-Platform Builds

## 🎯 Overview

Version 1.3.0 is a landmark release focused on solidifying the project's foundations. We have introduced a **resilient CI/CD pipeline**, a powerful **pre-commit script** to automate quality checks, and a **fully cross-platform build system**. This release also includes a comprehensive documentation overhaul and a license alignment to AGPLv3, ensuring clarity and consistency across the entire project.

## ✨ New Features

### Cross-Platform Build Infrastructure
-   **Complete Toolchain Setup**: Full cross-compilation support with `musl-cross` for static Linux builds and `mingw-w64` for Windows.
-   **Universal Shell Integration**: A single, intelligent bash wrapper (`aws-assume-role-bash.sh`) replaces the previous platform-specific scripts, providing a consistent experience on Linux, macOS, and Windows (Git Bash).
-   **Automated Build Scripts**: The `./scripts/build-releases.sh` and `./scripts/release.sh` scripts now handle the entire cross-platform build, package, and release lifecycle.

## 🔧 Critical Fixes

-   **CI/CD Pipeline Reliability**:
    -   **Fixed Artifact Naming Conflicts**: Resolved the `409 Conflict` error in GitHub Actions by ensuring unique artifact names for each platform (`binary-ubuntu-latest`, etc.), unblocking the CI pipeline.
    -   **Upgraded Deprecated Actions**: Modernized the workflow by upgrading `actions/upload-artifact`, `actions/download-artifact`, and `actions/cache` from v3 to v4.
-   **Windows CI Compilation**:
    -   **Resolved Build Failure**: Fixed the Windows build failure by using conditional compilation (`#[cfg(unix)]`) for Unix-specific file permission tests in the shell integration test suite.

## 🏗️ Improvements

-   **Developer Workflow Automation**:
    -   **New Pre-Commit Script**: Introduced `./scripts/pre-commit-hook.sh` to automate all quality checks (format, clippy, tests, build) before committing. This is now the recommended workflow to prevent CI failures.
    -   **Safe Release Process**: Documented and implemented a "release from develop" strategy, where releases are tagged only after all CI checks pass on the `develop` branch.
-   **Comprehensive Documentation Overhaul**:
    -   **Simplified and Modernized**: All documentation in the `docs/` directory has been reviewed and updated to be concise and relevant.
    -   **Architecture Update**: `ARCHITECTURE.md` was rewritten to reflect the modern architecture using the **AWS SDK for Rust** (instead of shelling out to the AWS CLI).
    -   **Redundant Documents Removed**: Deleted the outdated `RELEASE.md` and consolidated its relevant content into the `DEVELOPER_WORKFLOW.md`, which is now the single source of truth for the development lifecycle.
-   **License Alignment**:
    -   **Corrected Project License**: Updated all license references in `Cargo.toml`, `README.md`, `Dockerfile`, and CI workflows from MIT to **AGPL-3.0-or-later** to match the official `LICENSE` file.
-   **Test Suite Enhancement**:
    -   The test suite was expanded from 59 to **79 tests** to cover the universal wrapper and other new functionality.

## 📚 Technical Details

-   **Cross-Compilation Targets**:
    -   Linux: `x86_64-unknown-linux-musl` (static linking)
    -   macOS: `aarch64-apple-darwin` (Apple Silicon & Intel via Rosetta)
    -   Windows: `x86_64-pc-windows-gnu` (MinGW)
-   **License**: `AGPL-3.0-or-later`

## 🚀 Migration Guide

-   **For End Users**: No breaking changes. The tool will continue to function as before. The new universal wrapper is fully backward compatible.
-   **For Developers**: It is highly recommended to start using the **pre-commit script** to validate changes locally. See `docs/DEVELOPER_WORKFLOW.md` for details.

## 🙏 Acknowledgments

This release was a major effort in improving the stability, reliability, and developer experience of the project. Thanks to the robust tooling in the Rust ecosystem and GitHub Actions, we now have a world-class CI/CD and development workflow.

---

**Full Changelog**: [v1.2.1...v1.3.0](https://github.com/holdennguyen/aws-assume-role/compare/v1.2.1...v1.3.0)

<!-- 
CHECKLIST - Remove before publishing:
□ Update all {PLACEHOLDERS} with actual values
□ Remove empty sections
□ Verify all links work
□ Test installation commands
□ Check changelog link is correct
□ Proofread for typos and clarity
--> 