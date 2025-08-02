# Test Function Existence
# Tests that all expected functions exist in the omp_tools scripts

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
    
    # Define expected functions
    $expectedFunctions = @(
        "omp_ls",
        "omp_set", 
        "omp_show",
        "_omp_completion"
    )
    
    # Test each expected function
    foreach ($functionName in $expectedFunctions) {
        $functionResult = Test-FunctionExists -FunctionName $functionName -ShowVerbose:$ShowVerbose
        
        $results += @{
            TestName = "Function Exists: $functionName"
            FunctionName = $functionName
            Success = $functionResult.Success
            Error = if (-not $functionResult.Success) { "Function not found" } else { $null }
        }
        
        if (-not $functionResult.Success) {
            $overallSuccess = $false
        }
    }
    
    # Test that functions are callable (basic test)
    if ($overallSuccess) {
        foreach ($functionName in $expectedFunctions) {
            try {
                # Test basic function call (may fail due to missing dependencies, but should not crash)
                $executionResult = Test-FunctionExecution -FunctionName $functionName -ShowVerbose:$ShowVerbose
                
                $results += @{
                    TestName = "Function Callable: $functionName"
                    FunctionName = $functionName
                    Success = $executionResult.Success
                    Error = $executionResult.Error
                }
                
                if (-not $executionResult.Success) {
                    $overallSuccess = $false
                }
            }
            catch {
                $results += @{
                    TestName = "Function Callable: $functionName"
                    FunctionName = $functionName
                    Success = $false
                    Error = $_.Exception.Message
                }
                $overallSuccess = $false
            }
        }
    }
    
}
catch {
    $overallSuccess = $false
    $results += @{
        TestName = "Function Existence Test"
        Success = $false
        Error = $_.Exception.Message
    }
}

# Return test results
return @{
    Success = $overallSuccess
    TestName = "Function Existence Tests"
    Results = $results
    Summary = "Function existence tests completed"
} 