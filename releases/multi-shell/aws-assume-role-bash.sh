#!/bin/bash
# AWS Assume Role - Bash/Zsh Wrapper
# Usage: source aws-assume-role-bash.sh assume <role-name>

aws_assume_role() {
    local binary_path=""
    
    # Detect the current platform
    local os_type=""
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        os_type="windows"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os_type="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os_type="linux"
    fi
    
    # Try to find the binary based on platform preference
    if [[ "$os_type" == "windows" ]]; then
        # Windows/Git Bash - prefer .exe
        if [ -f "./aws-assume-role.exe" ]; then
            binary_path="./aws-assume-role.exe"
        elif command -v aws-assume-role.exe >/dev/null 2>&1; then
            binary_path="aws-assume-role.exe"
        elif [ -f "./aws-assume-role-unix" ]; then
            binary_path="./aws-assume-role-unix"
        elif command -v aws-assume-role >/dev/null 2>&1; then
            binary_path="aws-assume-role"
        fi
    elif [[ "$os_type" == "macos" ]]; then
        # macOS - prefer macOS binary
        if [ -f "./aws-assume-role-macos" ]; then
            binary_path="./aws-assume-role-macos"
        elif [ -f "./aws-assume-role-unix" ]; then
            binary_path="./aws-assume-role-unix"
        elif command -v aws-assume-role-macos >/dev/null 2>&1; then
            binary_path="aws-assume-role-macos"
        elif command -v aws-assume-role >/dev/null 2>&1; then
            binary_path="aws-assume-role"
        fi
    else
        # Linux/Unix - prefer unix binary
        if [ -f "./aws-assume-role-unix" ]; then
            binary_path="./aws-assume-role-unix"
        elif [ -f "./aws-assume-role-macos" ]; then
            binary_path="./aws-assume-role-macos"
        elif command -v aws-assume-role-unix >/dev/null 2>&1; then
            binary_path="aws-assume-role-unix"
        elif command -v aws-assume-role >/dev/null 2>&1; then
            binary_path="aws-assume-role"
        fi
    fi
    
    # If no platform-specific binary found, try generic detection
    if [ -z "$binary_path" ]; then
        if [ -f "./aws-assume-role-unix" ]; then
            binary_path="./aws-assume-role-unix"
        elif [ -f "./aws-assume-role-macos" ]; then
            binary_path="./aws-assume-role-macos"
        elif [ -f "./aws-assume-role.exe" ]; then
            binary_path="./aws-assume-role.exe"
        elif command -v aws-assume-role >/dev/null 2>&1; then
            binary_path="aws-assume-role"
        fi
    fi
    
    # Final check
    if [ -z "$binary_path" ]; then
        echo "❌ AWS Assume Role binary not found"
        echo "Platform detected: $os_type (OSTYPE=$OSTYPE)"
        echo "Looking for platform-appropriate binary:"
        case "$os_type" in
            "windows") echo "  - aws-assume-role.exe (preferred for Git Bash)" ;;
            "macos") echo "  - aws-assume-role-macos (preferred for macOS)" ;;
            *) echo "  - aws-assume-role-unix (preferred for Linux/Unix)" ;;
        esac
        echo "Current directory: $(pwd)"
        echo "Available files:"
        ls -la aws-assume-role* 2>/dev/null || echo "No aws-assume-role files found"
        return 1
    fi
    
    if [ "$1" = "assume" ] && [ -n "$2" ]; then
        echo "🔄 Assuming role: $2"
        
        # Ensure AWS region is set to prevent IMDS timeout
        if [ -z "$AWS_REGION" ] && [ -z "$AWS_DEFAULT_REGION" ]; then
            echo "📍 Setting default AWS region to prevent timeout..."
            export AWS_DEFAULT_REGION="us-east-1"
        fi
        
        # Capture the output and separate stderr
        local output
        output=$("$binary_path" assume "$2" "${@:3}" --format export 2>/dev/null)
        local exit_code=$?
        
        # Check if the command was successful
        
        if [ $exit_code -eq 0 ] && [ -n "$output" ]; then
            
            # Check for different output formats and apply credentials
            if echo "$output" | grep -q "^export"; then
                # Standard export format
                local filtered_output
                filtered_output=$(echo "$output" | grep -E '^export')
                eval "$filtered_output"
            elif echo "$output" | grep -q '^\$env:'; then
                # PowerShell format - convert to bash
                echo "$output" | grep '^\$env:' | while IFS= read -r line; do
                    # Convert $env:VAR = "value" to export VAR="value"
                    if [[ "$line" =~ ^\$env:([A-Z_]+)\ =\ \"(.*)\"$ ]]; then
                        local var_name="${BASH_REMATCH[1]}"
                        local var_value="${BASH_REMATCH[2]}"
                        echo "Setting $var_name"
                        export "$var_name"="$var_value"
                        # Also set in current shell (since we're in a subshell)
                        declare -g "$var_name"="$var_value"
                    fi
                done
                
                # Alternative approach - use eval with converted commands
                local converted_commands=""
                while IFS= read -r line; do
                    if [[ "$line" =~ ^\$env:([A-Z_]+)\ =\ \"(.*)\"$ ]]; then
                        local var_name="${BASH_REMATCH[1]}"
                        local var_value="${BASH_REMATCH[2]}"
                        converted_commands+="export $var_name=\"$var_value\"; "
                    fi
                done <<< "$(echo "$output" | grep '^\$env:')"
                
                if [ -n "$converted_commands" ]; then
                    eval "$converted_commands"
                fi
            elif echo "$output" | grep -q "^set"; then
                # Windows set format
                # Convert set commands to export
                echo "$output" | grep "^set" | sed 's/^set /export /' | sed 's/=/="/' | sed 's/$/"/' | while read line; do
                    eval "$line"
                done
            else
                # Try to parse any credential-looking lines
                echo "$output" | while IFS= read -r line; do
                    if [[ "$line" =~ AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|AWS_SESSION_TOKEN ]]; then
                        echo "Processing: $line"
                        if [[ "$line" =~ ^export ]]; then
                            eval "$line"
                        elif [[ "$line" =~ = ]]; then
                            # Try to convert to export format
                            local var_line="export $line"
                            eval "$var_line"
                        fi
                    fi
                done
            fi
            
            echo "✅ Successfully assumed role: $2"
            echo "🔍 Current AWS identity:"
            aws sts get-caller-identity --output table 2>/dev/null || echo "Run 'aws sts get-caller-identity' to verify"
        else
            echo "❌ Failed to assume role: $2"
            if [ $exit_code -ne 0 ]; then
                echo "Exit code: $exit_code"
            fi
            if [ -z "$output" ]; then
                echo "No output received"
            fi
            return 1
        fi
    else
        "$binary_path" "$@"
    fi
}

# Function to clear AWS credentials from current shell
clear_aws_creds() {
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    echo "✅ AWS credentials cleared from current shell"
}

# Function to show current AWS identity
aws_whoami() {
    if command -v aws >/dev/null 2>&1; then
        echo "Current AWS identity:"
        aws sts get-caller-identity 2>/dev/null || echo "No valid AWS credentials found"
    else
        echo "AWS CLI not found"
    fi
}

# Create alias for convenience
alias awsr='aws_assume_role'

echo "✅ AWS Assume Role loaded for Bash/Zsh"
echo "Usage: awsr assume <role-name>"
echo "       awsr list"
echo "       awsr configure --name <name> --role-arn <arn> --account-id <id>"
echo "       clear_aws_creds (clear credentials)"
echo "       aws_whoami (show current identity)"
