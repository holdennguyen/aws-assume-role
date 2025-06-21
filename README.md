# AWS Assume Role CLI

A fast, reliable command-line tool for switching between AWS IAM roles across different accounts. Designed for seamless integration with modern development workflows.

## ✨ Features

- 🔄 **Instant role switching** between AWS accounts
- 🔐 **Smart credential management** with automatic region handling
- 🌍 **Universal compatibility** (macOS, Linux, Windows, Git Bash, WSL)
- 📋 **Multiple output formats** (shell exports, JSON)
- 💾 **Persistent configuration** with simple JSON storage
- ⏱️ **Flexible session control** with custom durations
- 🧪 **Comprehensive testing** (59 tests across all platforms)
- 🚀 **Zero-config installation** via package managers

## 🚀 Quick Start

### Installation
```bash
# Homebrew (macOS/Linux) - Recommended
brew tap holdennguyen/tap && brew install aws-assume-role

# Cargo (Rust)
cargo install aws-assume-role

# APT (Ubuntu/Debian)
sudo add-apt-repository ppa:holdennguyen/aws-assume-role && sudo apt install aws-assume-role
```
**→ [Complete installation guide](DEPLOYMENT.md)**

### Basic Usage
```bash
# 1. Verify prerequisites
awsr verify

# 2. Configure a role
awsr configure --name dev --role-arn arn:aws:iam::123456789012:role/DevRole --account-id 123456789012

# 3. Assume the role
awsr assume dev

# 4. Verify current identity
aws sts get-caller-identity
```

## 📖 Commands

| Command | Description | Example |
|---------|-------------|---------|
| `awsr verify` | Check prerequisites | `awsr verify --role dev` |
| `awsr configure` | Add/update role | `awsr configure --name prod --role-arn arn:aws:iam::987654321098:role/ProdRole --account-id 987654321098` |
| `awsr assume` | Switch to role | `awsr assume dev --format json --duration 7200` |
| `awsr list` | Show configured roles | `awsr list` |
| `awsr remove` | Delete role config | `awsr remove dev` |

## 💡 Shell Integration

```bash
# Add to ~/.bashrc or ~/.zshrc
alias assume-dev='eval $(awsr assume dev)'
alias assume-prod='eval $(awsr assume prod)'
alias aws-whoami='aws sts get-caller-identity'
```

## 📚 Documentation

| Guide | Purpose | Audience |
|-------|---------|----------|
| **[DEPLOYMENT.md](DEPLOYMENT.md)** | Installation, prerequisites, enterprise deployment | Users, DevOps |
| **[DEVELOPMENT.md](DEVELOPMENT.md)** | Development setup, testing, contributing | Developers |
| **[RELEASE.md](RELEASE.md)** | Release process and publishing | Maintainers |
| **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** | Technical architecture and design | Technical users |

## 🔧 Configuration

- **Config file**: `~/.aws-assume-role/config.json`
- **Format**: JSON with role definitions
- **Auto-created**: When you add your first role

## 🛠️ Development

### Quick Setup
```bash
git clone https://github.com/holdennguyen/aws-assume-role.git
cd aws-assume-role
cargo build --release
cargo test  # 59 tests across all platforms
```
**→ [Complete development guide](DEVELOPMENT.md)**

### Testing Framework (v1.2.0+)
- **59 total tests**: 23 unit + 14 integration + 22 shell integration
- **Cross-platform**: Ubuntu, Windows, macOS automated validation
- **Shell compatibility**: Bash, Zsh, PowerShell, Fish, CMD
- **Performance benchmarks**: Criterion-based regression detection

## 🔒 Security

- **AWS SDK v1.x**: Modern, secure AWS integration
- **aws-lc-rs cryptography**: AWS-maintained cryptographic backend
- **Clean security audit**: No known vulnerabilities
- **FIPS ready**: Optional FIPS 140-3 compliance

## 📦 Distribution

| Method | Status | Command |
|--------|--------|---------|
| 🦀 **Cargo** | ✅ Live | `cargo install aws-assume-role` |
| 🍺 **Homebrew** | ✅ Live | `brew tap holdennguyen/tap && brew install aws-assume-role` |
| 📦 **APT** | ✅ Live | `sudo add-apt-repository ppa:holdennguyen/aws-assume-role && sudo apt install aws-assume-role` |
| 📦 **YUM/DNF** | ✅ Live | `sudo dnf copr enable holdennguyen/aws-assume-role && sudo dnf install aws-assume-role` |
| 🐳 **Container** | ✅ Live | `docker pull ghcr.io/holdennguyen/aws-assume-role:latest` |

## 🤝 Contributing

1. **Check prerequisites**: [DEPLOYMENT.md](DEPLOYMENT.md)
2. **Development setup**: [DEVELOPMENT.md](DEVELOPMENT.md)
3. **Submit changes**: Follow git flow in development guide
4. **Release process**: [RELEASE.md](RELEASE.md) (maintainers only)

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built with modern Rust ecosystem and AWS SDK v1.x for reliable, secure AWS credential management. 