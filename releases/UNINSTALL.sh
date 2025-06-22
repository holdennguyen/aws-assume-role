#!/bin/bash

# AWS Assume Role CLI - Universal Uninstallation Script
# Removes aws-assume-role from your system

set -e

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

show_usage() {
    echo "AWS Assume Role CLI - Universal Uninstallation Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --force                Force removal without confirmation"
    echo "  --help, -h             Show this help"
    echo ""
    echo "This script will:"
    echo "  1. Find aws-assume-role installations"
    echo "  2. Remove binaries from common locations"
    echo "  3. Clean up shell configurations (if any)"
    echo "  4. Remove any cached files"
    echo ""
}

# Parse command line arguments
FORCE_REMOVAL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE_REMOVAL=true
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Find installations
find_installations() {
    INSTALLATIONS=()
    
    # Common binary locations
    local binary_locations=(
        "$HOME/.local/bin/aws-assume-role"
        "/usr/local/bin/aws-assume-role"
        "/opt/homebrew/bin/aws-assume-role"
        "/usr/bin/aws-assume-role"
    )
    
    # Windows executable locations
    local windows_locations=(
        "$HOME/.local/bin/aws-assume-role.exe"
        "/usr/local/bin/aws-assume-role.exe"
        "/c/Program Files/aws-assume-role/aws-assume-role.exe"
        "/c/Users/$USER/AppData/Local/aws-assume-role/aws-assume-role.exe"
    )
    
    # Check for binaries
    for location in "${binary_locations[@]}" "${windows_locations[@]}"; do
        if [[ -f "$location" ]]; then
            INSTALLATIONS+=("$location")
        fi
    done
    
    # Check PATH for aws-assume-role
    if command -v aws-assume-role >/dev/null 2>&1; then
        local path_location=$(which aws-assume-role)
        if [[ ! " ${INSTALLATIONS[@]} " =~ " ${path_location} " ]]; then
            INSTALLATIONS+=("$path_location")
        fi
    fi
}

# Remove installations
remove_installations() {
    if [[ ${#INSTALLATIONS[@]} -eq 0 ]]; then
        log_info "No aws-assume-role installations found."
        return 0
    fi
    
    log_info "Found ${#INSTALLATIONS[@]} installation(s):"
    for installation in "${INSTALLATIONS[@]}"; do
        echo "  - $installation"
    done
    echo ""
    
    if [[ "$FORCE_REMOVAL" != "true" ]]; then
        read -p "Remove all installations? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "❌ Cancelled."
            exit 0
        fi
    fi
    
    # Remove each installation
    for installation in "${INSTALLATIONS[@]}"; do
        log_info "Removing: $installation"
        
        # Check if we need sudo
        local dir=$(dirname "$installation")
        if [[ ! -w "$dir" ]]; then
            log_warn "Requires sudo for: $installation"
            sudo rm -f "$installation"
        else
            rm -f "$installation"
        fi
        
        if [[ -f "$installation" ]]; then
            log_error "Failed to remove: $installation"
        else
            log_info "✅ Removed: $installation"
        fi
    done
}

# Clean up shell configurations
cleanup_shell_configs() {
    log_info "🧹 Cleaning up shell configurations..."
    
    # Files to check for aws-assume-role references
    local config_files=(
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.zshrc"
        "$HOME/.profile"
        "$HOME/.config/fish/config.fish"
    )
    
    local found_configs=false
    
    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" ]] && grep -q "aws-assume-role" "$config_file" 2>/dev/null; then
            found_configs=true
            log_warn "Found aws-assume-role references in: $config_file"
            echo "  You may want to manually remove any aws-assume-role aliases or PATH modifications"
        fi
    done
    
    if [[ "$found_configs" != "true" ]]; then
        log_info "No shell configuration cleanup needed."
    fi
}

# Clean up cache and temp files
cleanup_cache() {
    log_info "🗑️  Cleaning up cache files..."
    
    # Potential cache locations
    local cache_dirs=(
        "$HOME/.cache/aws-assume-role"
        "$HOME/.aws-assume-role"
        "/tmp/aws-assume-role-*"
    )
    
    local cleaned=false
    
    for cache_dir in "${cache_dirs[@]}"; do
        if [[ -d "$cache_dir" ]] || ls $cache_dir >/dev/null 2>&1; then
            log_info "Removing cache: $cache_dir"
            rm -rf $cache_dir
            cleaned=true
        fi
    done
    
    if [[ "$cleaned" != "true" ]]; then
        log_info "No cache files found to clean."
    fi
}

# Verify removal
verify_removal() {
    log_info "🔍 Verifying removal..."
    
    if command -v aws-assume-role >/dev/null 2>&1; then
        local remaining=$(which aws-assume-role)
        log_warn "aws-assume-role still found in PATH: $remaining"
        log_info "You may need to restart your shell or manually remove: $remaining"
        return 1
    else
        log_info "✅ aws-assume-role successfully removed from PATH"
        return 0
    fi
}

# Main execution
main() {
    log_info "🗑️  AWS Assume Role CLI - Uninstallation"
    echo ""
    
    # Find installations
    log_info "🔍 Scanning for aws-assume-role installations..."
    find_installations
    
    # Remove installations
    remove_installations
    
    # Clean up configurations
    cleanup_shell_configs
    
    # Clean up cache
    cleanup_cache
    
    # Verify removal
    echo ""
    if verify_removal; then
        log_info "🎉 Uninstallation completed successfully!"
        echo ""
        echo "AWS Assume Role CLI has been removed from your system."
        echo "You may need to restart your shell for PATH changes to take effect."
    else
        log_warn "⚠️  Uninstallation completed with warnings."
        echo ""
        echo "Some aws-assume-role files may still be present."
        echo "Check the warnings above and remove manually if needed."
    fi
}

# Run main function
main "$@" 