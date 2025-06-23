#!/bin/bash
# Pre-commit hook for AWS Assume Role CLI
# Automatically runs quality gates and fixes formatting before each commit
#
# To install this hook:
# cp scripts/pre-commit-hook.sh .git/hooks/pre-commit
# chmod +x .git/hooks/pre-commit

set -e

echo "�� Running pre-commit quality checks..."

# Check if we're in the right directory
if [[ ! -f "Cargo.toml" ]]; then
    echo "❌ Error: Not in project root directory"
    exit 1
fi

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_next() {
    echo -e "${BLUE}[NEXT]${NC} $1"
}

# 1. Auto-format code (ENHANCED)
echo "📝 Auto-formatting code..."
if cargo fmt --check >/dev/null 2>&1; then
    echo "✅ Code formatting is already correct"
else
    echo "🔧 Auto-fixing code formatting..."
    if cargo fmt; then
        echo "✅ Code formatting fixed automatically"
        
        # Stage the formatted files
        echo "📦 Staging formatted files..."
        git add -A
        
        echo "💡 Note: Formatted files have been automatically staged"
        echo "   Review the changes with: git diff --cached"
    else
        echo "❌ Failed to auto-format code!"
        echo "💡 Manual fix required: cargo fmt"
        exit 1
    fi
fi

# 2. Clippy check
echo "🔍 Running clippy linting..."
if ! cargo clippy --all-targets --all-features -- -D warnings; then
    echo "❌ Clippy warnings found!"
    echo "💡 Fix warnings and try again"
    exit 1
fi
echo "✅ No clippy warnings"

# 3. Test check
echo "�� Running tests..."
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

# Success message with next steps
echo ""
log_info "�� All quality checks passed! Proceeding with commit..."
echo "📊 Quality gates: ✅ Auto-Format ✅ Clippy ✅ Tests ✅ Build"
echo ""

# Determine current branch and provide appropriate next steps
get_current_branch() {
    git branch --show-current 2>/dev/null || echo "unknown"
}

get_remote_branch() {
    git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "none"
}

show_next_steps() {
    local current_branch=$(get_current_branch)
    local remote_branch=$(get_remote_branch)
    
    echo "🚀 Next Steps:"
    echo ""
    
    # Check if we're on a feature branch
    if [[ "$current_branch" != "main" && "$current_branch" != "develop" ]]; then
        log_next "1. Review your changes:"
        echo "   git diff --cached"
        echo ""
        
        log_next "2. Commit your changes:"
        echo "   git commit -m \"feat: your descriptive commit message\""
        echo ""
        
        if [[ "$remote_branch" == "none" ]]; then
            log_next "3. Push to remote (first time):"
            echo "   git push -u origin $current_branch"
            echo ""
        else
            log_next "3. Push to remote:"
            echo "   git push origin $current_branch"
            echo ""
        fi
        
        log_next "4. Create Pull Request:"
        echo "   - Go to GitHub and create PR to 'develop' branch"
        echo "   - Wait for CI checks to pass"
        echo "   - Request review if needed"
        echo ""
        
        log_warn "💡 Remember: Follow the Safe Release Process for releases"
        echo "   See docs/DEVELOPER_WORKFLOW.md for details"
        
    elif [[ "$current_branch" == "develop" ]]; then
        log_next "1. Review your changes:"
        echo "   git diff --cached"
        echo ""
        
        log_next "2. Commit your changes:"
        echo "   git commit -m \"feat: your descriptive commit message\""
        echo ""
        
        log_next "3. Push to develop:"
        echo "   git push origin develop"
        echo ""
        
        log_warn "⚠️  CRITICAL: Wait for GitHub Actions to PASS before creating release tags"
        echo "   Visit: https://github.com/holdennguyen/aws-assume-role/actions"
        echo ""
        
        log_next "4. After CI passes, prepare release:"
        echo "   ./scripts/release.sh prepare x.y.z"
        echo "   git add . && git commit -m \"�� Prepare release vx.y.z\""
        echo "   git push origin develop"
        echo "   # Wait for CI again, then:"
        echo "   git tag -a vx.y.z -m \"Release vx.y.z\""
        echo "   git push origin vx.y.z"
        
    elif [[ "$current_branch" == "main" ]]; then
        log_next "1. Review your changes:"
        echo "   git diff --cached"
        echo ""
        
        log_next "2. Commit your changes:"
        echo "   git commit -m \"feat: your descriptive commit message\""
        echo ""
        
        log_warn "⚠️  Note: You're on main branch - consider using feature branches"
        echo "   Recommended: git checkout -b feature/your-feature"
        
    else
        log_next "1. Review your changes:"
        echo "   git diff --cached"
        echo ""
        
        log_next "2. Commit your changes:"
        echo "   git commit -m \"feat: your descriptive commit message\""
        echo ""
    fi
    
    echo ""
    log_info "📚 For more details, see: docs/DEVELOPER_WORKFLOW.md"
    echo ""
}

# Show next steps
show_next_steps

# Additional tips based on context
if [[ -n "$(git diff --cached)" ]]; then
    echo "💡 Tip: You have staged changes ready to commit"
fi

if [[ -n "$(git diff)" ]]; then
    echo "�� Tip: You have unstaged changes - consider: git add ."
fi