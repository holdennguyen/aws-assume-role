#!/usr/bin/env fish
# AWS Assume Role - Fish Shell Wrapper
# Usage: source aws-assume-role-fish.fish

function aws_assume_role
    set binary_path ""
    
    # Detect the current platform
    set os_type ""
    if string match -q "msys" "$OSTYPE"; or string match -q "cygwin" "$OSTYPE"
        set os_type "windows"
    else if string match -q "darwin*" "$OSTYPE"
        set os_type "macos"
    else if string match -q "linux-gnu*" "$OSTYPE"
        set os_type "linux"
    end
    
    # Try to find the binary based on platform preference
    if test "$os_type" = "windows"
        # Windows/Git Bash - prefer .exe
        if test -f "./aws-assume-role.exe"
            set binary_path "./aws-assume-role.exe"
        else if command -v aws-assume-role.exe >/dev/null 2>&1
            set binary_path "aws-assume-role.exe"
        else if test -f "./aws-assume-role-unix"
            set binary_path "./aws-assume-role-unix"
        else if command -v aws-assume-role >/dev/null 2>&1
            set binary_path "aws-assume-role"
        end
    else if test "$os_type" = "macos"
        # macOS - prefer macOS binary
        if test -f "./aws-assume-role-macos"
            set binary_path "./aws-assume-role-macos"
        else if test -f "./aws-assume-role-unix"
            set binary_path "./aws-assume-role-unix"
        else if command -v aws-assume-role-macos >/dev/null 2>&1
            set binary_path "aws-assume-role-macos"
        else if command -v aws-assume-role >/dev/null 2>&1
            set binary_path "aws-assume-role"
        end
    else
        # Linux/Unix - prefer unix binary
        if test -f "./aws-assume-role-unix"
            set binary_path "./aws-assume-role-unix"
        else if test -f "./aws-assume-role-macos"
            set binary_path "./aws-assume-role-macos"
        else if command -v aws-assume-role-unix >/dev/null 2>&1
            set binary_path "aws-assume-role-unix"
        else if command -v aws-assume-role >/dev/null 2>&1
            set binary_path "aws-assume-role"
        end
    end
    
    # If no platform-specific binary found, try generic detection
    if test -z "$binary_path"
        if test -f "./aws-assume-role-unix"
            set binary_path "./aws-assume-role-unix"
        else if test -f "./aws-assume-role-macos"
            set binary_path "./aws-assume-role-macos"
        else if test -f "./aws-assume-role.exe"
            set binary_path "./aws-assume-role.exe"
        else if command -v aws-assume-role >/dev/null 2>&1
            set binary_path "aws-assume-role"
        end
    end
    
    # Final check
    if test -z "$binary_path"
        echo "❌ AWS Assume Role binary not found"
        echo "Platform detected: $os_type (OSTYPE=$OSTYPE)"
        echo "Looking for platform-appropriate binary:"
        switch "$os_type"
            case "windows"
                echo "  - aws-assume-role.exe (preferred for Git Bash)"
            case "macos"
                echo "  - aws-assume-role-macos (preferred for macOS)"
            case '*'
                echo "  - aws-assume-role-unix (preferred for Linux/Unix)"
        end
        echo "Current directory: "(pwd)
        echo "Available files:"
        ls -la aws-assume-role* 2>/dev/null; or echo "No aws-assume-role files found"
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

# Function to clear AWS credentials from current shell
function clear_aws_creds
    set -e AWS_ACCESS_KEY_ID
    set -e AWS_SECRET_ACCESS_KEY
    set -e AWS_SESSION_TOKEN
    echo "✅ AWS credentials cleared from current shell"
end

# Function to show current AWS identity
function aws_whoami
    if command -v aws >/dev/null 2>&1
        echo "Current AWS identity:"
        aws sts get-caller-identity 2>/dev/null; or echo "No valid AWS credentials found"
    else
        echo "AWS CLI not found"
    end
end

# Create alias for convenience
alias awsr='aws_assume_role'

echo "✅ AWS Assume Role loaded for Fish Shell"
echo "Usage: awsr assume <role-name>"
echo "       awsr list"
echo "       awsr configure --name <name> --role-arn <arn> --account-id <id>"
echo "       clear_aws_creds (clear credentials)"
echo "       aws_whoami (show current identity)"
