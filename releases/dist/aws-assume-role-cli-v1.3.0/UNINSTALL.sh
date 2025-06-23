#!/bin/bash

# AWS Assume Role CLI - Uninstallation Script
# This script removes the aws-assume-role CLI and cleans up shell integration.

set -euo pipefail

# --- Configuration ---
# The script is expected to be in the installation directory.
INSTALL_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# --- Colors and Logging ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Main Logic ---
main() {
    log_warn "This script will remove the AWS Assume Role CLI program files."
    read -p "Files will be removed from '$INSTALL_DIR'. Are you sure? (y/N) " confirmation
    if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
        log_info "Uninstallation cancelled."
        exit 0
    fi

    # 1. Remove installed files
    log_info "Removing CLI files..."
    # Find all 'aws-assume-role*' files in the script's directory and remove them.
    # This intentionally leaves the UNINSTALL.sh script itself behind.
    find "$INSTALL_DIR" -maxdepth 1 -name 'aws-assume-role*' -print -exec rm -v {} +
    
    log_info "✅ Files removed successfully."
    echo
    log_warn "--- ACTION REQUIRED ---"
    log_warn "To complete the uninstallation, you MUST manually remove the following line"
    log_warn "from your shell's startup file (e.g., ~/.bash_profile, ~/.bashrc):"
    echo
    echo "    source \"$INSTALL_DIR/aws-assume-role-bash.sh\""
    echo
    log_warn "After removing the line, restart your shell."
    echo
}

main "$@" 