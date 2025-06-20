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

# Chocolatey
sed -i.bak "s/<version>.*<\/version>/<version>$NEW_VERSION<\/version>/" packaging/chocolatey/aws-assume-role.nuspec
sed -i.bak "s/\$version = '.*'/\$version = '$NEW_VERSION'/" packaging/chocolatey/tools/chocolateyinstall.ps1
sed -i.bak "s/releases\/tag\/v.*/releases\/tag\/v$NEW_VERSION<\/releaseNotes>/" packaging/chocolatey/aws-assume-role.nuspec

# RPM
sed -i.bak "s/^Version:.*$/Version:        $NEW_VERSION/" packaging/rpm/aws-assume-role.spec
sed -i.bak "s/- [0-9]\+\.[0-9]\+\.[0-9]\+-1$/- $NEW_VERSION-1/" packaging/rpm/aws-assume-role.spec

# APT/DEB
sed -i.bak "s/^Version: .*/Version: $NEW_VERSION/" packaging/apt/DEBIAN/control

# Homebrew
sed -i.bak "s/version \".*\"/version \"$NEW_VERSION\"/" packaging/homebrew/aws-assume-role.rb

# AUR
sed -i.bak "s/pkgver=.*/pkgver=$NEW_VERSION/" packaging/aur/PKGBUILD
sed -i.bak "s/pkgver = .*/pkgver = $NEW_VERSION/" packaging/aur/.SRCINFO
sed -i.bak "s/archive\/v.*/archive\/v$NEW_VERSION.tar.gz/" packaging/aur/.SRCINFO

# Build script
sed -i.bak "s/VERSION=\".*\"/VERSION=\"$NEW_VERSION\"/" packaging/build-packages.sh

# Distribution script
sed -i.bak "s/VERSION=\"v.*\"/VERSION=\"v$NEW_VERSION\"/" releases/multi-shell/create-distribution.sh

# GitHub Actions workflow
sed -i.bak "s/default: '.*'/default: '$NEW_VERSION'/" .github/workflows/release.yml

# Dockerfile
sed -i.bak "s/org.opencontainers.image.version=\".*\"/org.opencontainers.image.version=\"$NEW_VERSION\"/" Dockerfile

# Clean up backup files
echo "🧹 Cleaning up backup files..."
find . -name "*.bak" -type f -delete

echo "✅ Version updated to $NEW_VERSION successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Review changes: git diff"
echo "2. Build and test: cargo build --release"
echo "3. Commit changes: git add . && git commit -m \"🔖 Bump version to v$NEW_VERSION\""
echo "4. Create tag: git tag -a v$NEW_VERSION -m \"Release v$NEW_VERSION\""
echo "5. Push: git push origin master && git push origin v$NEW_VERSION" 