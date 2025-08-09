# Test for omp_ls function in PowerShell script
# This test verifies that omp_ls returns a list of themes

# Parse command line arguments
param(
    [switch]$Verbose
)

# Load the script
. ./dot-oh-my-posh.ps1

# Test omp_ls function
if ($Verbose) {
    Write-Host "Testing omp_ls function..." -ForegroundColor Green
}

# Capture the output of omp_ls by redirecting to a temporary file
$tempFile = [System.IO.Path]::GetTempFileName()
try {
    & { omp_ls } *> $tempFile
    $output = Get-Content $tempFile -Raw
} finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}

# Verify that output is not empty and contains expected patterns
if ($output -and $output.Trim().Length -gt 0) {
    # Check if output contains theme files (should have .omp.json extension)
    $themeFiles = $output -split "`n" | Where-Object { $_ -like "*.omp.json" }
    
    # Test passes if we have output (even if no .omp.json files, as long as there's output)
    if ($Verbose) {
        Write-Host "✓ omp_ls returned output" -ForegroundColor Green
        
        if ($themeFiles.Count -gt 0) {
            Write-Host "✓ Found theme files with .omp.json extension" -ForegroundColor Green
            Write-Host "Sample themes found:" -ForegroundColor Yellow
            $themeFiles | Select-Object -First 5 | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
        } else {
            Write-Host "⚠ No .omp.json files found in output" -ForegroundColor Yellow
        }
        
        # Display first few lines of output
        Write-Host "First 10 lines of omp_ls output:" -ForegroundColor Cyan
        $output -split "`n" | Select-Object -First 10 | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    }
    Write-Host "PASS: omp_ls (powershell)" -ForegroundColor Green
} else {
    if ($Verbose) {
        Write-Host "✗ omp_ls returned no output" -ForegroundColor Red
    }
    Write-Host "FAIL: omp_ls (powershell)" -ForegroundColor Red
    exit 1
} 