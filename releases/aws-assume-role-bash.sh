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
