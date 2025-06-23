# 🧠 Memory Bank - AI Agent Context

This directory contains consolidated contextual information for AI agents working on the AWS Assume Role CLI project. The memory bank preserves project knowledge across sessions and ensures continuity when AI agents have memory resets.

## 📋 Purpose

The memory bank serves as the **complete project context** for AI agents, containing:
- Project overview and current status
- Development workflows and patterns
- Technical decisions and architecture
- Critical learnings and patterns
- Active context and next steps

## 🔄 Update Rule

**CRITICAL**: Memory bank files MUST be updated whenever:

1. **Significant project changes occur**:
   - Documentation restructuring
   - Major feature releases
   - Architectural changes
   - Workflow modifications
   - Script or tooling changes

2. **Explicit instruction given**:
   - When user requests "update memory bank"
   - When AI agent discovers outdated information
   - After completing major tasks or refactoring

3. **Pattern discovery**:
   - New development patterns identified
   - Critical workflows established
   - Quality issues or solutions found

## 📁 Optimized File Structure

### Core Context Files (Consolidated)

| File | Purpose | Key Information |
|------|---------|-----------------|
| `project-context.md` | **Complete project overview** - Mission, status, achievements, user stories | Project goals, current version status, recent achievements, user experience |
| `development-context.md` | **Development workflows** - Git Flow, quality gates, patterns, tooling | Git Flow strategy, dev-cli.sh usage, quality checks, release process |
| `technical-context.md` | **Architecture & implementation** - Code patterns, dependencies, security | Rust patterns, AWS SDK usage, cross-platform builds, security practices |
| `testing-framework.md` | **Testing strategy** - Test matrix, patterns, execution | 79 tests breakdown, shell integration tests, CI/CD testing |

### Consolidated Information

**Removed Redundancies**:
- `development-setup.md` → Merged into `development-context.md`
- `security-upgrade.md` → Merged into `technical-context.md`

**Benefits**:
- Reduced file count from 7 to 4 core files
- Eliminated duplicate information
- Faster context loading for AI agents
- Clearer information hierarchy

## 🎯 Current Project Status (December 2024)

### Recent Major Achievements
- ✅ **CI/CD Pipeline Fixed**: Upgraded deprecated actions and resolved artifact conflicts
- ✅ **Standardized Workflow**: Unified `dev-cli.sh` script for all development tasks
- ✅ **Git Flow Documentation**: Corrected branch strategy to reflect proper Git Flow workflow
- ✅ **Test Suite**: 79 comprehensive tests covering all functionality
- ✅ **Cross-Platform Support**: Universal bash wrapper for Linux, macOS, Windows Git Bash

### Active Focus
- **Git Bash Windows Issue**: Fixing shell detection for proper export commands
- **Documentation Maintenance**: Keeping all documentation current and accurate
- **Quality Assurance**: Maintaining 79 tests and CI/CD pipeline stability

### Next Updates Expected
- When Git Bash Windows fix is implemented
- When new features or architectural changes occur
- When development workflows evolve
- Upon explicit "update memory bank" instruction

---

**Last Updated**: December 2024 - After identifying Git Bash Windows issue
**Next Review**: When significant changes occur or upon explicit request

## 🔍 Quick Reference for AI Agents

### **Session Start Protocol**
1. **Read `project-context.md`** - Understand project mission and current status
2. **Review `development-context.md`** - Understand Git Flow and development workflow
3. **Check `technical-context.md`** - Understand architecture and implementation patterns
4. **Reference `testing-framework.md`** - Understand testing strategy and execution

### **Critical Patterns to Remember**
- **Git Flow**: Feature branches from `develop`, PRs to `develop`, releases to `main`
- **Quality Gates**: Always run `./dev-cli.sh check` before commits
- **Cross-Platform**: Universal bash wrapper handles Linux, macOS, Windows Git Bash
- **Testing**: 79 tests must pass (unit, integration, shell integration)

### **Common Tasks**
- **Bug Fixes**: Create `fix/` branch from `develop`
- **Features**: Create `feature/` branch from `develop`
- **Releases**: Use `./dev-cli.sh release <version>` workflow
- **Testing**: Use `./dev-cli.sh check` for all quality gates

**Remember**: The memory bank is only as good as it is current. Update it whenever significant changes occur! 