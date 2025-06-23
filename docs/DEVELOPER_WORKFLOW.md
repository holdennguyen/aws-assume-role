# 🛠️ Developer Workflow Guide

This guide outlines the standard end-to-end process for development, testing, and releasing the AWS Assume Role CLI. The workflow is centered around the unified developer script: `./dev-cli.sh`.

## 📋 Table of Contents

- [Quick Start](#-quick-start)
- [The Core Workflow: Day-to-Day Development](#-the-core-workflow-day-to-day-development)
- [Creating a Local Distribution Package for Testing](#-creating-a-local-distribution-package-for-testing)
- [The Release Workflow: Publishing a New Version](#-the-release-workflow-publishing-a-new-version)
- [Developer CLI (`dev-cli.sh`) Reference](#-developer-cli-dev-clish-reference)
- [Troubleshooting](#-troubleshooting)

---

## 🚀 Quick Start

Get your development environment set up in a few steps.

### 1. Install Toolchain
This is a one-time setup for cross-compilation from macOS.

```bash
# Install required tools via Homebrew
brew install musl-cross mingw-w64 cmake

# Add Rust targets for Linux and Windows
rustup target add x86_64-unknown-linux-musl
rustup target add x86_64-pc-windows-gnu
```

### 2. Clone and Build
Clone the repository and run the build command to generate all required binaries.

```bash
# Clone the repository
git clone https://github.com/holdennguyen/aws-assume-role.git
cd aws-assume-role

# Build all cross-platform binaries
./dev-cli.sh build
```

### 3. Run Quality Checks
Verify your setup is working correctly by running the standard quality checks.

```bash
# Run all checks (format, lint, test, build)
./dev-cli.sh check
```
If all checks pass, you are ready to start development!

---

## 🔄 The Core Workflow: Day-to-Day Development

This is the standard process for adding features, fixing bugs, and contributing to the project.

### Step 1: Create a Feature Branch
Always start your work from an up-to-date `main` branch.

```bash
git checkout main
git pull origin main
git checkout -b feature/your-new-feature
```

### Step 2: Write Code and Tests
Implement your changes. Remember to add or update tests to cover your new code.

### Step 3: Run Quality Checks (The Golden Rule)
Before **every** commit, run the `check` command. This single command validates all project quality standards and prevents CI failures.

```bash
# Run all quality checks
./dev-cli.sh check
```

The `check` command will automatically fix any formatting issues. If it reports other errors (linting, tests, build), fix them and re-run the command until it passes.

### Step 4: Commit and Push
Once all checks pass, commit your work and push it to your feature branch.

```bash
# Add your changes
git add .

# Commit your work
git commit -m "feat: A descriptive commit message"

# Push your branch
git push origin feature/your-new-feature
```

### Step 5: Create a Pull Request
Open a pull request in GitHub from your feature branch to the `develop` branch.

---

## 📦 Creating a Local Distribution Package for Testing

Before creating an official release, you can build a complete, distributable package locally to test the end-to-end user experience, including the installer.

```bash
# Build the binaries, create archives, and generate checksums
./dev-cli.sh package <version>
```
This command will create a `releases/dist` directory containing the `.tar.gz` and `.zip` archives, mimicking the final assets of a GitHub Release.

---

## 🎯 The Release Workflow: Publishing a New Version

This process is for maintainers and should only be started after all features for a new version have been merged into the `develop` branch.

### Phase 1: Prepare the Release
Use the `release` command to update the version number in all necessary files and create release notes.

```bash
# Prepare the release with the new version number
./dev-cli.sh release <version>
```

### Phase 2: Validate on CI (Critical Step)
Commit the version bump and push to `develop`. **Do not proceed until all CI checks pass.**

```bash
# Commit the version bump
git add . && git commit -m "🔖 Prepare release v<version>"

# Push to the integration branch
git push origin develop
```
> **CRITICAL**: Go to the GitHub Actions page and wait for the workflow run on the `develop` branch to complete successfully.

### Phase 3: Tag and Publish
**Only after CI has passed**, create and push a Git tag. This action will trigger the automated release pipeline.

```bash
# Create and push the annotated tag
git tag -a v<version> -m "Release v<version>"
git push origin v<version>
```

### Phase 4: Finalize
After the release pipeline succeeds, merge `develop` into `main` to bring the production branch up to date.

```bash
git checkout main
git pull origin main
git merge develop
git push origin main
```

---

## 🛠️ Developer CLI (`dev-cli.sh`) Reference

The `./dev-cli.sh` script is the single entry point for all common tasks.

-   `check`: Runs all pre-commit quality checks (format, lint, test, build). Use this before every commit.
-   `build`: Builds all cross-platform binaries. This is required for running shell integration tests.
-   `package <version>`: Creates a full, local distributable package (`.tar.gz`, `.zip`) for end-to-end testing.
-   `release <version>`: Prepares for a new release (updates version and creates release notes).
-   `help`: Displays the help message.

---

## 🔧 Troubleshooting

-   **Shell integration tests are failing?**
    -   You likely need to build the release binaries first. Run `./dev-cli.sh build`.
-   **CI is failing, but my code works locally?**
    -   Ensure you ran `./dev-cli.sh check` and it passed before you committed. This script runs the same checks as the CI pipeline.
-   **Cross-compilation is failing?**
    -   Verify that you have installed the toolchain described in the [Quick Start](#-quick-start) section. 