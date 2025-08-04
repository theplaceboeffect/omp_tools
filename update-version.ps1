#!/usr/bin/env pwsh

# Update version numbers in dot-oh-my-posh scripts based on current git branch

# Get current branch name
$CURRENT_BRANCH = git branch --show-current

# Check if branch name follows version format
if ($CURRENT_BRANCH -notmatch '^v[0-9]+\.[0-9]+\.[0-9]+$') {
    Write-Host "Warning: Current branch '$CURRENT_BRANCH' doesn't follow version format (vXX.XX.XX)" -ForegroundColor Yellow
    Write-Host "Version will be set to: v$CURRENT_BRANCH" -ForegroundColor Yellow
    $VERSION = "v$CURRENT_BRANCH"
} else {
    $VERSION = $CURRENT_BRANCH
}

Write-Host "Updating version to: $VERSION" -ForegroundColor Green

# Update PowerShell script
if (Test-Path "dot-oh-my-posh.ps1") {
    $content = Get-Content "dot-oh-my-posh.ps1" -Raw
    $content = $content -replace '## Version: v[0-9]+\.[0-9]+\.[0-9]+', "## Version: $VERSION"
    $content = $content -replace 'Write-Host "Version: v[0-9]+\.[0-9]+\.[0-9]+"', "Write-Host `"Version: $VERSION`""
    $content = $content -replace 'Write-Host "Version: v[0-9]+\.[0-9]+\.[0-9]+" -ForegroundColor Green', "Write-Host `"Version: $VERSION`" -ForegroundColor Green"
    Set-Content "dot-oh-my-posh.ps1" $content
    Write-Host "✓ Updated dot-oh-my-posh.ps1" -ForegroundColor Green
} else {
    Write-Host "✗ dot-oh-my-posh.ps1 not found" -ForegroundColor Red
}

# Update zsh script
if (Test-Path "dot-oh-my-posh.zsh") {
    $content = Get-Content "dot-oh-my-posh.zsh" -Raw
    $content = $content -replace '## Version: v[0-9]+\.[0-9]+\.[0-9]+', "## Version: $VERSION"
    $content = $content -replace 'echo "Version: v[0-9]+\.[0-9]+\.[0-9]+"', "echo `"Version: $VERSION`""
    Set-Content "dot-oh-my-posh.zsh" $content
    Write-Host "✓ Updated dot-oh-my-posh.zsh" -ForegroundColor Green
} else {
    Write-Host "✗ dot-oh-my-posh.zsh not found" -ForegroundColor Red
}

Write-Host "Version update complete!" -ForegroundColor Green 