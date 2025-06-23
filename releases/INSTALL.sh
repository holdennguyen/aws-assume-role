#!/bin/bash
# AWS Assume Role CLI - Installation Script

set -euo pipefail

# --- Configuration ---
INSTALL_DIR_DEFAULT="$HOME/.local/bin"
SOURCE_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

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
    echo "AWS Assume Role CLI - Installer"
    echo "==============================="
    echo
    
    # 1. Determine OS and binary name
    log_step "Step 1: Detecting operating system..."
    local os
    case "$(uname -s)" in
        Linux*)   os="linux" ;;
        Darwin*)  os="macos" ;;
        MINGW*|MSYS*|CYGWIN*) os="windows" ;;
        *) log_error "Unsupported OS: $(uname -s)"; exit 1 ;;
    esac
    local binary_name="aws-assume-role-$os"
    if [ "$os" = "windows" ]; then binary_name="aws-assume-role-windows.exe"; fi
    log_info "Detected OS: $os, using binary: $binary_name"

    # 2. Get installation directory
    log_step "Step 2: Setting installation directory..."
    read -p "Enter installation directory [default: $INSTALL_DIR_DEFAULT]: " install_dir_input
    local install_dir=${install_dir_input:-$INSTALL_DIR_DEFAULT}
    mkdir -p "$install_dir"
    log_info "Installing to: $install_dir"

    # 3. Copy files
    log_step "Step 3: Copying application files..."
    log_info "Copying files..."
    cp -v "$SOURCE_DIR/$binary_name" "$install_dir/"
    cp -v "$SOURCE_DIR/aws-assume-role-bash.sh" "$install_dir/"
    cp -v "$SOURCE_DIR/UNINSTALL.sh" "$install_dir/"

    # 4. Make files executable
    log_step "Step 4: Setting file permissions..."
    chmod +x "$install_dir/$binary_name"
    chmod +x "$install_dir/aws-assume-role-bash.sh"
    chmod +x "$install_dir/UNINSTALL.sh"
    log_info "✅ Files installed successfully to $install_dir"
    
    echo
    log_step "Step 5: Manual configuration required"
    log_warn "--- ACTION REQUIRED ---"
    log_warn "To complete the installation, you MUST add the following line to your shell profile."
    log_warn "For Git Bash on Windows, this is usually ~/.bash_profile"
    log_warn "For macOS or Linux, this is usually ~/.bashrc or ~/.zshrc"
    echo
    echo "    source \"$install_dir/aws-assume-role-bash.sh\""
    echo
    log_warn "After adding the line, you MUST restart your shell."
    echo
    echo "To uninstall, run: $install_dir/UNINSTALL.sh"
}

main "$@" 