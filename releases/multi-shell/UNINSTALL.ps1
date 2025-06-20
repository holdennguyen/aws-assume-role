# AWS Assume Role CLI Tool - PowerShell Uninstall Script
# Removes all traces of the AWS Assume Role CLI tool from Windows

param(
    [switch]$Force = $false,
    [switch]$Help = $false
)

if ($Help) {
    Write-Host @"
AWS Assume Role CLI Tool - PowerShell Uninstall Script

Usage:
    .\UNINSTALL.ps1 [-Force] [-Help]

Parameters:
    -Force    Skip confirmation prompts
    -Help     Show this help message

Examples:
    .\UNINSTALL.ps1         # Interactive uninstall
    .\UNINSTALL.ps1 -Force  # Uninstall without prompts
"@
    exit 0
}

Write-Host "🗑️  AWS Assume Role CLI Tool - PowerShell Uninstall Script" -ForegroundColor Red
Write-Host "==========================================================" -ForegroundColor Red

# Clear current session functions
Write-Host ""
Write-Host "🧹 Clearing current session..." -ForegroundColor Yellow
try {
    Remove-Item Function:\awsr -ErrorAction SilentlyContinue
    Remove-Item Function:\Clear-AwsCredentials -ErrorAction SilentlyContinue  
    Remove-Item Function:\Get-AwsWhoAmI -ErrorAction SilentlyContinue
    Write-Host "✅ Cleared current session functions" -ForegroundColor Green
} catch {
    Write-Host "ℹ️  No current session functions to clear" -ForegroundColor Cyan
}

# Find installations
Write-Host ""
Write-Host "🔍 Finding AWS Assume Role CLI installations..." -ForegroundColor Yellow
Write-Host "=============================================="

$foundInstallations = @()

# Common installation locations
$searchPaths = @(
    "C:\Program Files\AWSAssumeRole",
    "$env:LOCALAPPDATA\AWSAssumeRole", 
    "$env:USERPROFILE\AWSAssumeRole",
    (Get-Location).Path
)

# Add PATH directories
$pathDirs = $env:PATH -split ';' | Where-Object { $_ -and (Test-Path $_) }
$searchPaths += $pathDirs

foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        # Look for binaries
        $binaries = @("aws-assume-role.exe", "aws-assume-role-windows.exe")
        $wrappers = @("aws-assume-role-powershell.ps1", "aws-assume-role-cmd.bat")
        
        $foundBinary = $binaries | Where-Object { Test-Path (Join-Path $path $_) } | Select-Object -First 1
        $foundWrapper = $wrappers | Where-Object { Test-Path (Join-Path $path $_) } | Select-Object -First 1
        
        if ($foundBinary -or $foundWrapper) {
            if ($foundInstallations -notcontains $path) {
                $foundInstallations += $path
                Write-Host "📍 Found installation in: $path" -ForegroundColor Cyan
            }
        }
    }
}

# Remove installations
if ($foundInstallations.Count -gt 0) {
    Write-Host ""
    Write-Host "🗑️  Removing installations..." -ForegroundColor Yellow
    Write-Host "============================="
    
    foreach ($installPath in $foundInstallations) {
        Write-Host "📁 Removing from: $installPath" -ForegroundColor Cyan
        
        $filesToRemove = @(
            "aws-assume-role.exe",
            "aws-assume-role-windows.exe",
            "aws-assume-role-powershell.ps1",
            "aws-assume-role-cmd.bat",
            "aws-assume-role-bash.sh",
            "aws-assume-role-fish.fish"
        )
        
        $removedCount = 0
        foreach ($file in $filesToRemove) {
            $filePath = Join-Path $installPath $file
            if (Test-Path $filePath) {
                try {
                    Remove-Item $filePath -Force
                    Write-Host "  ✅ Removed: $file" -ForegroundColor Green
                    $removedCount++
                } catch {
                    Write-Host "  ❌ Failed to remove: $file - $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
        
        if ($removedCount -gt 0) {
            Write-Host "✅ Removed $removedCount file(s) from $installPath" -ForegroundColor Green
        } else {
            Write-Host "ℹ️  No files to remove from $installPath" -ForegroundColor Cyan
        }
    }
} else {
    Write-Host "ℹ️  No installations found in common locations" -ForegroundColor Cyan
}

# Remove from PowerShell profile
Write-Host ""
Write-Host "🔧 Removing from PowerShell profile..." -ForegroundColor Yellow
Write-Host "====================================="

$profilePath = $PROFILE
Write-Host "📍 Checking PowerShell profile: $profilePath" -ForegroundColor Cyan

if (Test-Path $profilePath) {
    $profileContent = Get-Content $profilePath -ErrorAction SilentlyContinue
    $awsLines = $profileContent | Where-Object { $_ -match "aws-assume-role" }
    
    if ($awsLines) {
        Write-Host "📝 Found AWS Assume Role CLI entries in profile:" -ForegroundColor Yellow
        $awsLines | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
        
        $removeFromProfile = $Force
        if (-not $Force) {
            $response = Read-Host "Remove these entries from PowerShell profile? (y/n)"
            $removeFromProfile = $response -match "^[Yy]"
        }
        
        if ($removeFromProfile) {
            # Create backup
            $backupPath = "$profilePath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item $profilePath $backupPath
            Write-Host "📄 Created backup: $backupPath" -ForegroundColor Green
            
            # Remove AWS Assume Role CLI lines
            $newContent = $profileContent | Where-Object { $_ -notmatch "aws-assume-role" }
            $newContent | Set-Content $profilePath
            Write-Host "✅ Removed AWS Assume Role CLI from PowerShell profile" -ForegroundColor Green
        } else {
            Write-Host "⏭️  Skipped PowerShell profile cleanup" -ForegroundColor Yellow
        }
    } else {
        Write-Host "ℹ️  No AWS Assume Role CLI entries found in PowerShell profile" -ForegroundColor Cyan
    }
} else {
    Write-Host "ℹ️  PowerShell profile does not exist" -ForegroundColor Cyan
}

# Remove configuration directory
Write-Host ""
Write-Host "🗂️  Removing configuration..." -ForegroundColor Yellow
Write-Host "============================="

$configDir = "$env:USERPROFILE\.aws-assume-role"
if (Test-Path $configDir) {
    Write-Host "📁 Found configuration directory: $configDir" -ForegroundColor Cyan
    Write-Host "📋 Contents:" -ForegroundColor Cyan
    try {
        Get-ChildItem $configDir | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }
    } catch {
        Write-Host "  (empty or inaccessible)" -ForegroundColor Gray
    }
    
    $removeConfig = $Force
    if (-not $Force) {
        $response = Read-Host "Remove configuration directory and all role configurations? (y/n)"
        $removeConfig = $response -match "^[Yy]"
    }
    
    if ($removeConfig) {
        try {
            Remove-Item $configDir -Recurse -Force
            Write-Host "✅ Removed configuration directory: $configDir" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed to remove configuration directory: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "⏭️  Kept configuration directory: $configDir" -ForegroundColor Yellow
        Write-Host "   (You can manually remove it later if needed)" -ForegroundColor Gray
    }
} else {
    Write-Host "ℹ️  No configuration directory found" -ForegroundColor Cyan
}

# Clear environment variables
Write-Host ""
Write-Host "🌍 Clearing AWS environment variables from current session..." -ForegroundColor Yellow
Write-Host "==========================================================="

$awsVars = @(
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
    "AWS_SESSION_TOKEN", 
    "AWS_SECURITY_TOKEN",
    "AWS_DEFAULT_REGION",
    "AWS_REGION"
)

$clearedCount = 0
foreach ($var in $awsVars) {
    $value = [Environment]::GetEnvironmentVariable($var)
    if ($value) {
        [Environment]::SetEnvironmentVariable($var, $null)
        Write-Host "✅ Cleared: $var" -ForegroundColor Green
        $clearedCount++
    }
}

if ($clearedCount -gt 0) {
    Write-Host "✅ Cleared $clearedCount AWS environment variable(s)" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No AWS environment variables to clear" -ForegroundColor Cyan
}

# Remove from PATH
Write-Host ""
Write-Host "🛣️  PATH Cleanup" -ForegroundColor Yellow
Write-Host "==============="

$currentUserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$currentMachinePath = [Environment]::GetEnvironmentVariable("PATH", "Machine")

$awsPathEntries = @()
if ($currentUserPath) {
    $awsPathEntries += $currentUserPath -split ';' | Where-Object { $_ -match "aws.*assume.*role|AWSAssumeRole" }
}
if ($currentMachinePath) {
    $awsPathEntries += $currentMachinePath -split ';' | Where-Object { $_ -match "aws.*assume.*role|AWSAssumeRole" }
}

if ($awsPathEntries) {
    Write-Host "📍 Found AWS Assume Role CLI entries in PATH:" -ForegroundColor Cyan
    $awsPathEntries | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    
    $cleanPath = $Force
    if (-not $Force) {
        $response = Read-Host "Remove these entries from PATH? (y/n)"
        $cleanPath = $response -match "^[Yy]"
    }
    
    if ($cleanPath) {
        try {
            # Clean user PATH
            if ($currentUserPath) {
                $newUserPath = ($currentUserPath -split ';' | Where-Object { $_ -notmatch "aws.*assume.*role|AWSAssumeRole" }) -join ';'
                [Environment]::SetEnvironmentVariable("PATH", $newUserPath, "User")
            }
            
            # Clean machine PATH (requires admin)
            if ($currentMachinePath) {
                try {
                    $newMachinePath = ($currentMachinePath -split ';' | Where-Object { $_ -notmatch "aws.*assume.*role|AWSAssumeRole" }) -join ';'
                    [Environment]::SetEnvironmentVariable("PATH", $newMachinePath, "Machine")
                    Write-Host "✅ Cleaned PATH entries" -ForegroundColor Green
                } catch {
                    Write-Host "⚠️  Could not clean system PATH (requires admin privileges)" -ForegroundColor Yellow
                }
            }
        } catch {
            Write-Host "❌ Failed to clean PATH: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "ℹ️  No AWS Assume Role CLI entries found in PATH" -ForegroundColor Cyan
}

# Final cleanup instructions
Write-Host ""
Write-Host "🎯 Manual Cleanup (if needed)" -ForegroundColor Yellow
Write-Host "============================="
Write-Host "If you installed in custom locations, you may need to manually remove:" -ForegroundColor White
Write-Host ""
Write-Host "📁 Binary files:" -ForegroundColor Cyan
Write-Host "  - aws-assume-role.exe, aws-assume-role-windows.exe" -ForegroundColor Gray
Write-Host ""
Write-Host "📄 Wrapper scripts:" -ForegroundColor Cyan
Write-Host "  - aws-assume-role-powershell.ps1" -ForegroundColor Gray
Write-Host "  - aws-assume-role-cmd.bat" -ForegroundColor Gray
Write-Host ""
Write-Host "📝 PowerShell profile entries containing 'aws-assume-role'" -ForegroundColor Cyan
Write-Host ""
Write-Host "🗂️  Configuration directory: ~/.aws-assume-role/" -ForegroundColor Cyan

Write-Host ""
Write-Host "✅ Uninstall Complete!" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""
Write-Host "🔄 To complete the uninstallation:" -ForegroundColor Yellow
Write-Host "1. Restart PowerShell" -ForegroundColor White
Write-Host "2. Or reload your profile: . `$PROFILE" -ForegroundColor White
Write-Host ""
Write-Host "🔍 To verify removal:" -ForegroundColor Yellow
Write-Host "   Get-Command awsr  # Should return error" -ForegroundColor White
Write-Host ""
Write-Host "Thank you for using AWS Assume Role CLI! 👋" -ForegroundColor Green 