#!/bin/bash

# AWS Assume Role Installation Script
# This script installs the aws-assume-role binary to your system

set -e

# Configuration
BINARY_NAME="aws-assume-role"
INSTALL_DIR="/usr/local/bin"
GITHUB_REPO="yourusername/aws-assume-role"  # Update this with your actual repo
VERSION="latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Detect OS and architecture
detect_platform() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)
    
    case $os in
        linux*)
            OS="linux"
            ;;
        darwin*)
            OS="macos"
            ;;
        msys*|mingw*|cygwin*)
            OS="windows"
            ;;
        *)
            log_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac
    
    case $arch in
        x86_64|amd64)
            ARCH="x86_64"
            ;;
        arm64|aarch64)
            ARCH="arm64"
            ;;
        *)
            log_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
    
    PLATFORM="${OS}-${ARCH}"
    log_info "Detected platform: $PLATFORM"
}

# Check if running as root for system-wide installation
check_permissions() {
    if [[ $EUID -ne 0 ]] && [[ -w "$INSTALL_DIR" ]]; then
        log_info "Installing to $INSTALL_DIR (user has write access)"
    elif [[ $EUID -ne 0 ]]; then
        log_warn "Need sudo access to install to $INSTALL_DIR"
        log_info "You can also install to a local directory by setting INSTALL_DIR environment variable"
        log_info "Example: INSTALL_DIR=~/.local/bin $0"
        
        # Ask for sudo
        if ! sudo -n true 2>/dev/null; then
            log_info "Please enter your password for sudo access:"
            sudo -v
        fi
        USE_SUDO="sudo"
    else
        log_info "Installing to $INSTALL_DIR (running as root)"
    fi
}

# Download binary (for future GitHub releases)
download_binary() {
    local binary_name="${BINARY_NAME}-${PLATFORM}"
    local download_url="https://github.com/${GITHUB_REPO}/releases/latest/download/${binary_name}"
    local temp_file="/tmp/${BINARY_NAME}"
    
    log_info "Downloading $binary_name..."
    
    if command -v curl >/dev/null 2>&1; then
        curl -sL "$download_url" -o "$temp_file"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$download_url" -O "$temp_file"
    else
        log_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi
    
    if [[ ! -f "$temp_file" ]]; then
        log_error "Failed to download binary"
        exit 1
    fi
    
    echo "$temp_file"
}

# Install binary
install_binary() {
    local binary_path="$1"
    local install_path="${INSTALL_DIR}/${BINARY_NAME}"
    
    log_info "Installing binary to $install_path..."
    
    # Make binary executable
    chmod +x "$binary_path"
    
    # Copy to install directory
    $USE_SUDO cp "$binary_path" "$install_path"
    
    # Verify installation
    if [[ -f "$install_path" ]]; then
        log_info "✅ Successfully installed $BINARY_NAME"
        log_info "Run '$BINARY_NAME --help' to get started"
    else
        log_error "Installation failed"
        exit 1
    fi
}

# Local installation (for development/testing)
install_local() {
    if [[ -f "./target/release/${BINARY_NAME}" ]]; then
        log_info "Found local binary, installing from ./target/release/${BINARY_NAME}"
        install_binary "./target/release/${BINARY_NAME}"
    elif [[ -f "./${BINARY_NAME}" ]]; then
        log_info "Found binary in current directory, installing from ./${BINARY_NAME}"
        install_binary "./${BINARY_NAME}"
    else
        log_error "No local binary found. Please build the project first with 'cargo build --release'"
        exit 1
    fi
}

# Main installation flow
main() {
    log_info "AWS Assume Role Installation Script"
    log_info "=================================="
    
    # Check if INSTALL_DIR is set by user
    if [[ -n "${INSTALL_DIR_OVERRIDE}" ]]; then
        INSTALL_DIR="$INSTALL_DIR_OVERRIDE"
        log_info "Using custom install directory: $INSTALL_DIR"
    fi
    
    # Create install directory if it doesn't exist
    if [[ ! -d "$INSTALL_DIR" ]]; then
        log_info "Creating install directory: $INSTALL_DIR"
        $USE_SUDO mkdir -p "$INSTALL_DIR"
    fi
    
    # Check for local installation
    if [[ "$1" == "--local" ]] || [[ -f "./target/release/${BINARY_NAME}" ]]; then
        install_local
    else
        # For future GitHub releases
        detect_platform
        check_permissions
        binary_path=$(download_binary)
        install_binary "$binary_path"
        rm -f "$binary_path"  # Clean up temp file
    fi
    
    log_info ""
    log_info "🎉 Installation complete!"
    log_info ""
    log_info "Next steps:"
    log_info "1. Configure a role: $BINARY_NAME configure -n my-role -r arn:aws:iam::123:role/MyRole -a 123"
    log_info "2. Assume the role: $BINARY_NAME assume my-role"
    log_info "3. Use in shell: eval \$($BINARY_NAME assume my-role)"
    log_info ""
    log_info "For more help: $BINARY_NAME --help"
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "AWS Assume Role Installation Script"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --local    Install from local build (./target/release/aws-assume-role)"
        echo "  --help     Show this help message"
        echo ""
        echo "Environment Variables:"
        echo "  INSTALL_DIR    Custom installation directory (default: /usr/local/bin)"
        echo ""
        echo "Examples:"
        echo "  $0                                    # Install from GitHub releases"
        echo "  $0 --local                           # Install from local build"
        echo "  INSTALL_DIR=~/.local/bin $0           # Install to custom directory"
        exit 0
        ;;
    *)
        check_permissions
        main "$@"
        ;;
esac 