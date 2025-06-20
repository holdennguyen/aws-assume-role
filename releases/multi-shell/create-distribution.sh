#!/bin/bash

# AWS Assume Role CLI Tool - Distribution Package Creator
# Creates a distributable archive with all necessary files

set -e

echo "📦 Creating AWS Assume Role CLI Distribution Package"
echo "=================================================="

# Get current date for versioning
DATE=$(date +%Y%m%d)
VERSION="v1.0.0"
PACKAGE_NAME="aws-assume-role-cli-${VERSION}-${DATE}"

echo "📍 Package name: $PACKAGE_NAME"

# Create temporary distribution directory
DIST_DIR="dist/$PACKAGE_NAME"
mkdir -p "$DIST_DIR"

echo "📋 Copying files to distribution directory..."

# Copy binaries
cp aws-assume-role-macos "$DIST_DIR/"
cp aws-assume-role-unix "$DIST_DIR/"
cp aws-assume-role.exe "$DIST_DIR/"

# Copy wrapper scripts
cp aws-assume-role-bash.sh "$DIST_DIR/"
cp aws-assume-role-fish.fish "$DIST_DIR/"
cp aws-assume-role-powershell.ps1 "$DIST_DIR/"
cp aws-assume-role-cmd.bat "$DIST_DIR/"

# Copy documentation and installation scripts
cp README.md "$DIST_DIR/"
cp INSTALL.sh "$DIST_DIR/"
cp INSTALL.ps1 "$DIST_DIR/"
cp UNINSTALL.sh "$DIST_DIR/"
cp UNINSTALL.ps1 "$DIST_DIR/"
cp DELIVERY_INSTRUCTIONS.md "$DIST_DIR/"
cp QUICK_START_DEPLOYMENT.md "$DIST_DIR/"

# Make scripts executable
chmod +x "$DIST_DIR/INSTALL.sh"
chmod +x "$DIST_DIR/UNINSTALL.sh"

# Make binaries executable
chmod +x "$DIST_DIR/aws-assume-role-macos"
chmod +x "$DIST_DIR/aws-assume-role-unix"

echo "✅ Files copied to: $DIST_DIR"

# Create archives
echo ""
echo "📦 Creating distribution archives..."

# Create tar.gz for Unix/Linux/macOS
cd dist
tar -czf "${PACKAGE_NAME}.tar.gz" "$PACKAGE_NAME"
echo "✅ Created: ${PACKAGE_NAME}.tar.gz"

# Create zip for Windows
zip -r "${PACKAGE_NAME}.zip" "$PACKAGE_NAME" > /dev/null
echo "✅ Created: ${PACKAGE_NAME}.zip"

cd ..

# Create checksums
echo ""
echo "🔒 Creating checksums..."
cd dist
sha256sum "${PACKAGE_NAME}.tar.gz" > "${PACKAGE_NAME}.tar.gz.sha256"
sha256sum "${PACKAGE_NAME}.zip" > "${PACKAGE_NAME}.zip.sha256"
echo "✅ Created checksum files"
cd ..

# Show final structure
echo ""
echo "📁 Distribution package structure:"
echo "=================================="
tree "dist/$PACKAGE_NAME" 2>/dev/null || find "dist/$PACKAGE_NAME" -type f | sort

echo ""
echo "📦 Distribution files created:"
echo "=============================="
ls -la dist/${PACKAGE_NAME}.*

echo ""
echo "🎉 Distribution package ready!"
echo "=============================="
echo ""
echo "📋 Next steps:"
echo "1. Test the installation on target platforms"
echo "2. Distribute the appropriate archive:"
echo "   - ${PACKAGE_NAME}.tar.gz for Unix/Linux/macOS users"
echo "   - ${PACKAGE_NAME}.zip for Windows users"
echo "3. Include installation instructions from README.md"
echo ""
echo "🚀 Users can now install with:"
echo "   Unix/Linux/macOS: tar -xzf ${PACKAGE_NAME}.tar.gz && cd ${PACKAGE_NAME} && ./INSTALL.sh"
echo "   Windows: Extract ${PACKAGE_NAME}.zip, then run .\\INSTALL.ps1"
echo ""
echo "Happy distributing! 🎊" 