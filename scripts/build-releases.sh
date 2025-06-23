#!/bin/bash

# AWS Assume Role - Multi-Platform Release Builder
# Builds optimized versions for Linux, macOS (Apple Silicon), and Windows (Git Bash)

set -e

echo "🚀 Building AWS Assume Role for Linux, macOS, and Windows (Git Bash)..."

# Change to project root directory
cd "$(dirname "$0")/.."

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

# Validate development environment
validate_environment() {
    log_info "🔍 Validating development environment..."
    
    local missing_tools=()
    local missing_targets=()
    local missing_config=()
    
    # Check for required system tools
    log_info "📦 Checking system tools..."
    
    # Check for Rust
    if ! command -v cargo >/dev/null 2>&1; then
        missing_tools+=("Rust (cargo)")
    else
        local rust_version=$(cargo --version | cut -d' ' -f2)
        log_info "✅ Rust found: $rust_version"
    fi
    
    # Check for Git
    if ! command -v git >/dev/null 2>&1; then
        missing_tools+=("Git")
    else
        log_info "✅ Git found"
    fi
    
    # Check for Homebrew (macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew >/dev/null 2>&1; then
            missing_tools+=("Homebrew")
        else
            log_info "✅ Homebrew found"
        fi
    fi
    
    # Check for cross-compilation tools
    log_info "🔧 Checking cross-compilation tools..."
    
    # Check for musl-cross (Linux builds)
    if ! command -v x86_64-linux-musl-gcc >/dev/null 2>&1; then
        missing_tools+=("musl-cross (x86_64-linux-musl-gcc)")
    else
        log_info "✅ musl-cross found"
    fi
    
    # Check for mingw-w64 (Windows builds)
    if ! command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1; then
        missing_tools+=("mingw-w64 (x86_64-w64-mingw32-gcc)")
    else
        log_info "✅ mingw-w64 found"
    fi
    
    # Check for cmake
    if ! command -v cmake >/dev/null 2>&1; then
        missing_tools+=("cmake")
    else
        log_info "✅ cmake found"
    fi
    
    # Check for Rust targets
    log_info "🎯 Checking Rust targets..."
    
    if ! rustup target list --installed | grep -q "x86_64-unknown-linux-musl"; then
        missing_targets+=("x86_64-unknown-linux-musl")
    else
        log_info "✅ Rust target x86_64-unknown-linux-musl found"
    fi
    
    if ! rustup target list --installed | grep -q "x86_64-pc-windows-gnu"; then
        missing_targets+=("x86_64-pc-windows-gnu")
    else
        log_info "✅ Rust target x86_64-pc-windows-gnu found"
    fi
    
    # Check for .cargo/config.toml
    log_info "⚙️  Checking Cargo configuration..."
    
    if [[ ! -f ".cargo/config.toml" ]]; then
        missing_config+=(".cargo/config.toml")
    else
        log_info "✅ .cargo/config.toml found"
    fi
    
    # Report missing components
    if [[ ${#missing_tools[@]} -gt 0 ]] || [[ ${#missing_targets[@]} -gt 0 ]] || [[ ${#missing_config[@]} -gt 0 ]]; then
        log_error "❌ Development environment validation failed!"
        echo ""
        
        if [[ ${#missing_tools[@]} -gt 0 ]]; then
            log_error "Missing system tools:"
            for tool in "${missing_tools[@]}"; do
                echo "  - $tool"
            done
            echo ""
        fi
        
        if [[ ${#missing_targets[@]} -gt 0 ]]; then
            log_error "Missing Rust targets:"
            for target in "${missing_targets[@]}"; do
                echo "  - $target"
            done
            echo ""
        fi
        
        if [[ ${#missing_config[@]} -gt 0 ]]; then
            log_error "Missing configuration files:"
            for config in "${missing_config[@]}"; do
                echo "  - $config"
            done
            echo ""
        fi
        
        echo "�� Setup instructions:"
        echo ""
        echo "1. Install cross-compilation toolchain:"
        echo "   brew install musl-cross mingw-w64 cmake"
        echo ""
        echo "2. Add Rust targets:"
        echo "   rustup target add x86_64-unknown-linux-musl"
        echo "   rustup target add x86_64-pc-windows-gnu"
        echo ""
        echo "3. Verify .cargo/config.toml exists with proper linker configuration"
        echo ""
        echo "4. Run this script again after setup"
        echo ""
        exit 1
    fi
    
    log_info "✅ Development environment validation passed!"
    echo ""
}

# Clean previous builds
clean_builds() {
    log_info "🧹 Cleaning previous builds..."
    cargo clean
}

# Create releases directory
setup_releases_dir() {
    log_info "📁 Setting up releases directory..."
    mkdir -p releases
}

# Build for Linux
build_linux() {
    log_info "�� Building for Linux (x86_64 musl)..."
    cargo build --release --target x86_64-unknown-linux-musl
    cp target/x86_64-unknown-linux-musl/release/aws-assume-role releases/aws-assume-role-linux
    log_info "✅ Linux build completed"
}

# Build for macOS
build_macos() {
    log_info "�� Building for macOS Apple Silicon (aarch64)..."
    cargo build --release --target aarch64-apple-darwin
    cp target/aarch64-apple-darwin/release/aws-assume-role releases/aws-assume-role-macos
    log_info "✅ macOS build completed"
}

# Build for Windows
build_windows() {
    log_info "🪟 Building for Windows (Git Bash)..."
    cargo build --release --target x86_64-pc-windows-gnu
    cp target/x86_64-pc-windows-gnu/release/aws-assume-role.exe releases/aws-assume-role-windows.exe
    log_info "✅ Windows build completed"
}

# Create or preserve universal bash wrapper script
setup_wrapper() {
    log_info "📝 Setting up universal bash wrapper script..."
    
    # Check if the universal wrapper already exists
    if [ -f "releases/aws-assume-role-bash.sh" ]; then
        log_info "✅ Universal wrapper already exists - preserving existing version"
        chmod +x releases/aws-assume-role-bash.sh
    else
        log_info "�� Creating universal bash wrapper script..."
        
        cat > releases/aws-assume-role-bash.sh << 'EOF'
#!/bin/bash
# AWS Assume Role - Bash Wrapper
#
# This script should be sourced in your shell's profile (e.g., .bashrc, .zshrc)
# to enable the 'awsr' command and manage the PATH.
#
# Example for ~/.bash_profile or ~/.bashrc:
#   source "/path/to/your/install_dir/aws-assume-role-bash.sh"
#

# --- Self-Contained PATH Management ---
# Get the directory where this script is located.
_AWS_ASSUME_ROLE_SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# This function is now the single source of truth for the 'awsr' command.
awsr() {
    # 1. Determine OS and the full binary path
    local os_type
    case "$(uname -s)" in
        Linux*)   os_type="linux" ;;
        Darwin*)  os_type="macos" ;;
        MINGW*|MSYS*|CYGWIN*) os_type="windows" ;;
        *)
            echo "awsr: Unsupported OS: $(uname -s)" >&2
            return 1
            ;;
    esac

    local binary_name="aws-assume-role-$os_type"
    if [ "$os_type" = "windows" ]; then
        binary_name="aws-assume-role-windows.exe"
    fi
    
    # Construct the full, absolute path to the binary.
    # This avoids all PATH-related issues.
    local binary_path="$_AWS_ASSUME_ROLE_SCRIPT_DIR/$binary_name"

    if [ ! -x "$binary_path" ]; then
        echo "awsr: Error: binary not found or not executable at '$binary_path'" >&2
        return 1
    fi

    # 2. Handle the 'assume' command to modify the current shell
    if [ "$1" = "assume" ]; then
        local output
        # Pass all arguments to the binary and request 'export' format.
        # If the command fails, its stderr will be captured in 'output'.
        if output=$("$binary_path" "$@" --format export); then
            # On success, evaluate the output to set environment variables.
            eval "$output"
        else
            # On failure, print the error captured from the binary and return failure.
            echo "$output" >&2
            return 1
        fi
    else
        # 3. For all other commands, execute the binary directly.
        # This passes through args, stdout, stderr, and exit codes correctly.
        "$binary_path" "$@"
    fi
}
EOF

        # Make script executable
        chmod +x releases/aws-assume-role-bash.sh
        log_info "✅ Universal wrapper created successfully"
    fi
}

# Display build results
show_results() {
    log_info "✅ Multi-platform releases built successfully!"
    echo ""
    log_info "📁 Files created in releases/:"
    ls -la releases/
    echo ""
    log_info "�� Usage instructions:"
    echo ""
    echo "All platforms (Linux, macOS, Windows Git Bash):"
    echo "  source aws-assume-role-bash.sh"
    echo "  awsr assume <role-name>"
    echo ""
    echo "Supported platforms:"
    echo "  �� Linux (x86_64 musl)"
    echo "  🍎 macOS Apple Silicon (aarch64)"
    echo "  �� Windows Git Bash (x86_64)"
    echo ""
    log_info "🧪 Next steps:"
    echo "  ./dev-cli.sh check # Run all tests"
    echo ""
    log_info "📚 For more details, see: docs/DEVELOPER_WORKFLOW.md"
    echo ""
}

# Main build process
main() {
    validate_environment
    clean_builds
    setup_releases_dir
    
    build_linux
    build_macos
    build_windows
    
    setup_wrapper
    show_results
}

# Run main function
main