#!/bin/bash

# AWS Assume Role CLI - Universal Installation Script
# This script installs the aws-assume-role CLI and sets up shell integration.

set -euo pipefail

# --- Configuration ---
INSTALL_DIR_DEFAULT="$HOME/.local/bin"
SOURCE_DIR="."
REPO_URL="https://github.com/holdennguyen/aws-assume-role"

# --- Colors and Logging ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Helper Functions ---
detect_os() {
    case "$(uname -s)" in
        Linux*)   OS="linux" ;;
        Darwin*)  OS="macos" ;;
        MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
        *)
            log_error "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
    log_info "Detected OS: $OS"
}

get_binary_name() {
    case "$OS" in
        linux)   echo "aws-assume-role-linux" ;;
        macos)   echo "aws-assume-role-macos" ;;
        windows) echo "aws-assume-role-windows.exe" ;;
    esac
}

cleanup_shell_profiles() {
    log_info "Cleaning up old configurations from shell profiles..."
    local profile
    for profile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.profile"; do
        if [ -f "$profile" ]; then
            # Use a temporary file and move to avoid issues with sed -i on different platforms
            sed '/aws-assume-role/d' "$profile" > "$profile.tmp" && mv "$profile.tmp" "$profile"
            log_info "Cleaned $profile"
        fi
    done
}

# --- Main Logic ---
main() {
    detect_os
    local binary_name=$(get_binary_name)

    if [ ! -f "$SOURCE_DIR/$binary_name" ]; then
        log_error "Binary '$binary_name' not found in '$SOURCE_DIR'."
        log_error "Please run this script from the extracted release archive directory."
        exit 1
    fi

    # 1. Get installation directory
    read -p "Enter installation directory [default: $INSTALL_DIR_DEFAULT]: " install_dir_input
    local install_dir=${install_dir_input:-$INSTALL_DIR_DEFAULT}
    mkdir -p "$install_dir"
    log_info "Installing to: $install_dir"

    # 2. Install files using cp for broad compatibility
    log_info "Installing binaries and scripts..."
    # Copy the binary with its original platform-specific name
    cp "$SOURCE_DIR/$binary_name" "$install_dir/$binary_name"
    if [ -f "$SOURCE_DIR/aws-assume-role-bash.sh" ]; then
        cp "$SOURCE_DIR/aws-assume-role-bash.sh" "$install_dir/"
    fi
    cp "$SOURCE_DIR/UNINSTALL.sh" "$install_dir/"

    # Make scripts and binary executable
    chmod +x "$install_dir/$binary_name"
    chmod +x "$install_dir/aws-assume-role-bash.sh"
    chmod +x "$install_dir/UNINSTALL.sh"

    # 3. Create a symlink for the 'awsr' command
    log_info "Creating 'awsr' command..."
    ln -sf "$install_dir/aws-assume-role-bash.sh" "$install_dir/awsr"

    # 4. Clean up old shell profile entries
    cleanup_shell_profiles

    # 5. Add new configuration to shell profile
    log_info "Adding configuration to shell profile..."
    local shell_profile=""
    if [ -f "$HOME/.zshrc" ]; then
        shell_profile="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        shell_profile="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
        shell_profile="$HOME/.bash_profile"
    else
        log_warn "Could not find .bashrc or .zshrc. Please configure your shell manually."
    fi

    if [ -n "$shell_profile" ]; then
        {
            echo ''
            echo '# AWS Assume Role CLI'
            echo "export PATH=\"\$PATH:$install_dir\""
        } >> "$shell_profile"
        log_info "Configuration added to $shell_profile"
    fi

    # --- Final Instructions ---
    log_info "✅ Installation complete!"
    echo
    log_warn "Please restart your shell or run 'source $shell_profile' for changes to take effect."
    echo
    echo "You can now use the 'awsr' command."
    echo "Example: awsr assume my-role"
    echo "To uninstall, run: $install_dir/UNINSTALL.sh"
}

main "$@" 