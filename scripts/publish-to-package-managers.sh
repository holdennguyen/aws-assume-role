#!/bin/bash

# AWS Assume Role CLI - Package Manager Publishing Helper
# This script helps publish to package managers manually or test automation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current version from Cargo.toml
VERSION=$(grep '^version =' Cargo.toml | sed 's/version = "\(.*\)"/\1/')

echo -e "${BLUE}🚀 AWS Assume Role CLI Package Publishing Helper${NC}"
echo -e "${BLUE}Current Version: ${GREEN}v${VERSION}${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to publish to Homebrew tap
publish_homebrew() {
    echo -e "${YELLOW}📦 Publishing to Homebrew...${NC}"
    
    # Check if tap repo exists
    if [ ! -d "homebrew-tap" ]; then
        echo "Cloning homebrew-tap repository..."
        git clone https://github.com/holdennguyen/homebrew-tap.git
    else
        echo "Updating existing homebrew-tap repository..."
        cd homebrew-tap
        git pull
        cd ..
    fi
    
    # Calculate checksums for binaries
    echo "Calculating checksums..."
    
    # Download binaries if they don't exist
    if [ ! -f "aws-assume-role-macos-x86_64" ]; then
        curl -L -o aws-assume-role-macos-x86_64 \
            "https://github.com/holdennguyen/aws-assume-role/releases/download/v${VERSION}/aws-assume-role-macos-x86_64"
    fi
    
    if [ ! -f "aws-assume-role-linux-x86_64" ]; then
        curl -L -o aws-assume-role-linux-x86_64 \
            "https://github.com/holdennguyen/aws-assume-role/releases/download/v${VERSION}/aws-assume-role-linux-x86_64"
    fi
    
    MACOS_SHA256=$(shasum -a 256 aws-assume-role-macos-x86_64 | cut -d' ' -f1)
    LINUX_SHA256=$(shasum -a 256 aws-assume-role-linux-x86_64 | cut -d' ' -f1)
    
    echo "macOS SHA256: $MACOS_SHA256"
    echo "Linux SHA256: $LINUX_SHA256"
    
    # Update formula
    cp packaging/homebrew/aws-assume-role.rb homebrew-tap/Formula/
    
    # Replace placeholders
    sed -i '' "s/version \".*\"/version \"${VERSION}\"/" homebrew-tap/Formula/aws-assume-role.rb
    sed -i '' "s/PLACEHOLDER_X86_64_SHA256/$MACOS_SHA256/" homebrew-tap/Formula/aws-assume-role.rb
    sed -i '' "s/PLACEHOLDER_LINUX_SHA256/$LINUX_SHA256/" homebrew-tap/Formula/aws-assume-role.rb
    
    # Commit and push
    cd homebrew-tap
    git add Formula/aws-assume-role.rb
    git commit -m "Update aws-assume-role to v${VERSION}" || echo "No changes to commit"
    git push
    cd ..
    
    echo -e "${GREEN}✅ Homebrew formula updated!${NC}"
    echo -e "Users can now install with: ${BLUE}brew tap holdennguyen/tap && brew install aws-assume-role${NC}"
}

# Function to prepare PPA package
prepare_ppa() {
    echo -e "${YELLOW}📦 Preparing PPA package...${NC}"
    
    # Check dependencies
    if ! command_exists debuild; then
        echo -e "${RED}❌ debuild not found. Install with: sudo apt install devscripts${NC}"
        return 1
    fi
    
    # Create source package directory
    mkdir -p "aws-assume-role-${VERSION}"
    cd "aws-assume-role-${VERSION}"
    
    # Create debian directory structure
    mkdir -p debian/source
    
    # Copy control files
    cp ../packaging/apt/DEBIAN/control debian/
    cp ../packaging/apt/DEBIAN/postinst debian/
    cp ../packaging/apt/DEBIAN/prerm debian/
    
    # Create additional debian files
    echo "3.0 (quilt)" > debian/source/format
    
    # Create changelog
    cat > debian/changelog << EOF
aws-assume-role (${VERSION}-1) jammy; urgency=medium

  * New upstream release v${VERSION}
  * Prerequisites verification system
  * Enhanced CLI help and examples
  * Improved troubleshooting

 -- Hung, Nguyen Minh <holdennguyen6174@gmail.com>  $(date -R)
EOF
    
    # Create rules file
    cat > debian/rules << 'EOF'
#!/usr/bin/make -f
%:
	dh $@

override_dh_auto_build:
	# Binary is pre-built

override_dh_auto_install:
	mkdir -p debian/aws-assume-role/usr/bin
	curl -L -o debian/aws-assume-role/usr/bin/aws-assume-role \
		"https://github.com/holdennguyen/aws-assume-role/releases/download/v$(VERSION)/aws-assume-role-linux-x86_64"
	chmod +x debian/aws-assume-role/usr/bin/aws-assume-role
EOF
    chmod +x debian/rules
    
    # Create compat file
    echo "13" > debian/compat
    
    # Create copyright file
    cat > debian/copyright << EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: aws-assume-role
Source: https://github.com/holdennguyen/aws-assume-role

Files: *
Copyright: 2025 Hung, Nguyen Minh <holdennguyen6174@gmail.com>
License: MIT
EOF
    
    cd ..
    
    echo -e "${GREEN}✅ PPA package prepared in aws-assume-role-${VERSION}/${NC}"
    echo -e "${BLUE}To build and upload:${NC}"
    echo -e "  cd aws-assume-role-${VERSION}"
    echo -e "  debuild -S -sa"
    echo -e "  dput ppa:holdennguyen/aws-assume-role ../aws-assume-role_${VERSION}-1_source.changes"
}

# Function to publish to COPR
publish_copr() {
    echo -e "${YELLOW}📦 Publishing to COPR (YUM/DNF)...${NC}"
    
    if ! command_exists copr-cli; then
        echo -e "${RED}❌ copr-cli not found. Install with: pip3 install copr-cli${NC}"
        return 1
    fi
    
    # Update RPM spec version
    sed -i '' "s/Version:.*/Version: ${VERSION}/" packaging/rpm/aws-assume-role.spec
    
    echo "Building COPR package..."
    copr-cli build aws-assume-role packaging/rpm/aws-assume-role.spec \
        --nowait \
        --chroot fedora-39-x86_64 \
        --chroot fedora-38-x86_64 \
        --chroot epel-9-x86_64
    
    echo -e "${GREEN}✅ COPR build submitted!${NC}"
    echo -e "Check status at: ${BLUE}https://copr.fedorainfracloud.org/coprs/holdennguyen/aws-assume-role/${NC}"
}

# Function to update documentation
update_docs() {
    echo -e "${YELLOW}📚 Updating installation documentation...${NC}"
    
    # Update README with package manager commands
    sed -i '' '/^### Package Managers/,/^### Manual Installation/c\
### Package Managers (Recommended)\
\
**🍺 Homebrew (macOS/Linux)**\
```bash\
brew tap holdennguyen/tap\
brew install aws-assume-role\
```\
\
**📦 APT (Debian/Ubuntu)**\
```bash\
sudo add-apt-repository ppa:holdennguyen/aws-assume-role\
sudo apt update\
sudo apt install aws-assume-role\
```\
\
**📦 DNF/YUM (Fedora/CentOS/RHEL)**\
```bash\
# Fedora\
sudo dnf copr enable holdennguyen/aws-assume-role\
sudo dnf install aws-assume-role\
\
# CentOS/RHEL\
sudo yum copr enable holdennguyen/aws-assume-role\
sudo yum install aws-assume-role\
```\
\
**🦀 Cargo (Rust)**\
```bash\
cargo install aws-assume-role\
```\
\
### Manual Installation' README.md
    
    echo -e "${GREEN}✅ Documentation updated!${NC}"
}

# Main menu
echo "What would you like to do?"
echo "1) Publish to Homebrew tap"
echo "2) Prepare PPA package"
echo "3) Publish to COPR (YUM/DNF)"
echo "4) Update documentation"
echo "5) Publish to all package managers"
echo "6) Exit"
echo ""

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        publish_homebrew
        ;;
    2)
        prepare_ppa
        ;;
    3)
        publish_copr
        ;;
    4)
        update_docs
        ;;
    5)
        echo -e "${BLUE}🚀 Publishing to all package managers...${NC}"
        publish_homebrew
        prepare_ppa
        publish_copr
        update_docs
        echo -e "${GREEN}✅ All package managers updated!${NC}"
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
echo -e "${GREEN}🎉 Package publishing completed!${NC}"
echo -e "${BLUE}Version v${VERSION} is now available via package managers.${NC}" 