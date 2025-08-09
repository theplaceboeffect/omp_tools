# Test for omp_help function in PowerShell script
# This test verifies that omp_help displays a standard help message

# Parse command line arguments
param(
    [switch]$Verbose
)

# Load the script
. ./dot-oh-my-posh.ps1

# Test omp_help function
if ($Verbose) {
    Write-Host "Testing omp_help function..." -ForegroundColor Green
}

# Capture the output of omp_help by redirecting to a temporary file
$tempFile = [System.IO.Path]::GetTempFileName()
try {
    & { omp_help } *> $tempFile
    $output = Get-Content $tempFile -Raw
} finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}

# Verify that output is not empty and contains expected patterns
if ($output -and $output.Trim().Length -gt 0) {
    # Check for expected patterns in output
    $helpHeaderPattern = "=== OH-MY-POSH TOOLS HELP ==="
    $usagePattern = "Usage:"
    $optionsPattern = "Options:"
    $functionsPattern = "Functions:"
    
    $hasHelpHeader = $output -split "`n" | Where-Object { $_ -like "*$helpHeaderPattern*" }
    $hasUsage = $output -split "`n" | Where-Object { $_ -like "*$usagePattern*" }
    $hasOptions = $output -split "`n" | Where-Object { $_ -like "*$optionsPattern*" }
    $hasFunctions = $output -split "`n" | Where-Object { $_ -like "*$functionsPattern*" }
    
    # All patterns must be present for the test to pass
    if ($hasHelpHeader -and $hasUsage -and $hasOptions -and $hasFunctions) {
        if ($Verbose) {
            Write-Host "✓ omp_help returned output" -ForegroundColor Green
            Write-Host "✓ Found help header" -ForegroundColor Green
            Write-Host "✓ Found usage section" -ForegroundColor Green
            Write-Host "✓ Found options section" -ForegroundColor Green
            Write-Host "✓ Found functions section" -ForegroundColor Green
            
            # Display the output
            Write-Host "omp_help output:" -ForegroundColor Cyan
            $output -split "`n" | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        }
        Write-Host "PASS: omp_help (powershell)" -ForegroundColor Green
    } else {
        if ($Verbose) {
            Write-Host "✓ omp_help returned output" -ForegroundColor Green
            
            if ($hasHelpHeader) {
                Write-Host "✓ Found help header" -ForegroundColor Green
            } else {
                Write-Host "✗ Help header not found" -ForegroundColor Red
            }
            
            if ($hasUsage) {
                Write-Host "✓ Found usage section" -ForegroundColor Green
            } else {
                Write-Host "✗ Usage section not found" -ForegroundColor Red
            }
            
            if ($hasOptions) {
                Write-Host "✓ Found options section" -ForegroundColor Green
            } else {
                Write-Host "✗ Options section not found" -ForegroundColor Red
            }
            
            if ($hasFunctions) {
                Write-Host "✓ Found functions section" -ForegroundColor Green
            } else {
                Write-Host "✗ Functions section not found" -ForegroundColor Red
            }
            
            # Display the output
            Write-Host "omp_help output:" -ForegroundColor Cyan
            $output -split "`n" | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        }
        Write-Host "FAIL: omp_help (powershell)" -ForegroundColor Red
        exit 1
    }
} else {
    if ($Verbose) {
        Write-Host "✗ omp_help returned no output" -ForegroundColor Red
    }
    Write-Host "FAIL: omp_help (powershell)" -ForegroundColor Red
    exit 1
} 