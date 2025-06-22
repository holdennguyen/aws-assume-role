#!/bin/bash

# AWS Assume Role - Multi-Platform Release Builder
# Builds optimized versions for Linux, macOS (Apple Silicon), and Windows (Git Bash)

set -e

echo "🚀 Building AWS Assume Role for Linux, macOS, and Windows (Git Bash)..."

# Change to project root directory
cd "$(dirname "$0")/.."

# Clean previous builds
cargo clean

# Create releases directory
mkdir -p releases

# Build for Linux
echo "📦 Building for Linux (x86_64)..."
cargo build --release --target x86_64-unknown-linux-musl
cp target/x86_64-unknown-linux-musl/release/aws-assume-role releases/aws-assume-role-linux

# Build for macOS Apple Silicon
echo "📦 Building for macOS Apple Silicon (aarch64)..."
cargo build --release --target aarch64-apple-darwin
cp target/aarch64-apple-darwin/release/aws-assume-role releases/aws-assume-role-macos

# Build for Windows (for Git Bash usage)
echo "📦 Building for Windows (Git Bash)..."
if command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1; then
    cargo build --release --target x86_64-pc-windows-gnu
    cp target/x86_64-pc-windows-gnu/release/aws-assume-role.exe releases/aws-assume-role-windows.exe
else
    echo "⚠️  Windows cross-compilation not available. Install mingw-w64 for Windows builds."
    echo "   On macOS: brew install mingw-w64"
    echo "   On Ubuntu: sudo apt-get install mingw-w64"
fi

# Create universal bash wrapper script
echo "📝 Creating universal bash wrapper script..."

cat > releases/aws-assume-role-bash.sh << 'EOF'
#!/bin/bash
# AWS Assume Role - Universal Bash Wrapper
# Works on Linux, macOS, and Windows (Git Bash)
# Usage: source aws-assume-role-bash.sh

aws_assume_role() {
    local binary_path=""
    local os_type=$(uname -s)
    
    # Detect platform and find appropriate binary
    case "$os_type" in
        Linux*)
            if [ -f "./aws-assume-role-linux" ]; then
                binary_path="./aws-assume-role-linux"
            elif command -v aws-assume-role >/dev/null 2>&1; then
                binary_path="aws-assume-role"
            fi
            ;;
        Darwin*)
            if [ -f "./aws-assume-role-macos" ]; then
                binary_path="./aws-assume-role-macos"
            elif command -v aws-assume-role >/dev/null 2>&1; then
                binary_path="aws-assume-role"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            if [ -f "./aws-assume-role-windows.exe" ]; then
                binary_path="./aws-assume-role-windows.exe"
            elif [ -f "./aws-assume-role.exe" ]; then
                binary_path="./aws-assume-role.exe"
            elif command -v aws-assume-role.exe >/dev/null 2>&1; then
                binary_path="aws-assume-role.exe"
            elif command -v aws-assume-role >/dev/null 2>&1; then
                binary_path="aws-assume-role"
            fi
            ;;
        *)
            echo "❌ Unsupported operating system: $os_type"
            return 1
            ;;
    esac
    
    if [ -z "$binary_path" ]; then
        echo "❌ AWS Assume Role binary not found for $os_type"
        echo "   Make sure the appropriate binary is in your PATH or current directory"
        return 1
    fi
    
    if [ "$1" = "assume" ] && [ -n "$2" ]; then
        echo "🔄 Assuming role: $2"
        eval $($binary_path assume "$2" "${@:3}" --format export 2>/dev/null)
        if [ $? -eq 0 ]; then
            echo "🎯 Role assumed successfully in current shell!"
            echo "Current AWS identity:"
            aws sts get-caller-identity --query 'Arn' --output text 2>/dev/null || echo "Failed to verify identity"
        fi
    else
        $binary_path "$@"
    fi
}

# Create alias for convenience
alias awsr='aws_assume_role'

echo "✅ AWS Assume Role loaded for $(uname -s)"
echo "Usage: awsr assume <role-name>"
echo "       awsr list"
echo "       awsr configure --name <name> --role-arn <arn> --account-id <id>"
EOF

# Make script executable
chmod +x releases/aws-assume-role-bash.sh

echo "✅ Multi-platform releases built successfully!"
echo ""
echo "📁 Files created in releases/:"
ls -la releases/
echo ""
echo "🎯 Usage instructions:"
echo ""
echo "All platforms (Linux, macOS, Windows Git Bash):"
echo "  source aws-assume-role-bash.sh"
echo "  awsr assume <role-name>"
echo ""
echo "Supported platforms:"
echo "  🐧 Linux (x86_64)"
echo "  🍎 macOS Apple Silicon (aarch64)"
echo "  🪟 Windows Git Bash (x86_64)" 