# 📋 Release Notes

This directory contains comprehensive release notes for all versions of AWS Assume Role CLI.

## 📚 Available Releases

| Version | Release Date | Focus | Status |
|---------|--------------|-------|--------|
| [v1.2.0](RELEASE_NOTES_v1.2.0.md) | 2025-06-22 | Windows Compatibility & CI/CD Reliability | ✅ Released |
| [v1.3.0](RELEASE_NOTES_v1.3.0.md) | 2025-06-24 | Developer Experience & Critical Windows Compatibility | ✅ Released |
| [v1.3.1](RELEASE_NOTES_v1.3.1.md) | 2025-06-24 | Installation Script Fixes & Quality Improvements | ✅ Released |

## 📝 Process

### Creating Release Notes

```bash
# Use the helper script (recommended)
./dev-cli.sh release v<version>

# Or manually copy template
cp release-notes/TEMPLATE.md release-notes/RELEASE_NOTES_v<version>.md
```

### Required Content
- **Overview**: Brief summary and focus area
- **Features**: New functionality and improvements  
- **Bug Fixes**: Issues resolved
- **Technical Details**: Dependencies, test coverage
- **Installation**: Up-to-date installation instructions

### Integration
1. Create release notes before publishing
2. Copy content to GitHub release description  
3. Update RELEASE.md with highlights
4. Add entry to this index table

## 🎯 Best Practices

- **Write for Users**: Focus on user-facing changes and benefits
- **Be Specific**: Provide clear, actionable information
- **Include Examples**: Show code snippets or commands when helpful
- **Test Links**: Verify all links work before publishing
- **Proofread**: Check for typos and clarity

## 🔍 Historical Context

- **v1.2.0**: First release with comprehensive Windows compatibility
- **v1.1.x**: Foundation releases with core functionality
- **v1.0.x**: Initial stable releases 