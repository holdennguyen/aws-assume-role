# AWS Assume Role CLI Tool - PowerShell Installation Script
# For Windows PowerShell and PowerShell Core

param(
    [string]$InstallPath = "",
    [switch]$AddToProfile = $false,
    [switch]$Help = $false
)

if ($Help) {
    Write-Host @"
AWS Assume Role CLI Tool - PowerShell Installation Script

Usage:
    .\INSTALL.ps1 [-InstallPath <path>] [-AddToProfile] [-Help]

Parameters:
    -InstallPath    Custom installation directory (optional)
    -AddToProfile   Automatically add to PowerShell profile
    -Help           Show this help message

Examples:
    .\INSTALL.ps1                                    # Interactive installation
    .\INSTALL.ps1 -InstallPath "C:\Tools"           # Install to specific directory
    .\INSTALL.ps1 -AddToProfile                     # Install and add to profile
"@
    exit 0
}

Write-Host "🚀 AWS Assume Role CLI Tool - PowerShell Installation" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

# Check if running as Administrator for system-wide installation
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# Detect PowerShell version
$psVersion = $PSVersionTable.PSVersion.Major
Write-Host "📍 PowerShell Version: $psVersion" -ForegroundColor Green

# Check for required files
$binaryNames = @("aws-assume-role-windows.exe", "aws-assume-role.exe")
$foundBinary = $null

foreach ($binary in $binaryNames) {
    if (Test-Path $binary) {
        $foundBinary = $binary
        break
    }
}

if (-not $foundBinary) {
    Write-Host "❌ No AWS Assume Role binary found!" -ForegroundColor Red
    Write-Host "Expected files: aws-assume-role-windows.exe or aws-assume-role.exe" -ForegroundColor Yellow
    Write-Host "Please ensure you're running this script from the directory containing the AWS Assume Role files." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path "aws-assume-role-powershell.ps1")) {
    Write-Host "❌ PowerShell wrapper not found: aws-assume-role-powershell.ps1" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found binary: $foundBinary" -ForegroundColor Green
Write-Host "✅ Found PowerShell wrapper: aws-assume-role-powershell.ps1" -ForegroundColor Green

# Determine installation directory
if (-not $InstallPath) {
    Write-Host ""
    Write-Host "📦 Installation Options:" -ForegroundColor Yellow
    Write-Host "1. Current directory (recommended for testing)"
    Write-Host "2. C:\Program Files\AWSAssumeRole (system-wide, requires admin)"
    Write-Host "3. $env:LOCALAPPDATA\AWSAssumeRole (user-specific)"
    Write-Host "4. Custom directory"
    Write-Host ""
    
    $choice = Read-Host "Choose installation option (1-4)"
    
    switch ($choice) {
        "1" {
            $InstallPath = Get-Location
            Write-Host "📁 Installing to current directory: $InstallPath" -ForegroundColor Green
        }
        "2" {
            $InstallPath = "C:\Program Files\AWSAssumeRole"
            if (-not $isAdmin) {
                Write-Host "❌ System-wide installation requires Administrator privileges!" -ForegroundColor Red
                Write-Host "Please run PowerShell as Administrator or choose a different option." -ForegroundColor Yellow
                exit 1
            }
            Write-Host "📁 Installing to system directory: $InstallPath" -ForegroundColor Green
        }
        "3" {
            $InstallPath = "$env:LOCALAPPDATA\AWSAssumeRole"
            Write-Host "📁 Installing to user directory: $InstallPath" -ForegroundColor Green
        }
        "4" {
            $InstallPath = Read-Host "Enter custom directory path"
            Write-Host "📁 Installing to custom directory: $InstallPath" -ForegroundColor Green
        }
        default {
            Write-Host "❌ Invalid option. Exiting." -ForegroundColor Red
            exit 1
        }
    }
}

# Create installation directory
if (-not (Test-Path $InstallPath)) {
    Write-Host "📁 Creating directory: $InstallPath" -ForegroundColor Yellow
    New-Item -Path $InstallPath -ItemType Directory -Force | Out-Null
}

# Copy files
Write-Host ""
Write-Host "📋 Installing files..." -ForegroundColor Yellow

try {
    # Copy binary
    $targetBinary = Join-Path $InstallPath "aws-assume-role.exe"
    Copy-Item $foundBinary $targetBinary -Force
    Write-Host "✅ Copied binary to: $targetBinary" -ForegroundColor Green
    
    # Copy PowerShell wrapper
    $targetWrapper = Join-Path $InstallPath "aws-assume-role-powershell.ps1"
    Copy-Item "aws-assume-role-powershell.ps1" $targetWrapper -Force
    Write-Host "✅ Copied wrapper to: $targetWrapper" -ForegroundColor Green
    
    # Update wrapper script if not in current directory
    if ((Get-Location).Path -ne $InstallPath) {
        Write-Host "🔧 Updating wrapper script paths..." -ForegroundColor Yellow
        
        $wrapperContent = Get-Content $targetWrapper
        $updatedContent = $wrapperContent -replace '"\.\aws-assume-role-windows\.exe"', "`"$targetBinary`"" -replace '"\.\aws-assume-role\.exe"', "`"$targetBinary`""
        $updatedContent | Set-Content $targetWrapper
        
        Write-Host "✅ Updated wrapper script paths" -ForegroundColor Green
    }
    
} catch {
    Write-Host "❌ Failed to copy files: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Add to PATH if system or user installation
if ($InstallPath -ne (Get-Location).Path) {
    Write-Host ""
    $addToPath = Read-Host "Would you like to add $InstallPath to your PATH? (y/n)"
    
    if ($addToPath -match "^[Yy]") {
        try {
            if ($InstallPath -like "C:\Program Files*") {
                # System PATH (requires admin)
                $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
                if ($currentPath -notlike "*$InstallPath*") {
                    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$InstallPath", "Machine")
                    Write-Host "✅ Added to system PATH" -ForegroundColor Green
                }
            } else {
                # User PATH
                $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
                if ($currentPath -notlike "*$InstallPath*") {
                    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$InstallPath", "User")
                    Write-Host "✅ Added to user PATH" -ForegroundColor Green
                }
            }
            Write-Host "🔄 Please restart PowerShell to use the updated PATH" -ForegroundColor Yellow
        } catch {
            Write-Host "⚠️  Could not update PATH: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

# PowerShell Profile Configuration
Write-Host ""
Write-Host "🔧 PowerShell Profile Configuration" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Yellow

$profilePath = $PROFILE
Write-Host "📍 Current PowerShell profile: $profilePath" -ForegroundColor Cyan

$sourceCommand = ". `"$targetWrapper`""

Write-Host ""
Write-Host "To use AWS Assume Role CLI, you need to source the wrapper script."
Write-Host ""
Write-Host "Option 1 - Load for current session only:" -ForegroundColor Green
Write-Host "  . `"$targetWrapper`""
Write-Host ""
Write-Host "Option 2 - Add to your PowerShell profile for permanent use:" -ForegroundColor Green
Write-Host "  Add-Content -Path `$PROFILE -Value '$sourceCommand'"

if (-not $AddToProfile) {
    Write-Host ""
    $addToProfileChoice = Read-Host "Would you like to add to your PowerShell profile now? (y/n)"
    $AddToProfile = $addToProfileChoice -match "^[Yy]"
}

if ($AddToProfile) {
    try {
        # Create profile if it doesn't exist
        if (-not (Test-Path $profilePath)) {
            $profileDir = Split-Path $profilePath -Parent
            if (-not (Test-Path $profileDir)) {
                New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
            }
            New-Item -Path $profilePath -ItemType File -Force | Out-Null
            Write-Host "📄 Created PowerShell profile: $profilePath" -ForegroundColor Green
        }
        
        # Check if already added
        $profileContent = Get-Content $profilePath -ErrorAction SilentlyContinue
        if ($profileContent -notcontains $sourceCommand) {
            Add-Content -Path $profilePath -Value $sourceCommand
            Write-Host "✅ Added to PowerShell profile: $profilePath" -ForegroundColor Green
            Write-Host "🔄 Please restart PowerShell or run '. `$PROFILE' to load the changes." -ForegroundColor Yellow
        } else {
            Write-Host "ℹ️  Already present in PowerShell profile" -ForegroundColor Cyan
        }
        
    } catch {
        Write-Host "❌ Failed to update PowerShell profile: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test installation
Write-Host ""
Write-Host "🧪 Testing Installation" -ForegroundColor Yellow
Write-Host "=======================" -ForegroundColor Yellow

try {
    Write-Host "📋 Loading wrapper script..." -ForegroundColor Cyan
    . $targetWrapper
    
    Write-Host "🔍 Testing command availability..." -ForegroundColor Cyan
    if (Get-Command awsr -ErrorAction SilentlyContinue) {
        Write-Host "✅ awsr command is available!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Testing help command..." -ForegroundColor Cyan
        try {
            awsr --help 2>$null
        } catch {
            Write-Host "Available commands: awsr list, awsr configure, awsr assume, awsr remove" -ForegroundColor Cyan
        }
    } else {
        Write-Host "❌ awsr command not found. Please check the installation." -ForegroundColor Red
    }
    
} catch {
    Write-Host "⚠️  Could not test installation automatically: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "Please manually test by running: . `"$targetWrapper`"" -ForegroundColor Yellow
}

# Final instructions
Write-Host ""
Write-Host "🎉 Installation Complete!" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""
Write-Host "📖 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Ensure you have AWS credentials configured:" -ForegroundColor White
Write-Host "   aws sts get-caller-identity" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Configure your first role:" -ForegroundColor White
Write-Host "   awsr configure -name `"my-role`" -role-arn `"arn:aws:iam::123456789012:role/MyRole`" -account-id `"123456789012`"" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Assume the role:" -ForegroundColor White
Write-Host "   awsr assume my-role" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 For detailed usage instructions, see README.md" -ForegroundColor Yellow
Write-Host ""
Write-Host "🚀 Happy role switching!" -ForegroundColor Green 