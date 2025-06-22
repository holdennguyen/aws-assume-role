#!/bin/bash

# AWS Assume Role CLI - Unified Release Script
# Complete release management: version, notes, build, package, distribute, and publish

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

# Colors for output
RED='\033[0;31m'
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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show usage
show_usage() {
    echo "AWS Assume Role CLI - Unified Release Script"
    echo ""
    echo "Usage: $0 <command> [version]"
    echo ""
    echo "Commands:"
    echo "  version <ver>       - Update version across all files"
    echo "  notes <ver>         - Create release notes from template"
    echo "  prepare <ver>       - Update version + create release notes"
    echo "  build               - Build binaries for all platforms"
    echo "  package [ver]       - Create distribution packages"
    echo "  publish [ver]       - Publish to package managers"
    echo "  help                - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 version x.y.z            # Update version only"
    echo "  $0 notes x.y.z              # Create release notes only"
    echo "  $0 prepare x.y.z            # Update version + create notes"
    echo "  $0 build                    # Build binaries"
    echo "  $0 package vx.y.z          # Create distribution packages"
    echo ""
    echo "Workflow:"
    echo "  1. $0 prepare x.y.z         # Prepare version and notes"
    echo "  2. Edit release notes and commit changes"
    echo "  3. Push to 'develop', wait for CI, then create git tag"
    echo ""
}

# Update version across all project files
update_version() {
    local version="$1"
    if [ -z "$version" ]; then
        log_error "Version required for version update"
        echo "Usage: $0 version x.y.z"
        exit 1
    fi
    
    # Remove 'v' prefix if present
    version=${version#v}
    
    log_info "🔄 Updating version to $version across all project files..."
    
    # Update Cargo.toml
    log_info "📦 Updating Cargo.toml..."
    sed -i.bak "s/^version = \".*\"/version = \"$version\"/" Cargo.toml
    
    # Update package manager configurations
    log_info "📦 Updating package manager configurations..."
    
    # Note: APT and RPM packaging removed in streamlined approach
    
    # Homebrew (if exists)
    if [[ -f "packaging/homebrew/aws-assume-role.rb" ]]; then
        sed -i.bak "s/version \".*\"/version \"$version\"/" packaging/homebrew/aws-assume-role.rb
    fi
    
    # GitHub Actions workflow (if exists)
    if [[ -f ".github/workflows/release.yml" ]]; then
        sed -i.bak "s/default: '.*'/default: '$version'/" .github/workflows/release.yml
    fi
    
    # Dockerfile (if exists)
    if [[ -f "Dockerfile" ]]; then
        sed -i.bak "s/org.opencontainers.image.version=\".*\"/org.opencontainers.image.version=\"$version\"/" Dockerfile
    fi
    
    # Clean up backup files
    log_info "🧹 Cleaning up backup files..."
    find . -name "*.bak" -type f -delete
    
    # Verify Cargo.toml was updated correctly
    local current_version=$(grep '^version =' Cargo.toml | sed 's/version = "\(.*\)"/\1/')
    if [ "$current_version" != "$version" ]; then
        log_error "Failed to update Cargo.toml version. Expected $version, got $current_version"
        exit 1
    fi
    
    log_info "✅ Version updated to $version successfully!"
    
    echo ""
    log_info "🎯 Release preparation completed!"
    echo ""
    echo "📋 Next steps (Safe Release Process):"
    echo "1. Review all changes: git diff"
    echo "2. Commit changes: git add . && git commit -m \"🔖 Prepare release v$version\""
    echo "3. Push to the integration branch: git push origin develop"
    echo "4. ⚠️  CRITICAL: Wait for GitHub Actions to PASS for the 'develop' branch."
    echo "5. After CI passes, create the tag: git tag -a v$version -m \"Release v$version\""
    echo "6. Push the tag to trigger the release pipeline: git push origin v$version"
    echo ""
    log_warn "Do not proceed to tagging until CI has passed on the 'develop' branch."
}

# Create release notes from template
create_release_notes() {
    local version="$1"
    if [ -z "$version" ]; then
        log_error "Version required for release notes creation"
        echo "Usage: $0 notes x.y.z"
        exit 1
    fi
    
    # Remove 'v' prefix if present
    version=${version#v}
    
    log_info "📝 Creating release notes for v$version..."
    
    local release_notes_dir="release-notes"
    local release_notes_file="$release_notes_dir/RELEASE_NOTES_v$version.md"
    local template_file="$release_notes_dir/TEMPLATE.md"
    
    # Check if release notes already exist
    if [[ -f "$release_notes_file" ]]; then
        log_warn "Release notes for v$version already exist:"
        echo "   $release_notes_file"
        echo ""
        read -p "Do you want to overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "✅ Skipping overwrite of existing release notes."
            return 0
        fi
    fi
    
    # Create release notes directory if it doesn't exist
    mkdir -p "$release_notes_dir"
    
    # Check for template
    if [[ ! -f "$template_file" ]]; then
        log_error "Template not found at $template_file"
        log_info "Please ensure the template exists before running this script."
        exit 1
    fi
    
    # Copy template
    cp "$template_file" "$release_notes_file"
    
    # Get current date and previous version
    local release_date=$(date +"%Y-%m-%d")
    local previous_version=$(git tag --sort=-version:refname | head -2 | tail -1 | sed 's/^v//' 2>/dev/null || echo "1.0.0")
    
    # Replace placeholders
    sed -i.bak "s/{VERSION}/$version/g" "$release_notes_file"
    sed -i.bak "s/{DATE}/$release_date/g" "$release_notes_file"
    sed -i.bak "s/{PREVIOUS_VERSION}/$previous_version/g" "$release_notes_file"
    
    # Clean up backup file
    rm -f "$release_notes_file.bak"
    
    log_info "✅ Release notes created: $release_notes_file"
    
    echo ""
    echo "📋 Next steps for release notes:"
    echo "1. Edit the file and fill in all placeholders:"
    echo "   - {FOCUS_AREA}: Main focus of this release"
    echo "   - Feature descriptions and improvements"
    echo "2. Remove empty sections that don't apply"
    echo "3. Update release-notes/README.md with new version entry"
    echo "4. Remove the checklist at the bottom before committing"
    
    # Try to open the file in editor
    if command -v code >/dev/null 2>&1; then
        log_info "🚀 Opening release notes in VS Code..."
        code "$release_notes_file" &
    elif command -v nano >/dev/null 2>&1; then
        log_info "🚀 Opening release notes in nano..."
        nano "$release_notes_file"
    else
        log_info "📝 Please edit: $release_notes_file"
    fi
}

# Prepare release (version + notes)
prepare_release() {
    local version="$1"
    if [ -z "$version" ]; then
        log_error "Version required for release preparation"
        echo "Usage: $0 prepare x.y.z"
        exit 1
    fi
    
    log_info "🚀 Preparing release v$version..."
    
    # Update version
    update_version "$version"
    
    echo ""
    
    # Create release notes
    create_release_notes "$version"
    
    echo ""
    log_info "🎯 Release preparation completed!"
    echo ""
    echo "📋 Next steps (Safe Release Process):"
    echo "1. Review all changes: git diff"
    echo "2. Commit changes: git add . && git commit -m \"🔖 Prepare release v$version\""
    echo "3. Push to the integration branch: git push origin develop"
    echo "4. ⚠️  CRITICAL: Wait for GitHub Actions to PASS for the 'develop' branch."
    echo "5. After CI passes, create the tag: git tag -a v$version -m \"Release v$version\""
    echo "6. Push the tag to trigger the release pipeline: git push origin v$version"
    echo ""
    log_warn "Do not proceed to tagging until CI has passed on the 'develop' branch."
}

# Build binaries
build_binaries() {
    log_info "🚀 Building binaries for all platforms..."
    ./scripts/build-releases.sh
    log_info "✅ Binaries built successfully"
}

# Create distribution packages
create_packages() {
    local version="$1"
    if [ -z "$version" ]; then
        version=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.2.0")
    fi
    
    # Remove 'v' prefix if present
    version=${version#v}
    
    log_info "📦 Creating distribution packages for v$version..."
    
    # Get current date for versioning
    local date=$(date +%Y%m%d)
    local package_name="aws-assume-role-cli-v${version}-${date}"
    
    # Create temporary distribution directory
    local dist_dir="releases/dist/$package_name"
    mkdir -p "$dist_dir"
    
    # Check if binaries exist
    if [ ! -f "releases/aws-assume-role-macos" ]; then
        log_error "Binaries not found. Running build first..."
        build_binaries
    fi
    
    # Copy binaries
    log_info "📋 Copying binaries and files..."
    cp releases/aws-assume-role-macos "$dist_dir/"
    cp releases/aws-assume-role-linux "$dist_dir/"
    cp releases/aws-assume-role-windows.exe "$dist_dir/"
    
    # Copy universal bash wrapper
    cp releases/aws-assume-role-bash.sh "$dist_dir/"
    
    # Copy documentation and installation scripts
    cp releases/README.md "$dist_dir/"
    cp releases/INSTALL.sh "$dist_dir/"
    cp releases/UNINSTALL.sh "$dist_dir/"
    
    # Make scripts executable
    chmod +x "$dist_dir/INSTALL.sh"
    chmod +x "$dist_dir/UNINSTALL.sh"
    chmod +x "$dist_dir/aws-assume-role-bash.sh"
    chmod +x "$dist_dir/aws-assume-role-macos"
    chmod +x "$dist_dir/aws-assume-role-linux"
    
    # Create archives
    log_info "📦 Creating distribution archives..."
    cd releases/dist
    
    # Create tar.gz for Unix/Linux/macOS
    tar -czf "${package_name}.tar.gz" "$package_name"
    log_info "✅ Created: ${package_name}.tar.gz"
    
    # Create zip for Windows
    zip -r "${package_name}.zip" "$package_name" > /dev/null
    log_info "✅ Created: ${package_name}.zip"
    
    # Create checksums
    sha256sum "${package_name}.tar.gz" > "${package_name}.tar.gz.sha256"
    sha256sum "${package_name}.zip" > "${package_name}.zip.sha256"
    log_info "✅ Created checksum files"
    
    cd ../..
    
    log_info "📁 Distribution files created in: releases/dist/"
    ls -la "releases/dist/${package_name}.*"
    
    echo ""
    log_info "🎉 Distribution packages ready!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Test installation: cd releases/dist/$package_name && ./INSTALL.sh"
    echo "2. Upload to GitHub releases"
    echo "3. Publish to package managers: $0 publish v$version"
}

# Publish to package managers
publish_packages() {
    local version="$1"
    if [ -z "$version" ]; then
        version=$(grep '^version =' Cargo.toml | sed 's/version = "\(.*\)"/\1/')
    fi
    
    # Remove 'v' prefix if present
    version=${version#v}
    
    log_info "🚀 Publishing v$version to package managers..."
    
    echo ""
    echo "📦 Publishing Options:"
    echo "1. Cargo (crates.io)"
    echo "2. Homebrew tap update"
    echo "3. Container build (local test)"
    echo "4. Exit"
    echo ""
    read -p "Choose option (1-4): " choice
    
    case $choice in
        1)
            log_info "🦀 Publishing to crates.io..."
            if [ -z "$CARGO_REGISTRY_TOKEN" ]; then
                log_warn "CARGO_REGISTRY_TOKEN not set. Please set it first:"
                echo "export CARGO_REGISTRY_TOKEN=your_token_here"
                return 1
            fi
            cargo publish --token "$CARGO_REGISTRY_TOKEN"
            log_info "✅ Published to crates.io"
            ;;
        2)
            publish_homebrew "$version"
            ;;
        3)
            log_info "🐳 Building container locally..."
            docker build -t aws-assume-role:test .
            docker run --rm aws-assume-role:test awsr --version
            log_info "✅ Container built and tested locally"
            log_info "ℹ️  Production containers are built automatically by GitHub Actions"
            ;;
        4)
            log_info "👋 Exiting without publishing"
            return 0
            ;;
        *)
            log_error "Invalid choice"
            return 1
            ;;
    esac
}

# Publish to Homebrew
publish_homebrew() {
    local version="$1"
    
    log_info "🍺 Publishing to Homebrew..."
    
    # Check if tap repo exists
    if [ ! -d "homebrew-tap" ]; then
        log_info "Cloning homebrew-tap repository..."
        git clone https://github.com/holdennguyen/homebrew-tap.git
    else
        log_info "Updating existing homebrew-tap repository..."
        cd homebrew-tap && git pull && cd ..
    fi
    
    # Calculate checksums for binaries (assuming they're in GitHub releases)
    log_info "📊 You'll need to manually update the SHA256 checksums in the Homebrew formula"
    log_info "After uploading binaries to GitHub releases, get the checksums with:"
    echo "  shasum -a 256 aws-assume-role-macos"
    echo "  shasum -a 256 aws-assume-role-linux"
    echo "  shasum -a 256 aws-assume-role-windows.exe"
    
    # Update formula
    cp packaging/homebrew/aws-assume-role.rb homebrew-tap/Formula/ 2>/dev/null || {
        log_warn "Homebrew formula not found in packaging/homebrew/"
        log_info "Please ensure the formula exists before publishing"
        return 1
    }
    
    # Update version in formula
    sed -i.bak "s/version \".*\"/version \"${version}\"/" homebrew-tap/Formula/aws-assume-role.rb
    rm -f homebrew-tap/Formula/aws-assume-role.rb.bak
    
    log_info "📝 Formula updated. Review changes:"
    cd homebrew-tap
    git diff Formula/aws-assume-role.rb
    
    echo ""
    read -p "Commit and push changes? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add Formula/aws-assume-role.rb
        git commit -m "Update aws-assume-role to v${version}" || echo "No changes to commit"
        git push
        log_info "✅ Homebrew formula updated!"
        log_info "Users can now install with: brew tap holdennguyen/tap && brew install aws-assume-role"
    else
        log_info "📝 Changes not committed. Review and push manually."
    fi
    
    cd ..
}

# Main command processing
case "${1:-help}" in
    "version")
        update_version "$2"
        ;;
    "notes")
        create_release_notes "$2"
        ;;
    "prepare")
        prepare_release "$2"
        ;;
    "build")
        build_binaries
        ;;
    "package")
        create_packages "$2"
        ;;
    "publish")
        publish_packages "$2"
        ;;
    "help"|*)
        show_usage
        ;;
esac 