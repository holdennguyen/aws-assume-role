#!/bin/bash

# AWS Assume Role CLI - Package Building Script
# Builds packages for supported package managers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current version from Cargo.toml
VERSION=$(grep '^version =' Cargo.toml | sed 's/version = "\(.*\)"/\1/')

echo -e "${BLUE}🔨 Building packages for AWS Assume Role CLI v${VERSION}${NC}"
echo ""

# Build binary first
echo -e "${YELLOW}🦀 Building Rust binary...${NC}"
cargo build --release
echo -e "${GREEN}✅ Binary built successfully${NC}"
echo ""

# Function to build DEB package
build_deb() {
    echo -e "${YELLOW}📦 Building DEB package...${NC}"
    
    # Create package directory structure
    mkdir -p aws-assume-role-deb/DEBIAN
    mkdir -p aws-assume-role-deb/usr/bin
    
    # Copy binary
    cp target/release/aws-assume-role aws-assume-role-deb/usr/bin/
    chmod +x aws-assume-role-deb/usr/bin/aws-assume-role
    
    # Copy control files
    cp packaging/apt/DEBIAN/control aws-assume-role-deb/DEBIAN/
    cp packaging/apt/DEBIAN/postinst aws-assume-role-deb/DEBIAN/
    cp packaging/apt/DEBIAN/prerm aws-assume-role-deb/DEBIAN/
    
    # Update version in control file
    sed -i "s/Version:.*/Version: ${VERSION}/" aws-assume-role-deb/DEBIAN/control
    
    # Build package
    dpkg-deb --build aws-assume-role-deb aws-assume-role_${VERSION}_amd64.deb
    
    # Clean up
    rm -rf aws-assume-role-deb
    
    echo -e "${GREEN}✅ DEB package: aws-assume-role_${VERSION}_amd64.deb${NC}"
}

# Function to build RPM package
build_rpm() {
    echo -e "${YELLOW}📦 Building RPM package...${NC}"
    
    # Create RPM build directory structure
    mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
    
    # Copy spec file
    cp packaging/rpm/aws-assume-role.spec ~/rpmbuild/SPECS/
    
    # Update version in spec file
    sed -i "s/Version:.*/Version: ${VERSION}/" ~/rpmbuild/SPECS/aws-assume-role.spec
    
    # Copy binary to SOURCES
    cp target/release/aws-assume-role ~/rpmbuild/SOURCES/
    
    # Build RPM
    rpmbuild -ba ~/rpmbuild/SPECS/aws-assume-role.spec
    
    # Copy built RPM to current directory
    cp ~/rpmbuild/RPMS/x86_64/aws-assume-role-${VERSION}-1.x86_64.rpm .
    
    echo -e "${GREEN}✅ RPM package: aws-assume-role-${VERSION}-1.x86_64.rpm${NC}"
}

# Function to prepare Homebrew formula
prepare_homebrew() {
    echo -e "${YELLOW}🍺 Preparing Homebrew formula...${NC}"
    
    # Calculate checksums
    if [ -f "target/release/aws-assume-role" ]; then
        BINARY_SHA256=$(shasum -a 256 target/release/aws-assume-role | cut -d' ' -f1)
        echo "Binary SHA256: $BINARY_SHA256"
        
        # Update formula with version
        sed -i "s/version \".*\"/version \"${VERSION}\"/" packaging/homebrew/aws-assume-role.rb
        
        echo -e "${GREEN}✅ Homebrew formula updated${NC}"
    else
        echo -e "${RED}❌ Binary not found. Build first.${NC}"
        return 1
    fi
}

# Function to prepare Cargo package
prepare_cargo() {
    echo -e "${YELLOW}🦀 Preparing Cargo package...${NC}"
    
    # Check if Cargo.toml is ready
    if grep -q "^version = \"${VERSION}\"" Cargo.toml; then
        echo -e "${GREEN}✅ Cargo.toml version is correct: ${VERSION}${NC}"
        
        # Test build
        cargo check
        echo -e "${GREEN}✅ Cargo package ready for publishing${NC}"
    else
        echo -e "${RED}❌ Version mismatch in Cargo.toml${NC}"
        return 1
    fi
}

# Main menu
echo "What packages would you like to build?"
echo "1) DEB package (APT)"
echo "2) RPM package (YUM/DNF)"
echo "3) Prepare Homebrew formula"
echo "4) Prepare Cargo package"
echo "5) Build all packages"
echo "6) Exit"
echo ""

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        build_deb
        ;;
    2)
        build_rpm
        ;;
    3)
        prepare_homebrew
        ;;
    4)
        prepare_cargo
        ;;
    5)
        echo -e "${BLUE}🚀 Building all packages...${NC}"
        build_deb
        build_rpm
        prepare_homebrew
        prepare_cargo
        echo -e "${GREEN}✅ All packages built!${NC}"
        ;;
    6)
        echo -e "${BLUE}👋 Goodbye!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Package building completed!${NC}"
echo -e "${BLUE}Version v${VERSION} packages are ready.${NC}" 