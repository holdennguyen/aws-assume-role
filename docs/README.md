# 📚 Documentation Hub

Welcome to the AWS Assume Role CLI documentation. This directory contains comprehensive guides for different user types and use cases.

## 📋 Documentation Structure

| Document | Purpose | Target Audience |
|----------|---------|-----------------|
| **[📋 Installation & Deployment](DEPLOYMENT.md)** | Complete installation guide, prerequisites, enterprise deployment | **End Users, DevOps Teams** |
| **[👨‍💻 Development Guide](DEVELOPER_WORKFLOW.md)** | Development setup, testing, contributing, release workflow | **Contributors, Maintainers** |
| **[🏗️ Technical Architecture](ARCHITECTURE.md)** | System design, security architecture, technical deep-dive | **Technical Users, Architects** |

## 🎯 Quick Navigation

### **For End Users**
- **Getting Started**: [Installation Guide](DEPLOYMENT.md#-quick-installation)
- **Configuration**: [Configuration Section](DEPLOYMENT.md#-configuration)
- **Troubleshooting**: [Common Issues](DEPLOYMENT.md#-troubleshooting)

### **For Developers & Contributors**
- **Development Setup**: [Quick Start](DEVELOPER_WORKFLOW.md#-quick-start)
- **Daily Workflow**: [Core Workflow](DEVELOPER_WORKFLOW.md#-the-core-workflow-day-to-day-development)
- **Release Process**: [Release Workflow](DEVELOPER_WORKFLOW.md#-the-release-workflow-publishing-a-new-version)

### **For DevOps & Enterprise**
- **Enterprise Deployment**: [Enterprise Section](DEPLOYMENT.md#-enterprise-deployment)
- **Architecture Overview**: [System Architecture](ARCHITECTURE.md#-system-overview)
- **Security Considerations**: [Security Architecture](ARCHITECTURE.md#-security-architecture)

## 🔧 Development Tools

The project uses a unified developer CLI for all development tasks:

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

## 📖 Additional Resources

- **[Release Notes](../release-notes/README.md)**: Version history and changelog
- **[Memory Bank](../memory-bank/README.md)**: AI agent context and project insights
- **[GitHub Repository](https://github.com/holdennguyen/aws-assume-role)**: Source code and issues

---

**Need help?** Open an issue on GitHub or check the troubleshooting sections in each guide.

## 📊 Documentation Metrics

- **Total Documents**: 3 comprehensive guides
- **Coverage**: Installation, Development, Architecture
- **Maintenance**: Single source of truth for each topic
- **Audience**: Segmented by user type and needs

## 🔄 Documentation Maintenance

### **Update Triggers**
- Major feature releases
- Distribution channel changes
- Development workflow modifications
- Architecture changes

### **Maintenance Guidelines**
- Keep each document focused on its specific audience
- Cross-reference related sections between documents
- Update all relevant documents when making changes
- Maintain consistency in formatting and structure

---

**Navigation**: Return to [Main README](../README.md) | View [Release Notes](../release-notes/) | Check [Memory Bank](../memory-bank/) 