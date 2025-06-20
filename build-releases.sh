#!/bin/bash

# AWS Assume Role - Multi-Shell Release Builder
# This script builds optimized versions for different shell environments

set -e

echo "🚀 Building AWS Assume Role for multiple shell environments..."

# Clean previous builds
cargo clean

# Create releases directory
mkdir -p releases/multi-shell

# Build for Unix-like systems (bash, zsh, fish)
echo "📦 Building for Unix shells (bash, zsh, fish)..."
cargo build --release --target-dir target/unix
cp target/unix/release/aws-assume-role releases/multi-shell/aws-assume-role-unix

# Build for macOS specifically
echo "📦 Building for macOS..."
cargo build --release
cp target/release/aws-assume-role releases/multi-shell/aws-assume-role-macos

# Cross-compile for Windows (if cross-compilation is set up)
if command -v x86_64-pc-windows-gnu-gcc >/dev/null 2>&1; then
    echo "📦 Building for Windows..."
    cargo build --release --target x86_64-pc-windows-gnu --target-dir target/windows
    cp target/windows/x86_64-pc-windows-gnu/release/aws-assume-role.exe releases/multi-shell/aws-assume-role-windows.exe
else
    echo "⚠️  Windows cross-compilation not available. Skipping Windows build."
fi

# Create shell-specific wrapper scripts
echo "📝 Creating shell-specific wrapper scripts..."

# Bash/Zsh wrapper
cat > releases/multi-shell/aws-assume-role-bash.sh << 'EOF'
#!/bin/bash
# AWS Assume Role - Bash/Zsh Wrapper
# Usage: source aws-assume-role-bash.sh assume <role-name>

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
echo "Usage: awsr assume <role-name>"
echo "       awsr list"
echo "       awsr configure --name <name> --role-arn <arn> --account-id <id>"
EOF

# Fish wrapper
cat > releases/multi-shell/aws-assume-role-fish.fish << 'EOF'
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
EOF

# PowerShell wrapper
cat > releases/multi-shell/aws-assume-role-powershell.ps1 << 'EOF'
# AWS Assume Role - PowerShell Wrapper
# Usage: . .\aws-assume-role-powershell.ps1

function Invoke-AwsAssumeRole {
    param(
        [Parameter(Position=0)]
        [string]$Command,
        
        [Parameter(Position=1)]
        [string]$RoleName,
        
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$RemainingArgs
    )
    
    $binaryPath = $null
    
    # Try to find the binary
    if (Test-Path ".\aws-assume-role-windows.exe") {
        $binaryPath = ".\aws-assume-role-windows.exe"
    } elseif (Test-Path ".\aws-assume-role.exe") {
        $binaryPath = ".\aws-assume-role.exe"
    } elseif (Get-Command aws-assume-role-windows.exe -ErrorAction SilentlyContinue) {
        $binaryPath = "aws-assume-role-windows.exe"
    } elseif (Get-Command aws-assume-role.exe -ErrorAction SilentlyContinue) {
        $binaryPath = "aws-assume-role.exe"
    } else {
        Write-Host "❌ AWS Assume Role binary not found" -ForegroundColor Red
        return
    }
    
    if ($Command -eq "assume" -and $RoleName) {
        Write-Host "🔄 Assuming role: $RoleName" -ForegroundColor Cyan
        $output = & $binaryPath assume $RoleName @RemainingArgs --format export 2>$null
        if ($LASTEXITCODE -eq 0) {
            # Execute the PowerShell commands
            Invoke-Expression $output
            Write-Host "🎯 Role assumed successfully in current session!" -ForegroundColor Green
            Write-Host "Current AWS identity:" -ForegroundColor Cyan
            try {
                aws sts get-caller-identity --query 'Arn' --output text
            } catch {
                Write-Host "Failed to verify identity" -ForegroundColor Yellow
            }
        }
    } else {
        & $binaryPath @($Command, $RoleName) @RemainingArgs
    }
}

# Create alias for convenience
Set-Alias -Name awsr -Value Invoke-AwsAssumeRole

Write-Host "✅ AWS Assume Role loaded for PowerShell" -ForegroundColor Green
Write-Host "Usage: awsr assume <role-name>"
Write-Host "       awsr list"
Write-Host "       awsr configure -name <name> -role-arn <arn> -account-id <id>"
EOF

# Command Prompt wrapper
cat > releases/multi-shell/aws-assume-role-cmd.bat << 'EOF'
@echo off
REM AWS Assume Role - Command Prompt Wrapper
REM Usage: aws-assume-role-cmd.bat assume <role-name>

setlocal enabledelayedexpansion

set BINARY_PATH=
if exist "aws-assume-role-windows.exe" (
    set BINARY_PATH=aws-assume-role-windows.exe
) else if exist "aws-assume-role.exe" (
    set BINARY_PATH=aws-assume-role.exe
) else (
    where aws-assume-role-windows.exe >nul 2>&1
    if !errorlevel! equ 0 (
        set BINARY_PATH=aws-assume-role-windows.exe
    ) else (
        where aws-assume-role.exe >nul 2>&1
        if !errorlevel! equ 0 (
            set BINARY_PATH=aws-assume-role.exe
        ) else (
            echo ❌ AWS Assume Role binary not found
            exit /b 1
        )
    )
)

if "%1"=="assume" if not "%2"=="" (
    echo 🔄 Assuming role: %2
    for /f "delims=" %%i in ('!BINARY_PATH! assume %2 %3 %4 %5 %6 %7 %8 %9 --format export 2^>nul') do (
        %%i
    )
    if !errorlevel! equ 0 (
        echo 🎯 Role assumed successfully in current session!
        echo Current AWS identity:
        aws sts get-caller-identity --query "Arn" --output text 2>nul || echo Failed to verify identity
    )
) else (
    !BINARY_PATH! %*
)
EOF

# Make scripts executable
chmod +x releases/multi-shell/aws-assume-role-bash.sh
chmod +x releases/multi-shell/aws-assume-role-fish.fish

echo "✅ Multi-shell releases built successfully!"
echo ""
echo "📁 Files created in releases/multi-shell/:"
ls -la releases/multi-shell/
echo ""
echo "🎯 Usage instructions:"
echo ""
echo "Bash/Zsh:"
echo "  source aws-assume-role-bash.sh"
echo "  awsr assume <role-name>"
echo ""
echo "Fish:"
echo "  source aws-assume-role-fish.fish"
echo "  awsr assume <role-name>"
echo ""
echo "PowerShell:"
echo "  . .\\aws-assume-role-powershell.ps1"
echo "  awsr assume <role-name>"
echo ""
echo "Command Prompt:"
echo "  aws-assume-role-cmd.bat assume <role-name>" 