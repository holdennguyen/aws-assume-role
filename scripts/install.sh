#!/bin/bash

# AWS Assume Role CLI - Universal Installation Script
# Works for development builds and distribution packages
# Supports: Linux (x86_64), macOS (Apple Silicon), Windows (Git Bash)

set -e

# Change to script directory for relative path operations
cd "$(dirname "$0")"

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
    echo "AWS Assume Role CLI - Universal Installation Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --local                 Install from local build (development)"
    echo "  --dir <path>           Custom installation directory"
    echo "  --help, -h             Show this help"
    echo ""
    echo "Installation modes:"
    echo "  1. Distribution package (if platform-specific binaries found)"
    echo "  2. Local development build (if target/release/ exists)"
    echo "  3. Download from GitHub releases (if --download specified)"
    echo ""
    echo "Examples:"
    echo "  $0                     # Auto-detect and install"
    echo "  $0 --local            # Force local build installation"
    echo "  $0 --dir ~/.local/bin # Install to custom directory"
    echo ""
}

# Detect operating system and platform
detect_platform() {
    local os_type=$(uname -s)
    
    case "$os_type" in
        Linux*)
            OS="linux"
            BINARY_NAME="aws-assume-role-linux"
            ;;
        Darwin*)
            OS="macos"
            BINARY_NAME="aws-assume-role-macos"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            OS="gitbash"
            BINARY_NAME="aws-assume-role-windows.exe"
            ;;
        *)
            # Fallback detection for Windows
            if [[ -n "$WINDIR" ]] || [[ -n "$SYSTEMROOT" ]] || command -v winpty >/dev/null 2>&1; then
                OS="gitbash"
                BINARY_NAME="aws-assume-role-windows.exe"
            else
                log_error "Unsupported operating system: $os_type"
                log_info "Supported platforms: Linux (x86_64), macOS (Apple Silicon), Windows (Git Bash)"
                exit 1
            fi
            ;;
    esac
    
    log_info "Detected platform: $OS"
    log_info "Expected binary: $BINARY_NAME"
}

# Determine installation mode
determine_install_mode() {
    INSTALL_MODE=""
    
    # Check for distribution package (platform-specific binaries)
    if [[ -f "$BINARY_NAME" ]] || [[ -f "../releases/$BINARY_NAME" ]]; then
        INSTALL_MODE="distribution"
        log_info "Distribution package detected"
        
        # Set source path
        if [[ -f "$BINARY_NAME" ]]; then
            SOURCE_DIR="."
        else
            SOURCE_DIR="../releases"
        fi
        
    # Check for local development build
    elif [[ -f "../target/release/aws-assume-role" ]]; then
        INSTALL_MODE="development"
        log_info "Local development build detected"
        SOURCE_DIR="../target/release"
        BINARY_NAME="aws-assume-role"
        
    else
        log_error "No installation source found!"
        echo ""
        echo "Available options:"
        echo "1. For distribution: Ensure you're in the extracted package directory"
        echo "2. For development: Run 'cargo build --release' first"
        echo "3. Check that platform-specific binary exists:"
        echo "   - Linux: aws-assume-role-linux"
        echo "   - macOS: aws-assume-role-macos" 
        echo "   - Windows Git Bash: aws-assume-role-windows.exe"
        echo ""
        echo "Current directory contents:"
        ls -la
        exit 1
    fi
}

# Get installation directory
get_install_dir() {
    if [[ -n "$CUSTOM_INSTALL_DIR" ]]; then
        INSTALL_DIR="$CUSTOM_INSTALL_DIR"
        log_info "Using custom directory: $INSTALL_DIR"
        return
    fi
    
    echo ""
    echo "📦 Installation Directory Options:"
    echo "1. ~/.local/bin (user-specific, recommended)"
    echo "2. /usr/local/bin (system-wide, requires sudo)"
    echo "3. Current directory (testing only)"
    echo "4. Custom directory"
    echo ""
    read -p "Choose option (1-4): " choice
    
    case $choice in
        1)
            INSTALL_DIR="$HOME/.local/bin"
            mkdir -p "$INSTALL_DIR"
            log_info "Installing to user directory: $INSTALL_DIR"
            ;;
        2)
            INSTALL_DIR="/usr/local/bin"
            if [[ ! -w "$INSTALL_DIR" ]]; then
                REQUIRE_SUDO=true
                log_warn "System directory requires sudo privileges"
            fi
            log_info "Installing to system directory: $INSTALL_DIR"
            ;;
        3)
            INSTALL_DIR="$(pwd)"
            log_info "Installing to current directory: $INSTALL_DIR"
            ;;
        4)
            read -p "Enter custom directory path: " INSTALL_DIR
            mkdir -p "$INSTALL_DIR"
            log_info "Installing to custom directory: $INSTALL_DIR"
            ;;
        *)
            log_error "Invalid option"
            exit 1
            ;;
    esac
}

# Install files
install_files() {
    log_info "📋 Installing files..."
    
    # Determine copy command
    local copy_cmd="cp"
    if [[ "$REQUIRE_SUDO" == "true" ]]; then
        copy_cmd="sudo cp"
        log_warn "Using sudo for system directory installation"
    fi
    
    # Install main binary
    local target_name="aws-assume-role"
    if [[ "$OS" == "gitbash" ]]; then
        target_name="aws-assume-role.exe"
    fi
    
    log_info "Installing binary: $BINARY_NAME → $target_name"
    $copy_cmd "$SOURCE_DIR/$BINARY_NAME" "$INSTALL_DIR/$target_name"
    
    if [[ "$REQUIRE_SUDO" == "true" ]]; then
        sudo chmod +x "$INSTALL_DIR/$target_name"
    else
        chmod +x "$INSTALL_DIR/$target_name"
    fi
    
    # Install bash wrapper if in distribution mode
    if [[ "$INSTALL_MODE" == "distribution" ]] && [[ -f "$SOURCE_DIR/aws-assume-role-bash.sh" ]]; then
        log_info "Installing bash wrapper..."
        $copy_cmd "$SOURCE_DIR/aws-assume-role-bash.sh" "$INSTALL_DIR/"
        
        if [[ "$REQUIRE_SUDO" == "true" ]]; then
            sudo chmod +x "$INSTALL_DIR/aws-assume-role-bash.sh"
        else
            chmod +x "$INSTALL_DIR/aws-assume-role-bash.sh"
        fi
    fi
    
    log_info "✅ Files installed successfully"
}

# Configure shell integration
configure_shell() {
    log_info "🔧 Shell Integration"
    
    # Detect shell
    local shell_name=$(basename "$SHELL" 2>/dev/null || echo "bash")
    log_info "Detected shell: $shell_name"
    
    if [[ "$INSTALL_MODE" == "distribution" ]] && [[ -f "$INSTALL_DIR/aws-assume-role-bash.sh" ]]; then
        # Distribution mode with wrapper
        echo ""
        echo "🎯 To use AWS Assume Role CLI with shell integration:"
        echo ""
        echo "Option 1 - Load for current session:"
        echo "  source $INSTALL_DIR/aws-assume-role-bash.sh"
        echo ""
        echo "Option 2 - Add to shell profile for permanent use:"
        case $shell_name in
            bash)
                echo "  echo 'source $INSTALL_DIR/aws-assume-role-bash.sh' >> ~/.bashrc"
                ;;
            zsh)
                echo "  echo 'source $INSTALL_DIR/aws-assume-role-bash.sh' >> ~/.zshrc"
                ;;
            *)
                echo "  echo 'source $INSTALL_DIR/aws-assume-role-bash.sh' >> ~/.${shell_name}rc"
                ;;
        esac
        
        echo ""
        echo "After sourcing the wrapper, use:"
        echo "  awsr assume <role-name>"
        echo "  awsr list"
        echo "  awsr configure --name <name> --role-arn <arn> --account-id <id>"
    else
        # Direct binary usage
        echo ""
        echo "🎯 To use AWS Assume Role CLI:"
        echo ""
        if [[ "$INSTALL_DIR" != *"/bin"* ]] && [[ "$INSTALL_DIR" != "$(pwd)" ]]; then
            echo "Add to PATH (if not already):"
            echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
            echo ""
        fi
        echo "Basic usage:"
        echo "  aws-assume-role configure --name <name> --role-arn <arn> --account-id <id>"
        echo "  aws-assume-role assume <role-name>"
        echo "  eval \$(aws-assume-role assume <role-name>)  # Set in current shell"
    fi
    
    echo ""
    echo "📋 Next steps:"
    echo "1. Configure a role with your AWS account details"
    echo "2. Test with: aws-assume-role --help"
    echo "3. See documentation: https://github.com/holdennguyen/aws-assume-role"
}

# Verify installation
verify_installation() {
    log_info "🔍 Verifying installation..."
    
    local binary_path="$INSTALL_DIR/aws-assume-role"
    if [[ "$OS" == "gitbash" ]]; then
        binary_path="$INSTALL_DIR/aws-assume-role.exe"
    fi
    
    if [[ -f "$binary_path" ]]; then
        log_info "✅ Binary installed: $binary_path"
        
        # Test if binary is executable and shows version
        if "$binary_path" --version >/dev/null 2>&1; then
            local version=$("$binary_path" --version 2>/dev/null || echo "unknown")
            log_info "✅ Binary is working: $version"
        else
            log_warn "⚠️  Binary installed but may not be working properly"
        fi
    else
        log_error "❌ Installation verification failed"
        exit 1
    fi
}

# Main installation process
main() {
    echo "🚀 AWS Assume Role CLI - Universal Installation Script"
    echo "====================================================="
    echo "📱 Supports: Linux (x86_64), macOS (Apple Silicon), Windows (Git Bash)"
    echo ""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --local)
                FORCE_LOCAL=true
                shift
                ;;
            --dir)
                CUSTOM_INSTALL_DIR="$2"
                shift 2
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
    
    # Main installation flow
    detect_platform
    
    if [[ "$FORCE_LOCAL" == "true" ]]; then
        INSTALL_MODE="development"
        SOURCE_DIR="../target/release"
        BINARY_NAME="aws-assume-role"
        log_info "Forced local installation mode"
    else
        determine_install_mode
    fi
    
    get_install_dir
    install_files
    verify_installation
    configure_shell
    
    echo ""
    log_info "🎉 Installation completed successfully!"
    echo ""
    echo "🎯 Supported platforms:"
    echo "  🐧 Linux (x86_64)"
    echo "  🍎 macOS Apple Silicon (aarch64)" 
    echo "  🪟 Windows Git Bash (x86_64)"
}

# Run main function with all arguments
main "$@" 