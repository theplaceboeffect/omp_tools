# Test Runner Script for Oh-My-Posh Tools
# Runs all tests for branch: v01.06.00

param(
    [string]$TestFilter = "*",
    [switch]$ShowVerbose
)

# Load environment setup
$setupScript = Join-Path $PSScriptRoot "setup_test_env.ps1"
if (Test-Path $setupScript) {
    . $setupScript -ShowVerbose:$ShowVerbose
} else {
    Write-Warning "Environment setup script not found: $setupScript"
}

Write-Host "Running tests for branch: v01.06.00"
Write-Host "Test filter: $TestFilter"

# Find test scripts
$testScripts = Get-ChildItem $PSScriptRoot -Name "test_*.ps1" | Where-Object { $_ -like "$TestFilter" }

if ($testScripts.Count -eq 0) {
    Write-Warning "No test scripts found matching filter: $TestFilter"
    exit 1
}

$results = @()
$passed = 0
$failed = 0

foreach ($script in $testScripts) {
    Write-Host "Running test: $script" -ForegroundColor Cyan
    
    try {
        $testResult = & (Join-Path $PSScriptRoot $script) -ShowVerbose:$ShowVerbose
        $results += $testResult
        
        if ($testResult.Success) {
            $passed++
            Write-Host "PASSED: $script" -ForegroundColor Green
        } else {
            $failed++
            Write-Host "FAILED: $script" -ForegroundColor Red
            Write-Host "  Error: $($testResult.Error)" -ForegroundColor Red
        }
    }
    catch {
        $failed++
        Write-Host "ERROR: $script" -ForegroundColor Red
        Write-Host "  Exception: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Summary
Write-Host "
Test Summary:" -ForegroundColor Yellow
Write-Host "  Passed: $passed" -ForegroundColor Green
Write-Host "  Failed: $failed" -ForegroundColor Red
Write-Host "  Total: $($passed + $failed)"

# Save results
$resultsPath = Join-Path (Split-Path $PSScriptRoot -Parent) "test_results.json"
$results | ConvertTo-Json -Depth 3 | Out-File -FilePath $resultsPath -Encoding UTF8

if ($failed -gt 0) {
    exit 1
}
