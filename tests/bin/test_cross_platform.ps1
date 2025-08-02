# Test Cross-Platform Compatibility
# Tests that scripts work across different platforms and shells

param(
    [switch]$ShowVerbose
)

# Load test utilities
$testUtilsPath = Join-Path $PSScriptRoot "TestUtils.ps1"
if (Test-Path $testUtilsPath) {
    . $testUtilsPath
} else {
    Write-Error "Test utilities not found: $testUtilsPath"
    exit 1
}

# Load test configuration
$configPath = Join-Path (Split-Path $PSScriptRoot -Parent) "test_config.json"
if (Test-Path $configPath) {
    $script:TestConfig = Get-Content $configPath | ConvertFrom-Json
} else {
    Write-Error "Test configuration not found: $configPath"
    exit 1
}

$results = @()
$overallSuccess = $true

try {
    # Detect current platform
    $platform = if ($IsWindows) { "Windows" } elseif ($IsMacOS) { "macOS" } elseif ($IsLinux) { "Linux" } else { "Unknown" }
    
    $results += @{
        TestName = "Platform Detection"
        Platform = $platform
        Success = $platform -ne "Unknown"
        Error = if ($platform -eq "Unknown") { "Could not detect platform" } else { $null }
    }
    
    if ($platform -eq "Unknown") {
        $overallSuccess = $false
    }
    
    # Test PowerShell script loading on current platform
    $psScriptPath = Join-Path $TestConfig.ScriptsPath "omp_tools.ps1"
    $psLoadResult = Import-OmpToolsPS1 -ScriptPath $psScriptPath -ShowVerbose:$ShowVerbose
    
    $results += @{
        TestName = "PowerShell Script Loading on $platform"
        Platform = $platform
        Success = $psLoadResult
        Error = if (-not $psLoadResult) { "Failed to load PowerShell script" } else { $null }
    }
    
    if (-not $psLoadResult) {
        $overallSuccess = $false
    }
    
    # Test ZSH script existence (basic check)
    $zshScriptPath = Join-Path $TestConfig.ScriptsPath "omp_tools.zsh"
    $zshExists = Test-Path $zshScriptPath
    
    $results += @{
        TestName = "ZSH Script Existence"
        Platform = $platform
        Success = $zshExists
        Error = if (-not $zshExists) { "ZSH script not found" } else { $null }
    }
    
    if (-not $zshExists) {
        $overallSuccess = $false
    }
    
    # Test path handling (should work on all platforms)
    $testPaths = @(
        "~/test/path",
        "C:\test\path",
        "/test/path",
        "test\path"
    )
    
    foreach ($testPath in $testPaths) {
        try {
            $resolvedPath = [System.IO.Path]::GetFullPath($testPath)
            $pathSuccess = $true
            $pathError = $null
        }
        catch {
            $pathSuccess = $false
            $pathError = $_.Exception.Message
        }
        
        $results += @{
            TestName = "Path Handling: $testPath"
            Platform = $platform
            Success = $pathSuccess
            Error = $pathError
        }
        
        if (-not $pathSuccess) {
            $overallSuccess = $false
        }
    }
    
    # Test environment variable handling
    $envVars = @("HOME", "USERPROFILE", "PATH")
    foreach ($envVar in $envVars) {
        $envValue = [Environment]::GetEnvironmentVariable($envVar)
        $envExists = -not [string]::IsNullOrEmpty($envValue)
        
        $results += @{
            TestName = "Environment Variable: $envVar"
            Platform = $platform
            Success = $envExists
            Error = if (-not $envExists) { "Environment variable not found" } else { $null }
        }
        
        if (-not $envExists) {
            $overallSuccess = $false
        }
    }
    
}
catch {
    $overallSuccess = $false
    $results += @{
        TestName = "Cross-Platform Test"
        Success = $false
        Error = $_.Exception.Message
    }
}

# Return test results
return @{
    Success = $overallSuccess
    TestName = "Cross-Platform Compatibility Tests"
    Results = $results
    Summary = "Cross-platform compatibility tests completed"
} 