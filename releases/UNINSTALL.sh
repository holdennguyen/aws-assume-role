#!/bin/bash

# AWS Assume Role CLI - Universal Uninstallation Script
# This script removes the aws-assume-role CLI and cleans up shell integration.

set -euo pipefail

# --- Configuration ---
INSTALL_DIR_DEFAULT="$HOME/.local/bin"

# --- Colors and Logging ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Helper Functions ---
cleanup_shell_profiles() {
    log_info "Removing configuration from shell profiles..."
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
    log_info "Starting uninstallation of AWS Assume Role CLI..."

    # 1. Get installation directory
    read -p "Enter the directory where the tool was installed [default: $INSTALL_DIR_DEFAULT]: " install_dir_input
    local install_dir=${install_dir_input:-$INSTALL_DIR_DEFAULT}

    if [ ! -d "$install_dir" ]; then
        log_error "Installation directory not found: $install_dir"
        exit 1
    fi

    # 2. Remove files
    log_info "Removing files from $install_dir..."
    rm -f "$install_dir/aws-assume-role-linux"
    rm -f "$install_dir/aws-assume-role-macos"
    rm -f "$install_dir/aws-assume-role-windows.exe"
    rm -f "$install_dir/aws-assume-role-bash.sh"
    rm -f "$install_dir/awsr"
    rm -f "$install_dir/UNINSTALL.sh"
    log_info "Files removed."

    # 3. Clean up shell profiles
    cleanup_shell_profiles

    # --- Final Instructions ---
    log_info "✅ Uninstallation complete!"
    echo
    log_warn "Please restart your shell for changes to take full effect."
}

main "$@" 