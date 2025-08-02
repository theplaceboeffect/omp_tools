# Test Initialization Script for Oh-My-Posh Tools
# Creates the test directory structure for a specific branch

param(
    [Parameter(Mandatory=$true)]
    [string]$BranchName,
    
    [Parameter(Mandatory=$false)]
    [switch]$ShowVerbose
)

# Function to get current git branch if not specified
function Get-CurrentGitBranch {
    try {
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($branch) {
            return $branch
        }
    }
    catch {
        Write-Warning "Could not determine git branch"
    }
    return $null
}

# Function to create directory structure
function New-TestDirectoryStructure {
    param(
        [string]$BranchName,
        [string]$TestRoot
    )
    
    $branchDir = Join-Path $TestRoot $BranchName
    $binDir = Join-Path $branchDir "bin"
    $testDir = Join-Path $branchDir "test"
    
    # Create directories
    New-Item -ItemType Directory -Force -Path $branchDir | Out-Null
    New-Item -ItemType Directory -Force -Path $binDir | Out-Null
    New-Item -ItemType Directory -Force -Path $testDir | Out-Null
    
    if ($ShowVerbose) {
        Write-Host "Created directory: $branchDir"
        Write-Host "Created directory: $binDir"
        Write-Host "Created directory: $testDir"
    }
    
    return @{
        BranchDir = $branchDir
        BinDir = $binDir
        TestDir = $testDir
    }
}

# Function to create test configuration
function New-TestConfiguration {
    param(
        [string]$BranchName,
        [string]$BranchDir
    )
    
    $configPath = Join-Path $BranchDir "test_config.json"
    $config = @{
        BranchName = $BranchName
        TestRoot = $BranchDir
        ScriptsPath = (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "bin")
        TestHomePrefix = "HOME-test"
        DefaultTheme = "nu4a"
        MockOhMyPosh = $true
    }
    
    $config | ConvertTo-Json -Depth 3 | Out-File -FilePath $configPath -Encoding UTF8
    
    if ($ShowVerbose) {
        Write-Host "Created test configuration: $configPath"
    }
    
    return $configPath
}

# Function to create environment setup script
function New-EnvironmentSetupScript {
    param(
        [string]$BinDir
    )
    
    $setupScript = @'
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
'@
    
    $setupPath = Join-Path $BinDir "setup_test_env.ps1"
    $setupScript | Out-File -FilePath $setupPath -Encoding UTF8
    
    if ($ShowVerbose) {
        Write-Host "Created environment setup script: $setupPath"
    }
    
    return $setupPath
}

# Function to create test runner script
function New-TestRunnerScript {
    param(
        [string]$BinDir,
        [string]$BranchName
    )
    
    $runnerScript = @"
# Test Runner Script for Oh-My-Posh Tools
# Runs all tests for branch: $BranchName

param(
    [string]`$TestFilter = "*",
    [switch]`$ShowVerbose
)

# Load environment setup
`$setupScript = Join-Path `$PSScriptRoot "setup_test_env.ps1"
if (Test-Path `$setupScript) {
    . `$setupScript -ShowVerbose:`$ShowVerbose
} else {
    Write-Warning "Environment setup script not found: `$setupScript"
}

Write-Host "Running tests for branch: $BranchName"
Write-Host "Test filter: `$TestFilter"

# Find test scripts
`$testScripts = Get-ChildItem `$PSScriptRoot -Name "test_*.ps1" | Where-Object { `$_ -like "`$TestFilter" }

if (`$testScripts.Count -eq 0) {
    Write-Warning "No test scripts found matching filter: `$TestFilter"
    exit 1
}

`$results = @()
`$passed = 0
`$failed = 0

foreach (`$script in `$testScripts) {
    Write-Host "Running test: `$script" -ForegroundColor Cyan
    
    try {
        `$testResult = & (Join-Path `$PSScriptRoot `$script) -ShowVerbose:`$ShowVerbose
        `$results += `$testResult
        
        if (`$testResult.Success) {
            `$passed++
            Write-Host "PASSED: `$script" -ForegroundColor Green
        } else {
            `$failed++
            Write-Host "FAILED: `$script" -ForegroundColor Red
            Write-Host "  Error: `$(`$testResult.Error)" -ForegroundColor Red
        }
    }
    catch {
        `$failed++
        Write-Host "ERROR: `$script" -ForegroundColor Red
        Write-Host "  Exception: `$(`$_.Exception.Message)" -ForegroundColor Red
    }
}

# Summary
Write-Host "`nTest Summary:" -ForegroundColor Yellow
Write-Host "  Passed: `$passed" -ForegroundColor Green
Write-Host "  Failed: `$failed" -ForegroundColor Red
Write-Host "  Total: `$(`$passed + `$failed)"

# Save results
`$resultsPath = Join-Path (Split-Path `$PSScriptRoot -Parent) "test_results.json"
`$results | ConvertTo-Json -Depth 3 | Out-File -FilePath `$resultsPath -Encoding UTF8

if (`$failed -gt 0) {
    exit 1
}
"@
    
    $runnerPath = Join-Path $BinDir "run_tests.ps1"
    $runnerScript | Out-File -FilePath $runnerPath -Encoding UTF8
    
    if ($ShowVerbose) {
        Write-Host "Created test runner script: $runnerPath"
    }
    
    return $runnerPath
}

# Main execution
try {
    # Get branch name if not provided
    if (-not $BranchName) {
        $BranchName = Get-CurrentGitBranch
        if (-not $BranchName) {
            throw "Branch name not specified and could not determine from git"
        }
    }
    
    Write-Host "Creating test structure for branch: $BranchName"
    
    # Get test root directory
    $testRoot = Join-Path (Split-Path $PSScriptRoot -Parent) "tests"
    
    # Create directory structure
    $dirs = New-TestDirectoryStructure -BranchName $BranchName -TestRoot $testRoot
    
    # Create test configuration
    $configPath = New-TestConfiguration -BranchName $BranchName -BranchDir $dirs.BranchDir
    
    # Create environment setup script
    $setupPath = New-EnvironmentSetupScript -BinDir $dirs.BinDir
    
    # Create test runner script
    $runnerPath = New-TestRunnerScript -BinDir $dirs.BinDir -BranchName $BranchName
    
    Write-Host "Test framework initialization complete!"
    Write-Host "Branch directory: $($dirs.BranchDir)"
    Write-Host "Next steps:"
    Write-Host "1. Navigate to: $($dirs.BinDir)"
    Write-Host "2. Create test scripts with prefix 'test_'"
    Write-Host "3. Run tests with: .\run_tests.ps1"
    
}
catch {
    Write-Error "Failed to initialize test framework: $($_.Exception.Message)"
    exit 1
} 