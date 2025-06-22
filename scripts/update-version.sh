#!/bin/bash
# Script to update version across all project files
# Usage: ./scripts/update-version.sh 1.0.3

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <new_version>"
    echo "Example: $0 1.0.3"
    exit 1
fi

NEW_VERSION="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔄 Updating version to $NEW_VERSION across all project files..."

cd "$ROOT_DIR"

# Update Cargo.toml
echo "📦 Updating Cargo.toml..."
sed -i.bak "s/^version = \".*\"/version = \"$NEW_VERSION\"/" Cargo.toml

# Update package manager configurations
echo "📦 Updating package manager configurations..."

# RPM
sed -i.bak "s/^Version:.*$/Version:        $NEW_VERSION/" packaging/rpm/aws-assume-role.spec
sed -i.bak "s/- [0-9]\+\.[0-9]\+\.[0-9]\+-1$/- $NEW_VERSION-1/" packaging/rpm/aws-assume-role.spec

# APT/DEB
sed -i.bak "s/^Version: .*/Version: $NEW_VERSION/" packaging/apt/DEBIAN/control

# Homebrew
sed -i.bak "s/version \".*\"/version \"$NEW_VERSION\"/" packaging/homebrew/aws-assume-role.rb

# Build script
sed -i.bak "s/VERSION=\".*\"/VERSION=\"$NEW_VERSION\"/" packaging/build-packages.sh

# GitHub Actions workflow
sed -i.bak "s/default: '.*'/default: '$NEW_VERSION'/" .github/workflows/release.yml

# Dockerfile
sed -i.bak "s/org.opencontainers.image.version=\".*\"/org.opencontainers.image.version=\"$NEW_VERSION\"/" Dockerfile

# Clean up backup files
echo "🧹 Cleaning up backup files..."
find . -name "*.bak" -type f -delete

# Verify Cargo.toml was updated correctly
CURRENT_VERSION=$(grep '^version =' Cargo.toml | sed 's/version = "\(.*\)"/\1/')
if [ "$CURRENT_VERSION" != "$NEW_VERSION" ]; then
    echo "❌ Error: Failed to update Cargo.toml version. Expected $NEW_VERSION, got $CURRENT_VERSION"
    exit 1
fi

echo "✅ Version updated to $NEW_VERSION successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Create release notes: cp release-notes/TEMPLATE.md release-notes/RELEASE_NOTES_v$NEW_VERSION.md"
echo "2. Edit release notes and fill in all placeholders"
echo "3. Update release-notes/README.md with new version entry"
echo "4. Review changes: git diff"
echo "5. Build and test: cargo build --release"
echo "6. Run tests: cargo test"
echo "7. Commit changes: git add . && git commit -m \"🔖 Bump version to v$NEW_VERSION\""
echo "8. Create tag: git tag -a v$NEW_VERSION -m \"Release v$NEW_VERSION\""
echo "9. Push: git push origin master && git push origin v$NEW_VERSION"
echo ""
echo "🚨 Important: Make sure to create the tag AFTER committing the version changes!"
echo "   This ensures Cargo.toml version matches the git tag for crates.io publishing."
echo ""
echo "📝 Release Notes: Don't forget to create comprehensive release notes using the template!" 