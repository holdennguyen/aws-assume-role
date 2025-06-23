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
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# --- Main Logic ---
main() {
    echo "AWS Assume Role CLI - Uninstaller"
    echo "================================="
    echo
    
    log_warn "This will remove AWS Assume Role CLI from your system."
    read -p "Are you sure you want to continue? (y/N) " confirmation
    if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
        log_info "Uninstallation cancelled."
        exit 0
    fi
    
    echo
    log_step "Step 1: Removing application files..."
    
    # Remove application files
    local files_removed=false
    for pattern in "aws-assume-role-*" "aws-assume-role-bash.sh"; do
        for file in "$INSTALL_DIR"/$pattern; do
            if [[ -f "$file" ]]; then
                if [[ -w "$file" ]]; then
                    rm -v "$file"
                    files_removed=true
                else
                    log_error "Permission denied: $file"
                    log_warn "Try running: sudo rm \"$file\""
                fi
            fi
        done
    done
    
    if [[ "$files_removed" == "false" ]]; then
        log_warn "No application files found to remove."
    fi
    
    echo
    log_step "Step 2: Manual cleanup required"
    echo "Please run the following commands to complete the uninstallation:"
    echo
    
    # Shell profile cleanup
    log_info "1. Remove from shell profile (choose your shell):"
    echo "   # For bash:"
    echo "   sed -i '/aws-assume-role-bash.sh/d' ~/.bashrc"
    echo "   sed -i '/aws-assume-role-bash.sh/d' ~/.bash_profile"
    echo
    echo "   # For zsh:"
    echo "   sed -i '/aws-assume-role-bash.sh/d' ~/.zshrc"
    echo
    echo "   # For Git Bash on Windows:"
    echo "   sed -i '/aws-assume-role-bash.sh/d' ~/.bash_profile"
    echo
    
    # Remove installation directory
    log_info "2. Remove installation directory:"
    echo "   cd .. && rm -rf \"$INSTALL_DIR\""
    echo
    
    # Clear shell functions
    log_info "3. Clear any existing shell functions:"
    echo "   unset -f awsr 2>/dev/null || true"
    echo
    
    # Reload shell
    log_info "4. Reload your shell configuration:"
    echo "   # For bash:"
    echo "   source ~/.bashrc"
    echo "   # For zsh:"
    echo "   source ~/.zshrc"
    echo
    
    log_info "✅ Uninstallation instructions provided."
    log_warn "Please run the commands above to complete the cleanup."
    echo
}

main "$@" 