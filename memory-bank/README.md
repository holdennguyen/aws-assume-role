# 🧠 Memory Bank - AI Agent Context

This directory contains contextual information for AI agents working on the AWS Assume Role CLI project. The memory bank preserves project knowledge across sessions and ensures continuity when AI agents have memory resets.

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

## 📁 File Structure

### Core Context Files

| File | Purpose | Update Frequency |
|------|---------|------------------|
| `project-context.md` | Complete project overview, status, achievements | Major changes |
| `development-context.md` | Development workflows, patterns, quality gates | Workflow changes |
| `technical-context.md` | Architecture, technical decisions, dependencies | Technical changes |
| `development-setup.md` | Environment setup, tooling, prerequisites | Setup changes |
| `testing-framework.md` | Testing strategy, patterns, coverage | Testing changes |
| `security-upgrade.md` | Security considerations, vulnerabilities, upgrades | Security updates |

### Usage Guidelines

1. **Read ALL files at session start** - AI agents must review complete context
2. **Update immediately after major changes** - Don't let context become stale
3. **Focus on current state** - Emphasize what's working now vs. historical details
4. **Document patterns** - Capture critical learnings and repeated patterns
5. **Maintain accuracy** - Remove outdated information, update status

## 🎯 Current Project Status (June 2024)

### Recent Major Achievements
- ✅ Documentation consolidated (17+ files → 4 core documents)
- ✅ Scripts streamlined (12 scripts → 5 scripts, -58% reduction)
- ✅ GitHub Actions unified (4 workflows → 1 comprehensive pipeline)
- ✅ Platform focused (3 core platforms with universal bash wrapper)
- ✅ Quality maintained (59 tests, zero-tolerance quality gates)

### Active Focus
- **Maintenance**: Keep streamlined architecture stable
- **Quality**: Maintain zero-defect releases
- **User Experience**: Monitor consolidated documentation effectiveness
- **Security**: Continue proactive security practices

### Next Updates Expected
- When user feedback requires documentation changes
- When new features or architectural changes occur  
- When development workflows evolve
- Upon explicit "update memory bank" instruction

---

**Last Updated**: June 2024 - Post documentation consolidation and script streamlining
**Next Review**: When significant changes occur or upon explicit request

## 🔍 Quick Reference

For AI agents starting a new session:

1. **Start here**: Read `project-context.md` for complete overview
2. **Development work**: Review `development-context.md` for workflows
3. **Technical questions**: Check `technical-context.md` for architecture
4. **Setup needs**: Reference `development-setup.md` for environment
5. **Testing work**: Review `testing-framework.md` for test patterns
6. **Security concerns**: Check `security-upgrade.md` for current status

**Remember**: The memory bank is only as good as it is current. Update it whenever significant changes occur! 