#!/bin/bash

# AWS Assume Role CLI - Release Helper Script
# Provides backend functions for the main dev-cli.sh script.
# This script is not intended to be run directly by developers.

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

# --- Helper Functions ---
log_info() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

# --- Subcommands ---

# Updates the version number in Cargo.toml and other key files.
update_version() {
    local version="$1"
    version=${version#v} # Remove 'v' prefix if present
    
    log_info "Updating version to $version in Cargo.toml..."
    sed -i.bak "s/^version = \".*\"/version = \"$version\"/" Cargo.toml
    
    find . -name "*.bak" -type f -delete
    
    local current_version
    current_version=$(grep '^version =' Cargo.toml | sed 's/version = "\(.*\)"/\1/')
    if [ "$current_version" != "$version" ]; then
        log_error "Failed to update Cargo.toml. Expected $version, got $current_version."
        exit 1
    fi
    log_info "Version updated successfully."
}

# Creates a new release notes file from the template.
create_release_notes() {
    local version="$1"
    version=${version#v} # Remove 'v' prefix if present
    
    local release_notes_dir="release-notes"
    local template_file="$release_notes_dir/TEMPLATE.md"
    local release_notes_file="$release_notes_dir/RELEASE_NOTES_v$version.md"
    
    if [ ! -f "$template_file" ]; then
        log_error "Release notes template not found at $template_file"
        exit 1
    fi

    log_info "Creating release notes file: $release_notes_file"
    cp "$template_file" "$release_notes_file"
    
    local release_date
    release_date=$(date +"%Y-%m-%d")
    
    # Replace placeholders
    sed -i.bak "s/{VERSION}/$version/g" "$release_notes_file"
    sed -i.bak "s/{DATE}/$release_date/g" "$release_notes_file"
    
    rm -f "$release_notes_file.bak"
    log_info "Release notes created. Please edit the file to add details."
}

# Prepares the repository for a new release.
prepare_release() {
    local version="$1"
    if [ -z "$version" ]; then
        log_error "A version number is required."
        echo "Usage: ./dev-cli.sh release <version>"
        exit 1
    fi
    
    log_info "🚀 Preparing release v$version..."
    update_version "$version"
    create_release_notes "$version"
    log_info "✅ Release preparation complete. Please review the changes and commit."
}

# Creates distributable archives (.tar.gz, .zip) from local artifacts.
package_local_artifacts() {
    local version="$1"
    if [ -z "$version" ]; then
        log_error "A version number is required to create packages."
        echo "Usage: ./dev-cli.sh package <version>"
        exit 1
    fi
    version=${version#v} # Remove 'v' prefix

    log_info "📦 Packaging local artifacts for v$version..."

    # 1. Ensure binaries are built first
    build_local_artifacts

    # 2. Set up directory structure
    local package_name="aws-assume-role-cli-v${version}"
    local dist_dir="releases/dist"
    local package_dir="$dist_dir/$package_name"
    
    log_info "Creating package directory: $package_dir"
    rm -rf "$package_dir" # Clean previous attempt
    mkdir -p "$package_dir"

    # 3. Copy all required artifacts
    log_info "Copying binaries and scripts..."
    cp releases/aws-assume-role-macos "$package_dir/"
    cp releases/aws-assume-role-linux "$package_dir/"
    cp releases/aws-assume-role-windows.exe "$package_dir/"
    cp releases/aws-assume-role-bash.sh "$package_dir/"
    cp releases/INSTALL.sh "$package_dir/"
    cp releases/UNINSTALL.sh "$package_dir/"
    cp README.md "$package_dir/" # Include root README

    # 4. Create archives
    log_info "Creating .tar.gz and .zip archives..."
    cd "$dist_dir"
    
    tar -czf "${package_name}.tar.gz" "$package_name"
    zip -r "${package_name}.zip" "$package_name" > /dev/null

    # 5. Generate checksums
    log_info "Generating SHA256 checksums..."
    if command -v sha256sum &> /dev/null; then
        sha256sum "${package_name}.tar.gz" > "${package_name}.tar.gz.sha256"
        sha256sum "${package_name}.zip" > "${package_name}.zip.sha256"
    else
        shasum -a 256 "${package_name}.tar.gz" > "${package_name}.tar.gz.sha256"
        shasum -a 256 "${package_name}.zip" > "${package_name}.zip.sha256"
    fi
    
    cd ../.. # Return to project root

    log_info "✅ Local distribution package created successfully in '$dist_dir'."
    ls -l "$dist_dir"
}

# Builds local artifacts for all platforms.
build_local_artifacts() {
    # ------------------------------------------------------------------
    # Fast-path for CI:
    #   – GitHub Actions has already produced the three platform binaries
    #     in the earlier `build` job and they are copied to ./releases/.
    #   – If they're present, we can safely skip the expensive rebuild /
    #     environment-validation that requires musl-cross, mingw-w64, etc.
    # ------------------------------------------------------------------
    if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
        if [[ -f releases/aws-assume-role-linux       && \
              -f releases/aws-assume-role-macos       && \
              -f releases/aws-assume-role-windows.exe ]]; then
            log_info "✅ CI environment detected and binaries already staged – skipping local build."
            return 0
        else
            log_info "CI environment detected but binaries missing – falling back to full build."
        fi
    fi

    log_info "🏗️ Building local release artifacts..."
    if [ ! -f "scripts/build-releases.sh" ]; then
        log_error "Build script not found at scripts/build-releases.sh"
        exit 1
    fi
    ./scripts/build-releases.sh
    log_info "✅ Local artifacts built successfully in the 'releases/' directory."
}

# --- Main Logic ---

show_usage() {
    echo "Release Helper Script"
    echo "This script is a backend for dev-cli.sh and not meant for direct use."
    echo ""
    echo "Available subcommands (via dev-cli.sh):"
    echo "  ./dev-cli.sh release <version>        - Prepares for a new release."
    echo "  ./dev-cli.sh build                    - Builds local artifacts."
    echo "  ./dev-cli.sh package <version>        - Creates distributable archives."
    echo ""
}

main() {
    local command="$1"
    shift
    
    case "$command" in
        prepare)
            prepare_release "$@"
            ;;
        build)
            build_local_artifacts
            ;;
        package)
            package_local_artifacts "$@"
            ;;
        *)
            # If no subcommand is provided, assume it's a version for release preparation
            if [ -n "$command" ]; then
                prepare_release "$command"
            else
                show_usage
                exit 1
            fi
            ;;
    esac
}

# Only run main logic if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 