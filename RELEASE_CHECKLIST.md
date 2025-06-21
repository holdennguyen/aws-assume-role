# 🚀 Release Checklist - Quick Reference

## Pre-Release Validation ✅

### 1. Code Quality
- [ ] All tests pass: `cargo test` (59 tests)
- [ ] Formatting applied: `cargo fmt`
- [ ] Linting clean: `cargo clippy -- -D warnings`
- [ ] Security audit clean: `cargo audit`

### 2. Version Management
- [ ] Update version: `./scripts/update-version.sh [VERSION]`
- [ ] Build release: `cargo build --release`
- [ ] Verify version: `./target/release/aws-assume-role --version`

### 3. Multi-Shell Release Updates (CRITICAL)
- [ ] Update macOS binary: `cp target/release/aws-assume-role releases/multi-shell/aws-assume-role-macos`
- [ ] Update Unix binary: `cp target/release/aws-assume-role releases/multi-shell/aws-assume-role-unix`
- [ ] Verify timestamps: `ls -la releases/multi-shell/aws-assume-role-*`
- [ ] Test binaries: `./releases/multi-shell/aws-assume-role-macos --version`

### 4. Release Notes (MANDATORY)
- [ ] Create release notes: `releases/multi-shell/RELEASE_NOTES_v[VERSION].md`
- [ ] Include user impact and technical details
- [ ] Add test matrix (Ubuntu/Windows/macOS results)
- [ ] Document binary update status
- [ ] Include installation instructions
- [ ] Note security improvements

### 5. Pre-Release Commit
- [ ] Stage changes: `git add releases/multi-shell/`
- [ ] Commit: `git commit -m "📦 Prepare v[VERSION] release artifacts"`

## Production Release 🚀

### 6. Master Merge
- [ ] Switch to master: `git checkout master`
- [ ] Merge develop: `git merge develop`

### 7. Release Tag
- [ ] Create tag: `git tag -a v[VERSION] -m "Release v[VERSION]: [DESCRIPTION]"`

### 8. Push Release
- [ ] Push master: `git push origin master`
- [ ] Push tag: `git push origin v[VERSION]`

## Post-Release Validation ✅

### 9. GitHub Actions
- [ ] All platform builds successful
- [ ] GitHub Release created
- [ ] Release assets uploaded
- [ ] Package managers triggered

### 10. Distribution Verification
- [ ] Cargo.io published
- [ ] Homebrew updated
- [ ] APT/YUM packages built
- [ ] Multi-shell distribution available

---

## ⚠️ Critical Reminders

1. **NEVER** merge to master without release notes
2. **ALWAYS** update multi-shell binaries before release
3. **VERIFY** all 59 tests pass on all platforms
4. **INCLUDE** comprehensive test matrix in release notes
5. **DOCUMENT** which binaries are updated with latest changes

## 📋 Release Notes Template Checklist

- [ ] **Overview**: Brief description of release focus
- [ ] **Critical Fixes**: What problems were solved
- [ ] **Testing**: Test results matrix for all platforms
- [ ] **Architecture**: Technical improvements with examples
- [ ] **Distribution**: Binary update status
- [ ] **Security**: Dependency and security updates
- [ ] **Installation**: Updated installation instructions
- [ ] **Acknowledgments**: Credits and thanks

## 🔗 Reference Documents

- **Full Process**: `RELEASE_GUIDE.md`
- **Development Workflow**: `memory-bank/development-workflow.md`
- **Release Notes Template**: `memory-bank/development-workflow.md#release-workflow`
- **Active Context**: `memory-bank/activeContext.md` 