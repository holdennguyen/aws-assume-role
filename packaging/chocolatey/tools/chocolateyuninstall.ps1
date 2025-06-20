$ErrorActionPreference = 'Stop'

$packageName = 'aws-assume-role'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Remove the wrapper module from PowerShell profile if it exists
$wrapperPath = Join-Path $toolsDir 'aws-assume-role-wrapper.psm1'
$profilePath = $PROFILE

if (Test-Path $profilePath) {
    $profileContent = Get-Content $profilePath -Raw
    $updatedContent = $profileContent -replace "(?m)^.*Import-Module.*aws-assume-role-wrapper\.psm1.*$\r?\n?", ""
    $updatedContent = $updatedContent -replace "(?m)^.*AWS Assume Role CLI Integration.*$\r?\n?", ""
    
    if ($profileContent -ne $updatedContent) {
        $updatedContent | Out-File -FilePath $profilePath -Encoding UTF8
        Write-Host "Removed AWS Assume Role CLI from PowerShell profile" -ForegroundColor Green
    }
}

# Clear any existing AWS credentials from current session
Remove-Item Env:\AWS_ACCESS_KEY_ID -ErrorAction SilentlyContinue
Remove-Item Env:\AWS_SECRET_ACCESS_KEY -ErrorAction SilentlyContinue
Remove-Item Env:\AWS_SESSION_TOKEN -ErrorAction SilentlyContinue

Write-Host "AWS Assume Role CLI has been uninstalled!" -ForegroundColor Green
Write-Host "Note: Your role configurations in ~/.aws-assume-role/ are preserved." -ForegroundColor Yellow 