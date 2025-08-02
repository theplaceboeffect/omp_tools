# Test Invalid Arguments
# Tests that functions handle invalid arguments gracefully

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
    # Load the PowerShell script
    $psScriptPath = Join-Path $TestConfig.ScriptsPath "omp_tools.ps1"
    $loadResult = Import-OmpToolsPS1 -ScriptPath $psScriptPath -ShowVerbose:$ShowVerbose
    
    if (-not $loadResult) {
        throw "Failed to load PowerShell script: $psScriptPath"
    }
    
    # Test omp_set with invalid arguments
    $ompSetInvalidArgs = @(
        @("nonexistent-theme"),
        @(""),
        @($null),
        @("invalid-theme-name-with-spaces"),
        @("theme", "extra-arg")
    )
    
    $ompSetResult = Test-InvalidArguments -FunctionName "omp_set" -InvalidArguments $ompSetInvalidArgs -ShowVerbose:$ShowVerbose
    
    $results += @{
        TestName = "omp_set Invalid Arguments"
        FunctionName = "omp_set"
        Success = $ompSetResult.Success
        Results = $ompSetResult.Results
    }
    
    if (-not $ompSetResult.Success) {
        $overallSuccess = $false
    }
    
    # Test omp_show with invalid arguments
    $ompShowInvalidArgs = @(
        @("nonexistent-theme"),
        @("invalid-theme"),
        @("theme", "extra-arg")
    )
    
    $ompShowResult = Test-InvalidArguments -FunctionName "omp_show" -InvalidArguments $ompShowInvalidArgs -ShowVerbose:$ShowVerbose
    
    $results += @{
        TestName = "omp_show Invalid Arguments"
        FunctionName = "omp_show"
        Success = $ompShowResult.Success
        Results = $ompShowResult.Results
    }
    
    if (-not $ompShowResult.Success) {
        $overallSuccess = $false
    }
    
    # Test omp_ls with invalid arguments (should handle gracefully)
    $ompLsInvalidArgs = @(
        @("unexpected-arg"),
        @("arg1", "arg2")
    )
    
    $ompLsResult = Test-InvalidArguments -FunctionName "omp_ls" -InvalidArguments $ompLsInvalidArgs -ShowVerbose:$ShowVerbose
    
    $results += @{
        TestName = "omp_ls Invalid Arguments"
        FunctionName = "omp_ls"
        Success = $ompLsResult.Success
        Results = $ompLsResult.Results
    }
    
    if (-not $ompLsResult.Success) {
        $overallSuccess = $false
    }
    
}
catch {
    $overallSuccess = $false
    $results += @{
        TestName = "Invalid Arguments Test"
        Success = $false
        Error = $_.Exception.Message
    }
}

# Return test results
return @{
    Success = $overallSuccess
    TestName = "Invalid Arguments Tests"
    Results = $results
    Summary = "Invalid arguments tests completed"
} 