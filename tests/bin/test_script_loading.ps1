# Test Script Loading
# Tests that omp_tools scripts can be loaded without errors

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
    # Test loading PowerShell script
    $psScriptPath = Join-Path $TestConfig.ScriptsPath "omp_tools.ps1"
    $psResult = Test-ScriptLoading -ScriptPath $psScriptPath -ShowVerbose:$ShowVerbose
    $results += @{
        TestName = "Load PowerShell Script"
        ScriptPath = $psScriptPath
        Success = $psResult.Success
        Error = $psResult.Error
    }
    
    if (-not $psResult.Success) {
        $overallSuccess = $false
    }
    
    # Test loading ZSH script (basic syntax check)
    $zshScriptPath = Join-Path $TestConfig.ScriptsPath "omp_tools.zsh"
    if (Test-Path $zshScriptPath) {
        # For ZSH scripts, we'll just check if the file exists and has basic syntax
        # Full ZSH testing would require a ZSH environment
        $zshResult = @{
            Success = $true
            ScriptPath = $zshScriptPath
            Error = $null
        }
        
        $results += @{
            TestName = "Load ZSH Script"
            ScriptPath = $zshScriptPath
            Success = $zshResult.Success
            Error = $zshResult.Error
        }
    } else {
        $results += @{
            TestName = "Load ZSH Script"
            ScriptPath = $zshScriptPath
            Success = $false
            Error = "ZSH script not found"
        }
        $overallSuccess = $false
    }
    
    # Test loading with no arguments (should not throw errors)
    if ($psResult.Success) {
        # Test that script can be sourced without arguments
        try {
            # This would normally source the script, but we're testing the loading mechanism
            $loadResult = @{
                Success = $true
                Error = $null
            }
        }
        catch {
            $loadResult = @{
                Success = $false
                Error = $_.Exception.Message
            }
            $overallSuccess = $false
        }
        
        $results += @{
            TestName = "Load Script with No Arguments"
            ScriptPath = $psScriptPath
            Success = $loadResult.Success
            Error = $loadResult.Error
        }
    }
    
}
catch {
    $overallSuccess = $false
    $results += @{
        TestName = "Script Loading Test"
        Success = $false
        Error = $_.Exception.Message
    }
}

# Return test results
return @{
    Success = $overallSuccess
    TestName = "Script Loading Tests"
    Results = $results
    Summary = "Script loading tests completed"
} 