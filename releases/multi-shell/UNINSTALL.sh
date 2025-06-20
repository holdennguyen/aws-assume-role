#!/bin/bash

# AWS Assume Role CLI Tool - Uninstall Script
# Removes all traces of the AWS Assume Role CLI tool

set -e

echo "🗑️  AWS Assume Role CLI Tool - Uninstall Script"
echo "==============================================="

# Detect shell
SHELL_TYPE="unknown"
if [[ "$SHELL" == *"bash"* ]]; then
    SHELL_TYPE="bash"
elif [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_TYPE="zsh"
elif [[ "$SHELL" == *"fish"* ]]; then
    SHELL_TYPE="fish"
else
    echo "🔍 Could not detect shell type. Will provide manual instructions."
    SHELL_TYPE="bash"
fi

echo "🐚 Detected shell: $SHELL_TYPE"
echo ""

# Function to remove from shell profile
remove_from_profile() {
    local profile_file="$1"
    local pattern="$2"
    
    if [ -f "$profile_file" ]; then
        echo "🔍 Checking $profile_file..."
        if grep -q "$pattern" "$profile_file"; then
            echo "📝 Removing AWS Assume Role CLI from $profile_file..."
            # Create backup
            cp "$profile_file" "${profile_file}.backup.$(date +%Y%m%d_%H%M%S)"
            # Remove lines containing the pattern
            grep -v "$pattern" "$profile_file" > "${profile_file}.tmp" && mv "${profile_file}.tmp" "$profile_file"
            echo "✅ Removed from $profile_file (backup created)"
        else
            echo "ℹ️  No AWS Assume Role CLI entries found in $profile_file"
        fi
    else
        echo "ℹ️  $profile_file does not exist"
    fi
}

# Clear current session
echo "🧹 Clearing current session..."
unset -f awsr 2>/dev/null || true
unset -f clear_aws_creds 2>/dev/null || true
unset -f aws_whoami 2>/dev/null || true
echo "✅ Cleared current session functions"

# Remove from shell profiles
echo ""
echo "🔧 Removing from shell profiles..."
echo "=================================="

case $SHELL_TYPE in
    "bash")
        remove_from_profile "$HOME/.bashrc" "aws-assume-role"
        remove_from_profile "$HOME/.bash_profile" "aws-assume-role"
        ;;
    "zsh")
        remove_from_profile "$HOME/.zshrc" "aws-assume-role"
        ;;
    "fish")
        remove_from_profile "$HOME/.config/fish/config.fish" "aws-assume-role"
        ;;
esac

# Find and list installation directories
echo ""
echo "🔍 Finding AWS Assume Role CLI installations..."
echo "=============================================="

FOUND_INSTALLATIONS=()

# Common installation locations
SEARCH_PATHS=(
    "/usr/local/bin"
    "$HOME/.local/bin"
    "$HOME/bin"
    "$(pwd)"
)

for path in "${SEARCH_PATHS[@]}"; do
    if [ -d "$path" ]; then
        # Look for binaries
        if [ -f "$path/aws-assume-role" ] || [ -f "$path/aws-assume-role-macos" ] || [ -f "$path/aws-assume-role-unix" ]; then
            FOUND_INSTALLATIONS+=("$path")
            echo "📍 Found installation in: $path"
        fi
        
        # Look for wrapper scripts
        if [ -f "$path/aws-assume-role-bash.sh" ] || [ -f "$path/aws-assume-role-fish.fish" ]; then
            if [[ ! " ${FOUND_INSTALLATIONS[@]} " =~ " $path " ]]; then
                FOUND_INSTALLATIONS+=("$path")
                echo "📍 Found installation in: $path"
            fi
        fi
    fi
done

# Remove installations
if [ ${#FOUND_INSTALLATIONS[@]} -gt 0 ]; then
    echo ""
    echo "🗑️  Removing installations..."
    echo "============================="
    
    for install_path in "${FOUND_INSTALLATIONS[@]}"; do
        echo "📁 Removing from: $install_path"
        
        # List files to be removed
        FILES_TO_REMOVE=(
            "aws-assume-role"
            "aws-assume-role-macos" 
            "aws-assume-role-unix"
            "aws-assume-role-bash.sh"
            "aws-assume-role-fish.fish"
            "aws-assume-role-powershell.ps1"
            "aws-assume-role-cmd.bat"
        )
        
        REMOVED_COUNT=0
        for file in "${FILES_TO_REMOVE[@]}"; do
            if [ -f "$install_path/$file" ]; then
                if [ -w "$install_path/$file" ]; then
                    rm -f "$install_path/$file"
                    echo "  ✅ Removed: $file"
                    ((REMOVED_COUNT++))
                else
                    echo "  🔐 Need sudo to remove: $file"
                    read -p "Remove with sudo? (y/n): " USE_SUDO
                    if [[ "$USE_SUDO" =~ ^[Yy]$ ]]; then
                        sudo rm -f "$install_path/$file"
                        echo "  ✅ Removed: $file (with sudo)"
                        ((REMOVED_COUNT++))
                    else
                        echo "  ⏭️  Skipped: $file"
                    fi
                fi
            fi
        done
        
        if [ $REMOVED_COUNT -gt 0 ]; then
            echo "✅ Removed $REMOVED_COUNT file(s) from $install_path"
        else
            echo "ℹ️  No files to remove from $install_path"
        fi
    done
else
    echo "ℹ️  No installations found in common locations"
fi

# Remove configuration directory
echo ""
echo "🗂️  Removing configuration..."
echo "============================="

CONFIG_DIR="$HOME/.aws-assume-role"
if [ -d "$CONFIG_DIR" ]; then
    echo "📁 Found configuration directory: $CONFIG_DIR"
    echo "📋 Contents:"
    ls -la "$CONFIG_DIR" 2>/dev/null || echo "  (empty or inaccessible)"
    echo ""
    read -p "Remove configuration directory and all role configurations? (y/n): " REMOVE_CONFIG
    
    if [[ "$REMOVE_CONFIG" =~ ^[Yy]$ ]]; then
        rm -rf "$CONFIG_DIR"
        echo "✅ Removed configuration directory: $CONFIG_DIR"
    else
        echo "⏭️  Kept configuration directory: $CONFIG_DIR"
        echo "   (You can manually remove it later if needed)"
    fi
else
    echo "ℹ️  No configuration directory found"
fi

# Clear environment variables in current session
echo ""
echo "🌍 Clearing AWS environment variables from current session..."
echo "==========================================================="

AWS_VARS=(
    "AWS_ACCESS_KEY_ID"
    "AWS_SECRET_ACCESS_KEY" 
    "AWS_SESSION_TOKEN"
    "AWS_SECURITY_TOKEN"
    "AWS_DEFAULT_REGION"
    "AWS_REGION"
)

CLEARED_COUNT=0
for var in "${AWS_VARS[@]}"; do
    if [ -n "${!var}" ]; then
        unset "$var"
        echo "✅ Cleared: $var"
        ((CLEARED_COUNT++))
    fi
done

if [ $CLEARED_COUNT -gt 0 ]; then
    echo "✅ Cleared $CLEARED_COUNT AWS environment variable(s)"
else
    echo "ℹ️  No AWS environment variables to clear"
fi

# Final cleanup instructions
echo ""
echo "🎯 Manual Cleanup (if needed)"
echo "============================="
echo "If you installed in custom locations, you may need to manually remove:"
echo ""
echo "📁 Binary files:"
echo "  - aws-assume-role, aws-assume-role-macos, aws-assume-role-unix"
echo ""
echo "📄 Wrapper scripts:"
echo "  - aws-assume-role-bash.sh"
echo "  - aws-assume-role-fish.fish" 
echo "  - aws-assume-role-powershell.ps1"
echo "  - aws-assume-role-cmd.bat"
echo ""
echo "📝 Shell profile entries containing 'aws-assume-role'"
echo ""
echo "🗂️  Configuration directory: ~/.aws-assume-role/"

# PATH cleanup
echo ""
echo "🛣️  PATH Cleanup"
echo "==============="
echo "If you added AWS Assume Role CLI directories to your PATH, you may want to:"
echo "1. Check your PATH: echo \$PATH"
echo "2. Remove AWS Assume Role CLI directories from:"
echo "   - ~/.bashrc or ~/.zshrc (for user PATH)"
echo "   - /etc/environment (for system PATH)"
echo "   - System environment variables (Windows)"

echo ""
echo "✅ Uninstall Complete!"
echo "====================="
echo ""
echo "🔄 To complete the uninstallation:"
echo "1. Restart your terminal/shell"
echo "2. Or reload your shell profile:"

case $SHELL_TYPE in
    "bash")
        echo "   source ~/.bashrc"
        ;;
    "zsh") 
        echo "   source ~/.zshrc"
        ;;
    "fish")
        echo "   source ~/.config/fish/config.fish"
        ;;
esac

echo ""
echo "🔍 To verify removal:"
echo "   command -v awsr  # Should return 'not found'"
echo ""
echo "Thank you for using AWS Assume Role CLI! 👋" 