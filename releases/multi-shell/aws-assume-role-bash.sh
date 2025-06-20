#!/bin/bash
# AWS Assume Role - Bash/Zsh Wrapper
# 
# IMPORTANT: This script provides the 'awsr' command for shell integration.
# 
# COMMANDS AVAILABLE:
#   aws-assume-role  - Direct binary execution (requires eval for credentials)
#   awsr            - Wrapper function (sets credentials directly in shell)
# 
# RECOMMENDED: Use 'awsr' for daily role switching
# 
# Usage: source aws-assume-role-bash.sh

aws_assume_role() {
    local binary_name="aws-assume-role-unix"
    
    # Try to find the binary
    if [ -f "./aws-assume-role-unix" ]; then
        binary_path="./aws-assume-role-unix"
    elif [ -f "./aws-assume-role-macos" ]; then
        binary_path="./aws-assume-role-macos"
    elif command -v aws-assume-role-unix >/dev/null 2>&1; then
        binary_path="aws-assume-role-unix"
    elif command -v aws-assume-role >/dev/null 2>&1; then
        binary_path="aws-assume-role"
    else
        echo "❌ AWS Assume Role binary not found"
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

echo "✅ AWS Assume Role loaded for Bash/Zsh"
echo ""
echo "📋 COMMANDS AVAILABLE:"
echo "  awsr                    - Wrapper function (recommended)"
echo "  aws-assume-role         - Direct binary (requires eval)"
echo ""
echo "🚀 QUICK START:"
echo "  awsr verify             - Check prerequisites"
echo "  awsr configure -n dev -r <role-arn> -a <account-id>"
echo "  awsr assume dev         - Assume role (sets credentials in shell)"
echo "  awsr list               - List configured roles"
echo ""
echo "💡 TIP: Use 'awsr' for seamless role switching without eval commands!"
