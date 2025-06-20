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
