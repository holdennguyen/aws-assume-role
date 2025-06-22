#!/bin/bash
# Pre-commit hook for AWS Assume Role CLI
# Automatically runs quality gates before each commit
#
# To install this hook:
# cp scripts/pre-commit-hook.sh .git/hooks/pre-commit
# chmod +x .git/hooks/pre-commit

set -e

echo "🔍 Running pre-commit quality checks..."

# Check if we're in the right directory
if [[ ! -f "Cargo.toml" ]]; then
    echo "❌ Error: Not in project root directory"
    exit 1
fi

# 1. Format check (CRITICAL)
echo "📝 Checking code formatting..."
if ! cargo fmt --check; then
    echo "❌ Code formatting issues found!"
    echo "💡 Fix with: cargo fmt"
    echo ""
    echo "🚨 CRITICAL: All code must be formatted before commit"
    echo "   This prevents GitHub Actions CI failures"
    exit 1
fi
echo "✅ Code formatting is correct"

# 2. Clippy check
echo "🔍 Running clippy linting..."
if ! cargo clippy --all-targets --all-features -- -D warnings; then
    echo "❌ Clippy warnings found!"
    echo "💡 Fix warnings and try again"
    exit 1
fi
echo "✅ No clippy warnings"

# 3. Test check
echo "🧪 Running tests..."
if ! cargo test --quiet; then
    echo "❌ Tests failed!"
    echo "💡 Fix failing tests and try again"
    exit 1
fi
echo "✅ All tests passing"

# 4. Build check
echo "🏗️ Checking build..."
if ! cargo build --quiet; then
    echo "❌ Build failed!"
    echo "💡 Fix build errors and try again"
    exit 1
fi
echo "✅ Build successful"

echo ""
echo "🎉 All quality checks passed! Proceeding with commit..."
echo "📊 Quality gates: ✅ Format ✅ Clippy ✅ Tests ✅ Build"
echo "" 