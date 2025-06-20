#!/bin/bash
set -e

# AWS Assume Role CLI - Package Builder
# Builds packages for all supported package managers

VERSION="1.1.1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🏗️  Building AWS Assume Role CLI packages v$VERSION"
echo "=================================================="

# Ensure binaries are built
echo "📋 Checking for binaries..."
if [ ! -f "$ROOT_DIR/releases/multi-shell/aws-assume-role-unix" ]; then
    echo "❌ Binaries not found. Please run build-releases.sh first."
    exit 1
fi

echo "✅ Binaries found"

# Create package output directory
PACKAGE_OUTPUT="$ROOT_DIR/packages"
mkdir -p "$PACKAGE_OUTPUT"

# Build DEB package
echo ""
echo "📦 Building DEB package..."
if command -v dpkg-deb >/dev/null 2>&1; then
    # Prepare DEB structure
    DEB_DIR="$SCRIPT_DIR/apt"
    mkdir -p "$DEB_DIR/usr/bin"
    mkdir -p "$DEB_DIR/usr/share/aws-assume-role"
    
    # Copy binary
    cp "$ROOT_DIR/releases/multi-shell/aws-assume-role-unix" "$DEB_DIR/usr/bin/aws-assume-role"
    chmod +x "$DEB_DIR/usr/bin/aws-assume-role"
    
    # Set permissions
    chmod +x "$DEB_DIR/DEBIAN/postinst"
    chmod +x "$DEB_DIR/DEBIAN/prerm"
    
    # Build package
    dpkg-deb --build "$DEB_DIR" "$PACKAGE_OUTPUT/aws-assume-role_${VERSION}_amd64.deb"
    echo "✅ DEB package: $PACKAGE_OUTPUT/aws-assume-role_${VERSION}_amd64.deb"
else
    echo "⚠️  dpkg-deb not available, skipping DEB package"
fi

# Build RPM package
echo ""
echo "📦 Building RPM package..."
if command -v rpmbuild >/dev/null 2>&1; then
    # Setup RPM build environment
    mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
    
    # Copy spec file and binary
    cp "$SCRIPT_DIR/rpm/aws-assume-role.spec" ~/rpmbuild/SPECS/
    cp "$ROOT_DIR/releases/multi-shell/aws-assume-role-unix" ~/rpmbuild/SOURCES/aws-assume-role-linux-x86_64
    
    # Build RPM
    rpmbuild -bb ~/rpmbuild/SPECS/aws-assume-role.spec
    
    # Copy to output
    cp ~/rpmbuild/RPMS/x86_64/aws-assume-role-${VERSION}-1.*.x86_64.rpm "$PACKAGE_OUTPUT/"
    echo "✅ RPM package: $PACKAGE_OUTPUT/aws-assume-role-${VERSION}-1.*.x86_64.rpm"
else
    echo "⚠️  rpmbuild not available, skipping RPM package"
fi

# Build Chocolatey package
echo ""
echo "📦 Building Chocolatey package..."
if command -v choco >/dev/null 2>&1; then
    cd "$SCRIPT_DIR/chocolatey"
    choco pack aws-assume-role.nuspec
    mv aws-assume-role.*.nupkg "$PACKAGE_OUTPUT/"
    echo "✅ Chocolatey package: $PACKAGE_OUTPUT/aws-assume-role.${VERSION}.nupkg"
    cd "$ROOT_DIR"
else
    echo "⚠️  choco not available, skipping Chocolatey package"
fi

# Build Homebrew formula (just copy)
echo ""
echo "📦 Preparing Homebrew formula..."
cp "$SCRIPT_DIR/homebrew/aws-assume-role.rb" "$PACKAGE_OUTPUT/"
echo "✅ Homebrew formula: $PACKAGE_OUTPUT/aws-assume-role.rb"

# Build AUR package (copy PKGBUILD)
echo ""
echo "📦 Preparing AUR package..."
mkdir -p "$PACKAGE_OUTPUT/aur"
cp "$SCRIPT_DIR/aur/PKGBUILD" "$PACKAGE_OUTPUT/aur/"
cp "$SCRIPT_DIR/aur/.SRCINFO" "$PACKAGE_OUTPUT/aur/"
echo "✅ AUR package: $PACKAGE_OUTPUT/aur/"

# Generate checksums
echo ""
echo "🔒 Generating checksums..."
cd "$PACKAGE_OUTPUT"
for file in *.deb *.rpm *.nupkg; do
    if [ -f "$file" ]; then
        sha256sum "$file" > "$file.sha256"
        echo "✅ Checksum: $file.sha256"
    fi
done
cd "$ROOT_DIR"

echo ""
echo "🎉 Package building complete!"
echo "=============================="
echo ""
echo "📦 Built packages:"
ls -la "$PACKAGE_OUTPUT"
echo ""
echo "📋 Next steps:"
echo "1. Test packages on target systems"
echo "2. Update checksums in package manager configs"
echo "3. Submit to package repositories"
echo ""
echo "📚 Installation commands for users:"
echo ""
echo "🍺 Homebrew (macOS/Linux):"
echo "  brew install yourusername/tap/aws-assume-role"
echo ""
echo "🍫 Chocolatey (Windows):"
echo "  choco install aws-assume-role"
echo ""
echo "📦 APT (Debian/Ubuntu):"
echo "  sudo dpkg -i aws-assume-role_${VERSION}_amd64.deb"
echo ""
echo "📦 YUM/DNF (RedHat/CentOS/Fedora):"
echo "  sudo rpm -i aws-assume-role-${VERSION}-1.*.x86_64.rpm"
echo ""
echo "🏗️  AUR (Arch Linux):"
echo "  yay -S aws-assume-role"
echo ""
echo "🦀 Cargo (Rust):"
echo "  cargo install aws-assume-role" 