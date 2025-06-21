#!/bin/bash

# AWS Assume Role CLI Tool - Installation Script
# Supports: macOS, Linux, Git Bash

set -e

echo "🚀 AWS Assume Role CLI Tool - Installation Script"
echo "=================================================="

# Debug information
echo "🔍 Debug Information:"
echo "  OSTYPE: $OSTYPE"
echo "  SHELL: $SHELL"
echo "  PWD: $(pwd)"
echo "  Available files:"
ls -la | head -10

# Detect OS with improved logic
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS="gitbash"
elif [[ "$OSTYPE" == *"msys"* ]] || [[ "$OSTYPE" == *"mingw"* ]] || [[ "$OSTYPE" == *"cygwin"* ]]; then
    # Additional patterns for Git Bash detection
    OS="gitbash"
elif command -v winpty >/dev/null 2>&1 || [[ -n "$WINDIR" ]] || [[ -n "$SYSTEMROOT" ]]; then
    # Fallback: detect Windows environment variables or winpty (common in Git Bash)
    echo "🔍 Windows environment detected via fallback method"
    OS="gitbash"
fi

echo "📍 Detected OS: $OS"

# Set binary name based on OS
BINARY_NAME=""
case $OS in
    "macos")
        BINARY_NAME="aws-assume-role-macos"
        ;;
    "linux")
        BINARY_NAME="aws-assume-role-unix"
        ;;
    "gitbash")
        # Git Bash on Windows needs a Windows executable
        if [ -f "aws-assume-role.exe" ]; then
            BINARY_NAME="aws-assume-role.exe"
            echo "✅ Found Windows executable: $BINARY_NAME"
        else
            echo "❌ AWS Assume Role binary not found!"
            echo "For Git Bash on Windows, you need: aws-assume-role.exe"
            echo ""
            echo "Available files in this directory:"
            ls -la *.exe 2>/dev/null || echo "No .exe files found"
            echo ""
            echo "All files in directory:"
            ls -la
            echo ""
            echo "Please ensure you've downloaded the correct release package."
            echo "Alternatively, use Windows PowerShell installation:"
            echo "  .\INSTALL.ps1"
            exit 1
        fi
        ;;
    *)
        echo "❌ Unsupported operating system: $OSTYPE"
        echo ""
        echo "If you're using Git Bash on Windows, please try:"
        echo "1. Make sure you're in the directory with aws-assume-role.exe"
        echo "2. Run: OSTYPE=msys ./INSTALL.sh"
        echo "3. Or use PowerShell: .\INSTALL.ps1"
        echo ""
        echo "Available files in this directory:"
        ls -la
        exit 1
        ;;
esac

# Check if files exist
if [ ! -f "$BINARY_NAME" ]; then
    echo "❌ Binary not found: $BINARY_NAME"
    echo "Please ensure you're running this script from the directory containing the AWS Assume Role files."
    echo ""
    echo "Available files:"
    ls -la
    exit 1
fi

echo "✅ Found binary: $BINARY_NAME"

# Detect shell
SHELL_TYPE="unknown"
if [[ "$SHELL" == *"bash"* ]]; then
    SHELL_TYPE="bash"
elif [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_TYPE="zsh"
elif [[ "$SHELL" == *"fish"* ]]; then
    SHELL_TYPE="fish"
else
    echo "🔍 Could not detect shell type. Defaulting to bash."
    SHELL_TYPE="bash"
fi

echo "🐚 Detected shell: $SHELL_TYPE"

# Installation options
echo ""
echo "📦 Installation Options:"
echo "1. Install to current directory (recommended for testing)"
echo "2. Install to /usr/local/bin (system-wide, requires sudo)"
echo "3. Install to ~/.local/bin (user-specific)"
echo "4. Custom directory"
echo ""
read -p "Choose installation option (1-4): " INSTALL_OPTION

INSTALL_DIR=""
case $INSTALL_OPTION in
    1)
        INSTALL_DIR="$(pwd)"
        echo "📁 Installing to current directory: $INSTALL_DIR"
        ;;
    2)
        INSTALL_DIR="/usr/local/bin"
        echo "📁 Installing to system directory: $INSTALL_DIR"
        if [ ! -w "$INSTALL_DIR" ]; then
            echo "🔐 This requires sudo privileges..."
            SUDO_REQUIRED=true
        fi
        ;;
    3)
        INSTALL_DIR="$HOME/.local/bin"
        echo "📁 Installing to user directory: $INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
        ;;
    4)
        read -p "Enter custom directory path: " INSTALL_DIR
        echo "📁 Installing to custom directory: $INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
        ;;
    *)
        echo "❌ Invalid option. Exiting."
        exit 1
        ;;
esac

# Copy files
echo ""
echo "📋 Installing files..."

# Determine target binary name
TARGET_BINARY_NAME="aws-assume-role"
if [ "$OS" = "gitbash" ]; then
    TARGET_BINARY_NAME="aws-assume-role.exe"
fi

if [ "$SUDO_REQUIRED" = true ]; then
    echo "🔐 Copying binary (requires sudo)..."
    sudo cp "$BINARY_NAME" "$INSTALL_DIR/$TARGET_BINARY_NAME"
    sudo chmod +x "$INSTALL_DIR/$TARGET_BINARY_NAME"
    
    echo "🔐 Copying wrapper scripts (requires sudo)..."
    sudo cp aws-assume-role-bash.sh "$INSTALL_DIR/"
    sudo cp aws-assume-role-fish.fish "$INSTALL_DIR/"
else
    echo "📄 Copying binary..."
    cp "$BINARY_NAME" "$INSTALL_DIR/$TARGET_BINARY_NAME"
    chmod +x "$INSTALL_DIR/$TARGET_BINARY_NAME"
    
    echo "📄 Copying wrapper scripts..."
    cp aws-assume-role-bash.sh "$INSTALL_DIR/"
    cp aws-assume-role-fish.fish "$INSTALL_DIR/"
fi

# Update wrapper scripts to use the correct binary path
if [ "$INSTALL_DIR" != "$(pwd)" ]; then
    echo "🔧 Updating wrapper script paths..."
    
    # Determine target binary name for wrapper updates
    TARGET_BINARY="$INSTALL_DIR/aws-assume-role"
    if [ "$OS" = "gitbash" ]; then
        TARGET_BINARY="$INSTALL_DIR/aws-assume-role.exe"
    fi
    
    # Update bash wrapper
    if [ "$SUDO_REQUIRED" = true ]; then
        sudo sed -i.bak "s|./aws-assume-role-unix|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-bash.sh"
        sudo sed -i.bak "s|./aws-assume-role-macos|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-bash.sh"
        sudo sed -i.bak "s|./aws-assume-role-windows.exe|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-bash.sh"
        sudo sed -i.bak "s|./aws-assume-role.exe|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-bash.sh"
        sudo rm -f "$INSTALL_DIR/aws-assume-role-bash.sh.bak"
    else
        sed -i.bak "s|./aws-assume-role-unix|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-bash.sh"
        sed -i.bak "s|./aws-assume-role-macos|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-bash.sh"
        sed -i.bak "s|./aws-assume-role-windows.exe|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-bash.sh"
        sed -i.bak "s|./aws-assume-role.exe|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-bash.sh"
        rm -f "$INSTALL_DIR/aws-assume-role-bash.sh.bak"
    fi
    
    # Update fish wrapper
    if [ "$SUDO_REQUIRED" = true ]; then
        sudo sed -i.bak "s|./aws-assume-role-unix|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-fish.fish"
        sudo sed -i.bak "s|./aws-assume-role-macos|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-fish.fish"
        sudo sed -i.bak "s|./aws-assume-role-windows.exe|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-fish.fish"
        sudo sed -i.bak "s|./aws-assume-role.exe|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-fish.fish"
        sudo rm -f "$INSTALL_DIR/aws-assume-role-fish.fish.bak"
    else
        sed -i.bak "s|./aws-assume-role-unix|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-fish.fish"
        sed -i.bak "s|./aws-assume-role-macos|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-fish.fish"
        sed -i.bak "s|./aws-assume-role-windows.exe|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-fish.fish"
        sed -i.bak "s|./aws-assume-role.exe|$TARGET_BINARY|g" "$INSTALL_DIR/aws-assume-role-fish.fish"
        rm -f "$INSTALL_DIR/aws-assume-role-fish.fish.bak"
    fi
fi

# Shell profile configuration
echo ""
echo "🔧 Shell Configuration"
echo "======================"

WRAPPER_PATH="$INSTALL_DIR/aws-assume-role-bash.sh"
if [ "$SHELL_TYPE" = "fish" ]; then
    WRAPPER_PATH="$INSTALL_DIR/aws-assume-role-fish.fish"
fi

echo "To use AWS Assume Role CLI, you need to source the wrapper script."
echo ""
echo "Option 1 - Load for current session only:"
if [ "$SHELL_TYPE" = "fish" ]; then
    echo "  source $WRAPPER_PATH"
else
    echo "  source $WRAPPER_PATH"
fi

echo ""
echo "Option 2 - Add to your shell profile for permanent use:"

case $SHELL_TYPE in
    "bash")
        echo "  echo 'source $WRAPPER_PATH' >> ~/.bashrc"
        echo "  source ~/.bashrc"
        ;;
    "zsh")
        echo "  echo 'source $WRAPPER_PATH' >> ~/.zshrc"
        echo "  source ~/.zshrc"
        ;;
    "fish")
        echo "  echo 'source $WRAPPER_PATH' >> ~/.config/fish/config.fish"
        ;;
esac

echo ""
read -p "Would you like to add to your shell profile now? (y/n): " ADD_TO_PROFILE

if [[ "$ADD_TO_PROFILE" =~ ^[Yy]$ ]]; then
    case $SHELL_TYPE in
        "bash")
            echo "source $WRAPPER_PATH" >> ~/.bashrc
            echo "✅ Added to ~/.bashrc"
            ;;
        "zsh")
            echo "source $WRAPPER_PATH" >> ~/.zshrc
            echo "✅ Added to ~/.zshrc"
            ;;
        "fish")
            mkdir -p ~/.config/fish
            echo "source $WRAPPER_PATH" >> ~/.config/fish/config.fish
            echo "✅ Added to ~/.config/fish/config.fish"
            ;;
    esac
    echo "🔄 Please restart your shell or run 'source' command to load the changes."
fi

# Test installation
echo ""
echo "🧪 Testing Installation"
echo "======================="

# Source the wrapper for testing
if [ "$SHELL_TYPE" = "fish" ]; then
    echo "⚠️  Cannot test Fish shell automatically. Please run: source $WRAPPER_PATH"
else
    echo "📋 Loading wrapper script..."
    source "$WRAPPER_PATH"
    
    echo "🔍 Testing command availability..."
    if command -v awsr >/dev/null 2>&1; then
        echo "✅ awsr command is available!"
        echo ""
        echo "📋 Available commands:"
        awsr --help 2>/dev/null || echo "  awsr list, awsr configure, awsr assume, awsr remove"
    else
        echo "❌ awsr command not found. Please check the installation."
    fi
fi

echo ""
echo "🎉 Installation Complete!"
echo "========================"
echo ""

# Show installation summary
echo "📁 Files installed to: $INSTALL_DIR"
echo "   - Binary: $INSTALL_DIR/$TARGET_BINARY_NAME"
echo "   - Bash wrapper: $INSTALL_DIR/aws-assume-role-bash.sh"
echo "   - Fish wrapper: $INSTALL_DIR/aws-assume-role-fish.fish"
echo ""

# Cleanup instructions
echo "🧹 Cleanup"
echo "=========="
if [ "$INSTALL_DIR" = "$(pwd)" ]; then
    echo "⚠️  Files were installed to the current directory."
    echo "   Keep this folder as it contains the installed files."
else
    echo "✅ All files have been copied to: $INSTALL_DIR"
    echo "   You can now safely delete this extracted folder:"
    echo "   cd .. && rm -rf $(basename "$(pwd)")"
fi
echo ""

echo "📖 Next Steps:"
echo "1. Ensure you have AWS credentials configured:"
echo "   aws sts get-caller-identity"
echo ""
echo "2. Configure your first role:"
echo "   awsr configure --name \"my-role\" --role-arn \"arn:aws:iam::123456789012:role/MyRole\" --account-id \"123456789012\""
echo ""
echo "3. Assume the role:"
echo "   awsr assume my-role"
echo ""
echo "📚 For detailed usage instructions, see README.md"
echo ""
echo "🚀 Happy role switching!" 