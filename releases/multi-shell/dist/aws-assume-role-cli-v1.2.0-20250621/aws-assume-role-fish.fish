#!/usr/bin/env fish
# AWS Assume Role - Fish Shell Wrapper
# Usage: source aws-assume-role-fish.fish

function aws_assume_role
    set binary_path ""
    
    # Try to find the binary
    if test -f "./aws-assume-role-unix"
        set binary_path "./aws-assume-role-unix"
    else if test -f "./aws-assume-role-macos"
        set binary_path "./aws-assume-role-macos"
    else if command -v aws-assume-role-unix >/dev/null 2>&1
        set binary_path "aws-assume-role-unix"
    else if command -v aws-assume-role >/dev/null 2>&1
        set binary_path "aws-assume-role"
    else
        echo "❌ AWS Assume Role binary not found"
        return 1
    end
    
    if test "$argv[1]" = "assume"; and test -n "$argv[2]"
        echo "🔄 Assuming role: $argv[2]"
        eval ($binary_path assume $argv[2..-1] --format export 2>/dev/null)
        if test $status -eq 0
            echo "🎯 Role assumed successfully in current shell!"
            echo "Current AWS identity:"
            aws sts get-caller-identity --query 'Arn' --output text 2>/dev/null; or echo "Failed to verify identity"
        end
    else
        $binary_path $argv
    end
end

# Create alias for convenience
alias awsr='aws_assume_role'

echo "✅ AWS Assume Role loaded for Fish Shell"
echo "Usage: awsr assume <role-name>"
echo "       awsr list"
echo "       awsr configure --name <name> --role-arn <arn> --account-id <id>"
