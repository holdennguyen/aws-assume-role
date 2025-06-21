# AWS Assume Role - Project Brief

## Project Purpose
AWS Assume Role simplifies switching between AWS IAM roles in CLI environments for users with SSO federated access. This production-ready tool bridges the gap between SSO-based access and IAM role-based permissions.

## Core Features ✅
- **Simple Usage**: Minimal user interaction with intuitive commands
- **Cross-Platform**: macOS, Linux, Windows support (bash, zsh, PowerShell)
- **Prerequisites Verification**: Built-in `verify` command for system checks
- **Multiple Output Formats**: Shell export and JSON formats
- **Persistent Configuration**: Role configurations stored locally

## Target Users
Software engineers who:
- Work with multiple AWS accounts and roles
- Need frequent role switching in CLI workflows
- Have SSO federated access to AWS
- Want streamlined credential management

## Current Status: PRODUCTION READY v1.1.2
**Complete Solution** with automated package distribution across 4 major channels:
- 🦀 **Cargo**: `cargo install aws-assume-role`
- 🍺 **Homebrew**: `brew tap holdennguyen/tap && brew install aws-assume-role`
- 📦 **APT**: `sudo add-apt-repository ppa:holdennguyen/aws-assume-role && sudo apt install aws-assume-role`
- 📦 **YUM/DNF**: `sudo dnf copr enable holdennguyen/aws-assume-role && sudo dnf install aws-assume-role`

## Key Commands
- `awsr configure <role-name>`: Add/update role configurations
- `awsr assume <role-name>`: Assume role and output credentials
- `awsr list`: Display configured roles
- `awsr verify`: Check prerequisites and system configuration
- `awsr remove <role-name>`: Delete role configurations 