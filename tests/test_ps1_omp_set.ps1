# Test for omp_set function in PowerShell script
# This test verifies that omp_set shows current and default themes

# Parse command line arguments
param(
    [switch]$Verbose
)

# Load the script
. ./dot-oh-my-posh.ps1

# Test omp_set function
if ($Verbose) {
    Write-Host "Testing omp_set function..." -ForegroundColor Green
}

# Capture the output of omp_set (without arguments) by redirecting to a temporary file
$tempFile = [System.IO.Path]::GetTempFileName()
try {
    & { omp_set } *> $tempFile
    $output = Get-Content $tempFile -Raw
} finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}

# Verify that output is not empty and contains expected patterns
if ($output -and $output.Trim().Length -gt 0) {
    # Check for expected patterns in output
    $currentThemePattern = "Current theme:"
    $defaultThemePattern = "Default theme:"
    
    $hasCurrentTheme = $output -split "`n" | Where-Object { $_ -like "*$currentThemePattern*" }
    $hasDefaultTheme = $output -split "`n" | Where-Object { $_ -like "*$defaultThemePattern*" }
    
    # Both patterns must be present for the test to pass
    if ($hasCurrentTheme -and $hasDefaultTheme) {
        if ($Verbose) {
            Write-Host "✓ omp_set returned output" -ForegroundColor Green
            Write-Host "✓ Found 'Current theme:' in output" -ForegroundColor Green
            Write-Host "✓ Found 'Default theme:' in output" -ForegroundColor Green
            
            # Display the output
            Write-Host "omp_set output:" -ForegroundColor Cyan
            $output -split "`n" | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        }
        Write-Host "PASS: omp_set" -ForegroundColor Green
    } else {
        if ($Verbose) {
            Write-Host "✓ omp_set returned output" -ForegroundColor Green
            
            if ($hasCurrentTheme) {
                Write-Host "✓ Found 'Current theme:' in output" -ForegroundColor Green
            } else {
                Write-Host "✗ 'Current theme:' not found in output" -ForegroundColor Red
            }
            
            if ($hasDefaultTheme) {
                Write-Host "✓ Found 'Default theme:' in output" -ForegroundColor Green
            } else {
                Write-Host "✗ 'Default theme:' not found in output" -ForegroundColor Red
            }
            
            # Display the output
            Write-Host "omp_set output:" -ForegroundColor Cyan
            $output -split "`n" | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        }
        Write-Host "FAIL: omp_set" -ForegroundColor Red
        exit 1
    }
} else {
    if ($Verbose) {
        Write-Host "✗ omp_set returned no output" -ForegroundColor Red
    }
    Write-Host "FAIL: omp_set" -ForegroundColor Red
    exit 1
} 