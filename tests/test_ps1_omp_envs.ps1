# Test for omp_env function in PowerShell script
# This test verifies that omp_env displays environment information

# Parse command line arguments
param(
    [switch]$Verbose
)

# Load the script
. ./dot-oh-my-posh.ps1

# Test omp_env function
if ($Verbose) {
    Write-Host "Testing omp_env function..." -ForegroundColor Green
}

# Capture the output of omp_env by redirecting to a temporary file
$tempFile = [System.IO.Path]::GetTempFileName()
try {
    & { omp_env } *> $tempFile
    $output = Get-Content $tempFile -Raw
} finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}

# Verify that output is not empty and contains expected patterns
if ($output -and $output.Trim().Length -gt 0) {
    # Check for expected patterns in output
    $envHeaderPattern = "=== OH-MY-POSH ENVIRONMENT ==="
    $osPattern = "Operating System:"
    $shellPattern = "Shell:"
    $installDirPattern = "oh-my-posh Install Dir:"
    
    $hasEnvHeader = $output -split "`n" | Where-Object { $_ -like "*$envHeaderPattern*" }
    $hasOS = $output -split "`n" | Where-Object { $_ -like "*$osPattern*" }
    $hasShell = $output -split "`n" | Where-Object { $_ -like "*$shellPattern*" }
    $hasInstallDir = $output -split "`n" | Where-Object { $_ -like "*$installDirPattern*" }
    
    # All patterns must be present for the test to pass
    if ($hasEnvHeader -and $hasOS -and $hasShell -and $hasInstallDir) {
        if ($Verbose) {
            Write-Host "✓ omp_env returned output" -ForegroundColor Green
            Write-Host "✓ Found environment header" -ForegroundColor Green
            Write-Host "✓ Found Operating System info" -ForegroundColor Green
            Write-Host "✓ Found Shell info" -ForegroundColor Green
            Write-Host "✓ Found Install Directory info" -ForegroundColor Green
            
            # Display the output
            Write-Host "omp_env output:" -ForegroundColor Cyan
            $output -split "`n" | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        }
        Write-Host "PASS: omp_env" -ForegroundColor Green
    } else {
        if ($Verbose) {
            Write-Host "✓ omp_env returned output" -ForegroundColor Green
            
            if ($hasEnvHeader) {
                Write-Host "✓ Found environment header" -ForegroundColor Green
            } else {
                Write-Host "✗ Environment header not found" -ForegroundColor Red
            }
            
            if ($hasOS) {
                Write-Host "✓ Found Operating System info" -ForegroundColor Green
            } else {
                Write-Host "✗ Operating System info not found" -ForegroundColor Red
            }
            
            if ($hasShell) {
                Write-Host "✓ Found Shell info" -ForegroundColor Green
            } else {
                Write-Host "✗ Shell info not found" -ForegroundColor Red
            }
            
            if ($hasInstallDir) {
                Write-Host "✓ Found Install Directory info" -ForegroundColor Green
            } else {
                Write-Host "✗ Install Directory info not found" -ForegroundColor Red
            }
            
            # Display the output
            Write-Host "omp_env output:" -ForegroundColor Cyan
            $output -split "`n" | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        }
        Write-Host "FAIL: omp_env" -ForegroundColor Red
        exit 1
    }
} else {
    if ($Verbose) {
        Write-Host "✗ omp_env returned no output" -ForegroundColor Red
    }
    Write-Host "FAIL: omp_env" -ForegroundColor Red
    exit 1
} 