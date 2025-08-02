# Environment Setup Script for Oh-My-Posh Tools Testing
# This script sets up the test environment with mocked dependencies

param(
    [switch]$ShowVerbose
)

# Load test utilities
$testUtilsPath = Join-Path (Split-Path $PSScriptRoot -Parent) "bin\TestUtils.ps1"
if (Test-Path $testUtilsPath) {
    . $testUtilsPath
    if ($ShowVerbose) {
        Write-Host "Loaded test utilities from: $testUtilsPath"
    }
} else {
    Write-Warning "Test utilities not found at: $testUtilsPath"
}

# Load test configuration
$configPath = Join-Path (Split-Path $PSScriptRoot -Parent) "test_config.json"
if (Test-Path $configPath) {
    $script:TestConfig = Get-Content $configPath | ConvertFrom-Json
    if ($ShowVerbose) {
        Write-Host "Loaded test configuration from: $configPath"
    }
} else {
    Write-Warning "Test configuration not found at: $configPath"
}

# Set up mock environment
if ($TestConfig.MockOhMyPosh) {
    Mock-OhMyPosh
    if ($ShowVerbose) {
        Write-Host "Mocked oh-my-posh commands"
    }
}

Write-Host "Test environment setup complete"
