$ErrorActionPreference = 'Stop'

$packageName = 'aws-assume-role'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = '1.0.2'
$url64 = "https://github.com/holdennguyen/aws-assume-role/releases/download/v$version/aws-assume-role.exe"

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $toolsDir
  fileType      = 'exe'
  url64bit      = $url64
  softwareName  = 'AWS Assume Role CLI*'
  checksum64    = 'YOUR_CHECKSUM_HERE'
  checksumType64= 'sha256'
  validExitCodes= @(0)
}

# Download and install the binary
Get-ChocolateyWebFile @packageArgs

# Create the main executable
$exePath = Join-Path $toolsDir 'aws-assume-role.exe'
Move-Item (Join-Path $toolsDir 'aws-assume-role.exe') $exePath -Force

# Create wrapper script for PowerShell integration
$wrapperScript = @"
# AWS Assume Role CLI PowerShell Wrapper
function awsr {
    param(
        [Parameter(Position=0)]
        [string]`$Command,
        
        [Parameter(Position=1, ValueFromRemainingArguments=`$true)]
        [string[]]`$Arguments
    )
    
    if (`$Command -eq "assume" -and `$Arguments.Count -gt 0) {
        `$roleName = `$Arguments[0]
        `$output = & "$exePath" assume `$roleName --format export
        
        if (`$LASTEXITCODE -eq 0) {
            # Parse and set environment variables
            `$output | ForEach-Object {
                if (`$_ -match '^export\s+([^=]+)="([^"]*)"') {
                    Set-Item -Path "env:`$(`$matches[1])" -Value `$matches[2]
                }
            }
            
            Write-Host "✅ Successfully assumed role: `$roleName" -ForegroundColor Green
            Write-Host "🔍 Current AWS identity:" -ForegroundColor Cyan
            try {
                aws sts get-caller-identity --output table
            } catch {
                Write-Host "Run 'aws sts get-caller-identity' to verify" -ForegroundColor Yellow
            }
        } else {
            Write-Host "❌ Failed to assume role: `$roleName" -ForegroundColor Red
            exit 1
        }
    } else {
        # Pass through all other commands
        & "$exePath" @(`$Command) @Arguments
    }
}

# Helper functions
function Clear-AwsCredentials {
    Remove-Item Env:\AWS_ACCESS_KEY_ID -ErrorAction SilentlyContinue
    Remove-Item Env:\AWS_SECRET_ACCESS_KEY -ErrorAction SilentlyContinue
    Remove-Item Env:\AWS_SESSION_TOKEN -ErrorAction SilentlyContinue
    Write-Host "🧹 AWS credentials cleared from current session" -ForegroundColor Green
}

function Get-AwsWhoAmI {
    try {
        aws sts get-caller-identity --output table
    } catch {
        Write-Host "❌ No AWS credentials found or AWS CLI not available" -ForegroundColor Red
    }
}

# Export functions for global use
Export-ModuleMember -Function awsr, Clear-AwsCredentials, Get-AwsWhoAmI
"@

# Save wrapper script
$wrapperPath = Join-Path $toolsDir 'aws-assume-role-wrapper.psm1'
$wrapperScript | Out-File -FilePath $wrapperPath -Encoding UTF8

# Add to PowerShell profile
$profileContent = @"

# AWS Assume Role CLI Integration
Import-Module "$wrapperPath" -Force

"@

Write-Host "AWS Assume Role CLI has been installed!" -ForegroundColor Green
Write-Host ""
Write-Host "To enable shell integration, add this to your PowerShell profile:" -ForegroundColor Cyan
Write-Host "Import-Module `"$wrapperPath`" -Force" -ForegroundColor Yellow
Write-Host ""
Write-Host "Or run this command to add it automatically:" -ForegroundColor Cyan
Write-Host "Add-Content `$PROFILE `"Import-Module \`"$wrapperPath\`" -Force`"" -ForegroundColor Yellow
Write-Host ""
Write-Host "Usage:" -ForegroundColor Green
Write-Host "  awsr configure --name dev --role-arn arn:aws:iam::123:role/DevRole --account-id 123"
Write-Host "  awsr assume dev"
Write-Host "  awsr list" 