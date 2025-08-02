# Test Utilities for Oh-My-Posh Tools
# Shared functions for testing the omp_tools scripts

# Global variables
$script:TestConfig = $null
$script:MockedFunctions = @{}

# Function to load and mock PowerShell script
function Import-OmpToolsPS1 {
    param(
        [string]$ScriptPath,
        [switch]$ShowVerbose
    )
    
    try {
        if (-not (Test-Path $ScriptPath)) {
            throw "Script not found: $ScriptPath"
        }
        
        # Create a new scope to avoid polluting global scope
        $scriptBlock = Get-Content $ScriptPath -Raw
        
        # Mock oh-my-posh commands before loading
        Mock-OhMyPosh
        
        # Execute the script in a new scope
        $null = [scriptblock]::Create($scriptBlock).Invoke()
        
        if ($ShowVerbose) {
            Write-Host "Successfully loaded script: $ScriptPath"
        }
        
        return $true
    }
    catch {
        if ($ShowVerbose) {
            Write-Error "Failed to load script $ScriptPath : $($_.Exception.Message)"
        }
        return $false
    }
}

# Function to test if a function exists
function Test-FunctionExists {
    param(
        [string]$FunctionName,
        [switch]$ShowVerbose
    )
    
    $exists = Get-Command $FunctionName -ErrorAction SilentlyContinue
    
    if ($ShowVerbose) {
        if ($exists) {
            Write-Host "Function exists: $FunctionName"
        } else {
            Write-Host "Function not found: $FunctionName"
        }
    }
    
    return @{
        Success = [bool]$exists
        FunctionName = $FunctionName
        Exists = [bool]$exists
    }
}

# Function to execute a function with validation
function Test-FunctionExecution {
    param(
        [string]$FunctionName,
        [object[]]$Arguments = @(),
        [scriptblock]$Validation = $null,
        [switch]$ShowVerbose
    )
    
    try {
        # Check if function exists
        $functionExists = Test-FunctionExists -FunctionName $FunctionName
        if (-not $functionExists.Success) {
            return @{
                Success = $false
                FunctionName = $FunctionName
                Error = "Function does not exist"
            }
        }
        
        # Execute function
        $result = & $FunctionName @Arguments
        
        # Run validation if provided
        $validationResult = $true
        if ($Validation) {
            $validationResult = & $Validation $result
        }
        
        if ($ShowVerbose) {
            Write-Host "Executed function: $FunctionName with arguments: $($Arguments -join ', ')"
            Write-Host "Validation result: $validationResult"
        }
        
        return @{
            Success = $validationResult
            FunctionName = $FunctionName
            Arguments = $Arguments
            Result = $result
            ValidationPassed = $validationResult
        }
    }
    catch {
        if ($ShowVerbose) {
            Write-Error "Error executing function $FunctionName : $($_.Exception.Message)"
        }
        
        return @{
            Success = $false
            FunctionName = $FunctionName
            Arguments = $Arguments
            Error = $_.Exception.Message
        }
    }
}

# Function to create isolated test environment
function New-TestEnvironment {
    param(
        [string]$EnvironmentName,
        [switch]$ShowVerbose
    )
    
    $testHome = Join-Path $TestConfig.TestRoot "test\$EnvironmentName"
    $testConfigDir = Join-Path $testHome ".config\omp_tools"
    
    # Create test home directory structure
    New-Item -ItemType Directory -Force -Path $testHome | Out-Null
    New-Item -ItemType Directory -Force -Path $testConfigDir | Out-Null
    
    # Create mock oh-my-posh themes directory
    $mockThemesDir = Join-Path $testHome "themes"
    New-Item -ItemType Directory -Force -Path $mockThemesDir | Out-Null
    
    # Create mock theme files
    $mockThemes = @("nu4a", "agnoster", "powerlevel10k")
    foreach ($theme in $mockThemes) {
        $themeFile = Join-Path $mockThemesDir "$theme.omp.json"
        @"
{
    "version": 1,
    "name": "$theme",
    "blocks": [
        {
            "type": "prompt",
            "alignment": "left",
            "segments": [
                {
                    "type": "text",
                    "style": "plain",
                    "text": "$theme"
                }
            ]
        }
    ]
}
"@ | Out-File -FilePath $themeFile -Encoding UTF8
    }
    
    # Create default theme file
    $defaultThemeFile = Join-Path $testConfigDir "default"
    $TestConfig.DefaultTheme | Out-File -FilePath $defaultThemeFile -Encoding UTF8
    
    if ($ShowVerbose) {
        Write-Host "Created test environment: $testHome"
        Write-Host "  Config directory: $testConfigDir"
        Write-Host "  Themes directory: $mockThemesDir"
    }
    
    return @{
        TestHome = $testHome
        ConfigDir = $testConfigDir
        ThemesDir = $mockThemesDir
        EnvironmentName = $EnvironmentName
    }
}

# Function to mock oh-my-posh commands
function Mock-OhMyPosh {
    param(
        [switch]$ShowVerbose
    )
    
    # Mock oh-my-posh init command
    if (-not (Get-Command "oh-my-posh" -ErrorAction SilentlyContinue)) {
        function Global:oh-my-posh {
            param(
                [string]$Command,
                [string]$Shell,
                [string]$Config
            )
            
            switch ($Command) {
                "init" {
                    # Return a mock initialization command
                    return "Write-Host 'Mock oh-my-posh init for $Shell with config: $Config'"
                }
                "print" {
                    # Return a mock prompt
                    return "Mock prompt for theme: $Config"
                }
                "export" {
                    # Return mock configuration
                    return "Mock oh-my-posh configuration"
                }
                default {
                    return "Mock oh-my-posh command: $Command"
                }
            }
        }
        
        if ($ShowVerbose) {
            Write-Host "Created mock oh-my-posh function"
        }
    }
    
    # Mock brew command
    if (-not (Get-Command "brew" -ErrorAction SilentlyContinue)) {
        function Global:brew {
            param(
                [string]$Command,
                [string]$Package
            )
            
            if ($Command -eq "--prefix" -and $Package -eq "oh-my-posh") {
                return "/usr/local/opt/oh-my-posh"
            }
            
            return "Mock brew command: $Command $Package"
        }
        
        if ($ShowVerbose) {
            Write-Host "Created mock brew function"
        }
    }
}

# Function to validate test results
function Assert-TestResult {
    param(
        [object]$TestResult,
        [string]$TestName,
        [switch]$ShowVerbose
    )
    
    if ($TestResult.Success) {
        if ($ShowVerbose) {
            Write-Host "PASS: $TestName" -ForegroundColor Green
        }
        return $true
    } else {
        if ($ShowVerbose) {
            Write-Host "FAIL: $TestName" -ForegroundColor Red
            Write-Host "  Error: $($TestResult.Error)" -ForegroundColor Red
        }
        return $false
    }
}

# Function to clean up test environment
function Remove-TestEnvironment {
    param(
        [string]$EnvironmentName,
        [switch]$ShowVerbose
    )
    
    $testHome = Join-Path $TestConfig.TestRoot "test\$EnvironmentName"
    
    if (Test-Path $testHome) {
        Remove-Item -Recurse -Force $testHome
        if ($ShowVerbose) {
            Write-Host "Cleaned up test environment: $testHome"
        }
    }
}

# Function to test script loading with no arguments
function Test-ScriptLoading {
    param(
        [string]$ScriptPath,
        [switch]$ShowVerbose
    )
    
    try {
        # Test loading script with no arguments
        $result = Import-OmpToolsPS1 -ScriptPath $ScriptPath -ShowVerbose:$ShowVerbose
        
        return @{
            Success = $result
            ScriptPath = $ScriptPath
            Error = if (-not $result) { "Failed to load script" } else { $null }
        }
    }
    catch {
        return @{
            Success = $false
            ScriptPath = $ScriptPath
            Error = $_.Exception.Message
        }
    }
}

# Function to test invalid arguments
function Test-InvalidArguments {
    param(
        [string]$FunctionName,
        [object[]]$InvalidArguments,
        [switch]$ShowVerbose
    )
    
    $results = @()
    
    foreach ($args in $InvalidArguments) {
        try {
            $result = & $FunctionName @args 2>&1
            
            # If we get here without exception, it might be a failure
            $results += @{
                Arguments = $args
                Success = $false
                Error = "Function should have failed with invalid arguments"
                Result = $result
            }
        }
        catch {
            # Expected behavior - function should fail with invalid arguments
            $results += @{
                Arguments = $args
                Success = $true
                Error = $null
                Exception = $_.Exception.Message
            }
        }
    }
    
    if ($ShowVerbose) {
        foreach ($result in $results) {
            if ($result.Success) {
                Write-Host "PASS: $FunctionName with invalid args: $($result.Arguments -join ', ')" -ForegroundColor Green
            } else {
                Write-Host "FAIL: $FunctionName with invalid args: $($result.Arguments -join ', ')" -ForegroundColor Red
            }
        }
    }
    
    return @{
        Success = ($results | Where-Object { $_.Success }).Count -eq $results.Count
        FunctionName = $FunctionName
        Results = $results
    }
}

# Functions are available for use in test scripts when sourced
# No Export-ModuleMember needed since we're sourcing the script, not importing as a module 