#!/bin/bash
# Script to create release notes for a new version
# Usage: ./scripts/create-release-notes.sh 1.2.1

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.2.1"
    exit 1
fi

VERSION="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RELEASE_NOTES_DIR="$ROOT_DIR/release-notes"
RELEASE_NOTES_FILE="$RELEASE_NOTES_DIR/RELEASE_NOTES_v$VERSION.md"
INDEX_FILE="$RELEASE_NOTES_DIR/README.md"

echo "📝 Creating release notes for v$VERSION..."

cd "$ROOT_DIR"

# Check if release notes already exist
if [ -f "$RELEASE_NOTES_FILE" ]; then
    echo "⚠️  Release notes for v$VERSION already exist at:"
    echo "   $RELEASE_NOTES_FILE"
    echo ""
    read -p "Do you want to overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cancelled."
        exit 1
    fi
fi

# Create release notes directory if it doesn't exist
mkdir -p "$RELEASE_NOTES_DIR"

# Copy template
if [ ! -f "$RELEASE_NOTES_DIR/TEMPLATE.md" ]; then
    echo "❌ Template not found at $RELEASE_NOTES_DIR/TEMPLATE.md"
    echo "Please ensure the template exists before running this script."
    exit 1
fi

cp "$RELEASE_NOTES_DIR/TEMPLATE.md" "$RELEASE_NOTES_FILE"

# Get current date
RELEASE_DATE=$(date +"%Y-%m-%d")

# Get previous version for changelog
PREVIOUS_VERSION=$(git tag --sort=-version:refname | head -2 | tail -1 | sed 's/^v//')
if [ -z "$PREVIOUS_VERSION" ]; then
    PREVIOUS_VERSION="1.0.0"
fi

# Replace basic placeholders
sed -i.bak "s/{VERSION}/$VERSION/g" "$RELEASE_NOTES_FILE"
sed -i.bak "s/{DATE}/$RELEASE_DATE/g" "$RELEASE_NOTES_FILE"
sed -i.bak "s/{PREVIOUS_VERSION}/$PREVIOUS_VERSION/g" "$RELEASE_NOTES_FILE"

# Clean up backup file
rm "$RELEASE_NOTES_FILE.bak"

echo "✅ Release notes created: $RELEASE_NOTES_FILE"
echo ""
echo "📋 Next steps:"
echo "1. Edit the release notes file and fill in all remaining placeholders:"
echo "   - {FOCUS_AREA}: Main focus of this release"
echo "   - {Feature Category}, {Bug Category}, etc.: Organize your content"
echo "   - All feature descriptions and improvements"
echo ""
echo "2. Remove empty sections that don't apply to this release"
echo ""
echo "3. Update the release notes index:"
echo "   Edit $INDEX_FILE"
echo "   Add a new row for v$VERSION in the table"
echo ""
echo "4. Validate your changes:"
echo "   - Check all links work"
echo "   - Verify installation commands"
echo "   - Proofread for clarity and typos"
echo ""
echo "5. Remove the checklist at the bottom before committing"
echo ""
echo "🚀 Opening the release notes file for editing..."

# Try to open the file in the user's editor
if command -v code >/dev/null 2>&1; then
    code "$RELEASE_NOTES_FILE"
elif command -v nano >/dev/null 2>&1; then
    nano "$RELEASE_NOTES_FILE"
elif command -v vim >/dev/null 2>&1; then
    vim "$RELEASE_NOTES_FILE"
else
    echo "Please edit: $RELEASE_NOTES_FILE"
fi 