# 📋 Release Notes

This directory contains comprehensive release notes for all versions of AWS Assume Role CLI.

## 📚 Available Releases

| Version | Release Date | Focus | Status |
|---------|--------------|-------|--------|
| [v1.2.0](RELEASE_NOTES_v1.2.0.md) | 2024-12-21 | Windows Compatibility & CI/CD Reliability | ✅ Released |

## 📝 Process

### Creating Release Notes

```bash
# Use the helper script (recommended)
./scripts/release.sh notes 1.2.1

# Or manually copy template
cp release-notes/TEMPLATE.md release-notes/RELEASE_NOTES_v1.2.1.md
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