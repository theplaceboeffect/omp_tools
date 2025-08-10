
## Version: v01.11.02
## -------- OH-MY-POSH --------

# Parse command-line arguments
param(
    [switch]$h,
    [switch]$e,
    [switch]$v
)

# Verify PowerShell 7 (pwsh) is being used
if ($PSVersionTable.PSEdition -ne "Core" -or $PSVersionTable.PSVersion.Major -lt 7) {
    Write-Error "This script requires PowerShell 7 (pwsh). Current version: $($PSVersionTable.PSVersion)"
    Write-Error "Please run this script with PowerShell 7 or later."
    exit 1
}

# Show version if -v flag is provided
if ($v) {
    Write-Host "Version: v01.11.02" -ForegroundColor Green
    return
}

# Show help if -h flag is provided (single source of truth via omp_help)
if ($h) {
    omp_help
    return
}

# Environment Detection for Windows Compatibility
function Get-OMPEnvironment {
    $envInfo = @{
        OperatingSystem = $null
        Shell = $null
        OMPInstallDir = $null
        OMPThemesDir = $null
        OMPExecutable = $null
        PackageManager = $null
    }
    
    # Determine Operating System (PowerShell 5 compatible)
    if ($env:OS -eq "Windows_NT" -or [System.Environment]::OSVersion.Platform -eq "Win32NT") {
        $envInfo.OperatingSystem = "Windows"
    } elseif ([System.Environment]::OSVersion.Platform -eq "Unix") {
        # Distinguish between macOS and Linux
        if (Test-Path "/System/Library/CoreServices/SystemVersion.plist") {
            $envInfo.OperatingSystem = "macOS"
        } else {
            $envInfo.OperatingSystem = "Linux"
        }
    } else {
        $envInfo.OperatingSystem = "Unknown"
    }
    
    # Determine Shell
    $envInfo.Shell = $PSVersionTable.PSEdition
    
    # Determine oh-my-posh installation directory and executable
    $ompPath = $null
    $ompExe = $null
    
    # Try to find oh-my-posh executable first
    $ompExe = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    if ($ompExe) {
        $ompPath = Split-Path $ompExe.Source
        $envInfo.OMPExecutable = $ompExe.Source
    }
    
    # If executable not found, check common installation paths
    if (-not $ompPath) {
        $possiblePaths = @(
            "$env:USERPROFILE\.oh-my-posh",
            "$env:LOCALAPPDATA\oh-my-posh",
            "/usr/local/share/oh-my-posh",
            "/opt/oh-my-posh"
        )
        
        # Add Homebrew path only if brew is available
        if (Get-Command brew -ErrorAction SilentlyContinue) {
            $brewPath = "$(brew --prefix oh-my-posh 2>$null)"
            $possiblePaths += $brewPath
        }
        
        foreach ($path in $possiblePaths) {
            if (Test-Path $path) {
                $ompPath = $path
                break
            }
        }
    }
    
    $envInfo.OMPInstallDir = $ompPath
    
    # Determine themes directory
    $themesDir = $null
    
    # Try common themes locations first (Windows-specific paths)
    $possibleThemesPaths = @(
        "$env:LOCALAPPDATA\oh-my-posh\themes",
        "$env:USERPROFILE\.oh-my-posh\themes",
        "$env:LOCALAPPDATA\Programs\oh-my-posh\themes",
        "$env:PROGRAMFILES\oh-my-posh\themes",
        "$env:PROGRAMFILES(X86)\oh-my-posh\themes",
        "/usr/local/share/oh-my-posh/themes",
        "/opt/oh-my-posh/themes"
    )
    
    # Add Homebrew path only if brew is available
    if (Get-Command brew -ErrorAction SilentlyContinue) {
        $brewPath = "$(brew --prefix oh-my-posh)/themes"
        $possibleThemesPaths += $brewPath
    }
    
    foreach ($path in $possibleThemesPaths) {
        if (Test-Path $path) {
            $themesDir = $path
            break
        }
    }
    
    # If themes directory not found in common locations, try relative to installation directory
    if (-not $themesDir -and $ompPath) {
        # Check for themes subdirectory
        $themesSubDir = Join-Path $ompPath "themes"
        if (Test-Path $themesSubDir) {
            $themesDir = $themesSubDir
        } else {
            # Try parent directory themes
            $parentDir = Split-Path $ompPath -Parent
            $parentThemesDir = Join-Path $parentDir "themes"
            if (Test-Path $parentThemesDir) {
                $themesDir = $parentThemesDir
            }
        }
    }
    
    $envInfo.OMPThemesDir = $themesDir
    
    # Determine Package Manager
    $packageManager = "Unknown"
    
    if (Get-Command brew -ErrorAction SilentlyContinue) {
        $packageManager = "Homebrew"
    } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
        $packageManager = "winget"
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        $packageManager = "Chocolatey"
    } elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
        $packageManager = "Scoop"
    } elseif (Get-Command apt -ErrorAction SilentlyContinue) {
        $packageManager = "apt"
    } elseif (Get-Command yum -ErrorAction SilentlyContinue) {
        $packageManager = "yum"
    }
    
    $envInfo.PackageManager = $packageManager
    
    return $envInfo
}

# Get environment information
$OMP_ENVIRONMENT = Get-OMPEnvironment

# Show environment information only if -e flag is provided
if ($e) {
    Write-Host "=== OH-MY-POSH ENVIRONMENT ===" -ForegroundColor Cyan
    Write-Host "Operating System: $($OMP_ENVIRONMENT.OperatingSystem)" -ForegroundColor Yellow
    Write-Host "Shell: $($OMP_ENVIRONMENT.Shell)" -ForegroundColor Yellow
    Write-Host "oh-my-posh Install Dir: $($OMP_ENVIRONMENT.OMPInstallDir)" -ForegroundColor Yellow
    Write-Host "oh-my-posh Themes Dir: $($OMP_ENVIRONMENT.OMPThemesDir)" -ForegroundColor Yellow
    Write-Host "oh-my-posh Executable: $($OMP_ENVIRONMENT.OMPExecutable)" -ForegroundColor Yellow
    Write-Host "Package Manager: $($OMP_ENVIRONMENT.PackageManager)" -ForegroundColor Yellow
    Write-Host "===============================" -ForegroundColor Cyan
    return
}

$DEFAULT_OMP_THEME = Get-Content ~/.config/omp_tools/default -ErrorAction SilentlyContinue | ForEach-Object { $_ } | Where-Object { $_ } | Select-Object -First 1
if (-not $DEFAULT_OMP_THEME) {
    $DEFAULT_OMP_THEME = "nu4a"
}

# Use the detected themes directory from environment detection

$OMP_THEMES = $OMP_ENVIRONMENT.OMPThemesDir

# If themes directory not detected, try fallback paths
if (-not $OMP_THEMES) {
    # Fallback paths for different systems
    $possibleThemePaths = @(
        "$env:LOCALAPPDATA\oh-my-posh\themes",
        "$env:USERPROFILE\.oh-my-posh\themes",
        "/usr/local/share/oh-my-posh/themes",
        "/opt/oh-my-posh/themes"
    )
    
    foreach ($path in $possibleThemePaths) {
        if (Test-Path $path) {
            $OMP_THEMES = $path
            break
        }
    }
    
    # If still not found, try to get it from oh-my-posh executable location
    if (-not $OMP_THEMES) {
        $ompExe = Get-Command oh-my-posh -ErrorAction SilentlyContinue
        if ($ompExe) {
            $ompDir = Split-Path $ompExe.Source
            $OMP_THEMES = Join-Path $ompDir "themes"
        }
    }
}

function omp_ls {
    if (-not (Test-Path $OMP_THEMES)) {
        Write-Host "Error: Themes directory not found: $OMP_THEMES" -ForegroundColor Red
        return 1
    }
    Get-ChildItem $OMP_THEMES -Name "*.omp.json" | ForEach-Object { $_.Replace(".omp.json", "") }
}

function omp_set {
    param(
        [Parameter(Position=0)]
        [string]$Theme
    )
    
    if (-not $Theme) {
        # Display current and default themes when no parameter is provided
        $currentThemeName = ""
        if ($env:POSH_THEME) {
            $currentThemeName = [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetFileNameWithoutExtension($env:POSH_THEME))
        }
        $defaultTheme = Get-Content ~/.config/omp_tools/default -ErrorAction SilentlyContinue | ForEach-Object { $_ } | Where-Object { $_ } | Select-Object -First 1
        if (-not $defaultTheme) {
            $defaultTheme = "nu4a"
        }
        
        Write-Host "Current theme: $currentThemeName"
        Write-Host "Default theme: $defaultTheme"
        return
    }
    
    # Check if oh-my-posh command is available
    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Write-Host "Error: oh-my-posh command not found" -ForegroundColor Red
        Write-Host "Please install oh-my-posh first" -ForegroundColor Yellow
        return 1
    }
    
    # Check if theme file exists
    $themeFile = Join-Path $OMP_THEMES "$Theme.omp.json"
    if (-not (Test-Path $themeFile)) {
        Write-Host "Error: Theme '$Theme' not found at $themeFile" -ForegroundColor Red
        Write-Host "Use 'omp_ls' to see available themes" -ForegroundColor Yellow
        return 1
    }
    
    Write-Host "Setting theme to $Theme"
    try {
        $themeCmd = oh-my-posh init pwsh --config "`"$themeFile`""
        Invoke-Expression $themeCmd
    } catch {
        Write-Host "Error: Failed to initialize theme '$Theme': $($_.Exception.Message)" -ForegroundColor Red
        return 1
    }
}

function omp_show {
    param(
        [Parameter(Position=0)]
        [string]$StartTheme
    )
    
    # Check if oh-my-posh command is available
    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Write-Host "Error: oh-my-posh command not found" -ForegroundColor Red
        Write-Host "Please install oh-my-posh first" -ForegroundColor Yellow
        return 1
    }
    
    # Check if themes directory exists
    if (-not (Test-Path $OMP_THEMES)) {
        Write-Host "Error: Themes directory not found: $OMP_THEMES" -ForegroundColor Red
        return 1
    }
    
    # Get a list of all theme files
    $themes = @(Get-ChildItem $OMP_THEMES -Name "*.omp.json" | ForEach-Object { $_.Replace(".omp.json", "") })
    $numThemes = $themes.Count
    
    # Check if any themes were found
    if ($numThemes -eq 0) {
        Write-Host "Error: No theme files found in $OMP_THEMES" -ForegroundColor Red
        return 1
    }
    
    $currentIndex = 0

    # Get the current theme name from the POSH_THEME env var
    $currentThemeName = ""
    if ($env:POSH_THEME) {
        $currentThemeName = [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetFileNameWithoutExtension($env:POSH_THEME))
    }

    # If a theme is specified as argument, start with that theme
    if ($StartTheme) {
        $specifiedTheme = $StartTheme
        # Find the index of the specified theme
        for ($i = 0; $i -lt $numThemes; $i++) {
            if ($themes[$i] -eq $specifiedTheme) {
                $currentIndex = $i
                break
            }
        }
    } else {
        # Find the index of the current theme
        for ($i = 0; $i -lt $numThemes; $i++) {
            if ($themes[$i] -eq $currentThemeName) {
                $currentIndex = $i
                break
            }
        }
    }

    # Store original theme to restore on quit
    $originalThemeName = ""
    if ($env:POSH_THEME) {
        $originalThemeName = [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetFileNameWithoutExtension($env:POSH_THEME))
    }

    # Function to display the current theme
    function Show-Theme {
        Clear-Host
        $themeFile = "$OMP_THEMES/$($themes[$currentIndex]).omp.json"
        $themeName = $themes[$currentIndex]
        
        # Check if this is the default theme
        $defaultTheme = Get-Content ~/.config/omp_tools/default -ErrorAction SilentlyContinue | ForEach-Object { $_ } | Where-Object { $_ } | Select-Object -First 1
        if (-not $defaultTheme) {
            $defaultTheme = "nu4a"
        }
        
        # Check if this is the currently active theme
        $isCurrent = ""
        $isDefault = ""
        
        if ($themeName -eq $currentThemeName) {
            $isCurrent = " (CURRENT)"
        }
        
        if ($themeName -eq $defaultTheme) {
            $isDefault = " (DEFAULT)"
        }
        
        $headerText = " Previewing theme: $themeName$isCurrent$isDefault "

       # Print the header
        Write-Host $headerText -BackgroundColor Blue -ForegroundColor White
        Write-Host "--------------------------------"
        Write-Host " "

        # Print the rendered prompt
        $themeFile = Join-Path $OMP_THEMES "$($themes[$currentIndex]).omp.json"
        Write-Host "Theme preview:" -ForegroundColor Green
        Write-Host "File: $themeFile" -ForegroundColor DarkGray

        # Print the rendered prompt - DO NOT CHANGE THIS LINE - IT WORKS ON WINDOWS/MAC.
        oh-my-posh print primary --config $themeFile

        # Print the instructions
        Write-Host "echo hello world"
        Write-Host " "
        Write-Host "--------------------------------"
        Write-Host " Use j/k to cycle, Enter to set, s to set default, q to quit " -BackgroundColor Blue -ForegroundColor White -NoNewline
   }

    # Main loop to handle keypresses
    while ($true) {
        Show-Theme
        
        # Read a single keypress
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        # Debug: Show what key is being pressed (only for troubleshooting)
        # Write-Host "Key pressed: '$($key.Character)' (ASCII: $([int]$key.Character), Key: $($key.Key))" -ForegroundColor Yellow
        
        # Check key code for special keys, character for regular keys
        $shouldBreak = $false
        
        if ($key.Key -eq [ConsoleKey]::Enter -or $key.Character -eq [char]13) {
            # Enter key
            Clear-Host
            $selectedTheme = $themes[$currentIndex]
            omp_set $selectedTheme
            Write-Host "Theme set to $selectedTheme"
            
            # Check if theme differs from default
            $defaultTheme = Get-Content ~/.config/omp_tools/default -ErrorAction SilentlyContinue | ForEach-Object { $_ } | Where-Object { $_ } | Select-Object -First 1
            if (-not $defaultTheme) {
                $defaultTheme = "nu4a"
            }
            if ($selectedTheme -ne $defaultTheme) {
                Write-Host "Note: Current theme ($selectedTheme) differs from default theme ($defaultTheme)" -ForegroundColor Yellow
            }
            $shouldBreak = $true
        }
        elseif ($key.Key -eq [ConsoleKey]::Escape) {
            # Escape key
            Clear-Host
            # Restore the original theme
            omp_set $originalThemeName
            Write-Host "Theme selection cancelled."
            $shouldBreak = $true
        }
        else {
            # Regular character keys
            switch ($key.Character) {
                'k' { # Up
                    $currentIndex = ($currentIndex - 1 + $numThemes) % $numThemes
                }
                'j' { # Down
                    $currentIndex = ($currentIndex + 1) % $numThemes
                }
                's' { # Set as default
                    Clear-Host
                    $selectedTheme = $themes[$currentIndex]
                    New-Item -ItemType Directory -Force -Path ~/.config/omp_tools | Out-Null
                    $selectedTheme | Out-File ~/.config/omp_tools/default
                    omp_set $selectedTheme
                    Write-Host "Theme set to $selectedTheme and saved as default"
                    $shouldBreak = $true
                }
                'q' { # Quit
                    Clear-Host
                    # Restore the original theme
                    omp_set $originalThemeName
                    Write-Host "Theme selection cancelled."
                    
                    # Check if restored theme differs from default
                    $defaultTheme = Get-Content ~/.config/omp_tools/default -ErrorAction SilentlyContinue | ForEach-Object { $_ } | Where-Object { $_ } | Select-Object -First 1
                    if (-not $defaultTheme) {
                        $defaultTheme = "nu4a"
                    }
                    if ($originalThemeName -ne $defaultTheme) {
                        Write-Host "Note: Current theme ($originalThemeName) differs from default theme ($defaultTheme)" -ForegroundColor Yellow
                    }
                    $shouldBreak = $true
                }
                'Q' { # Quit (uppercase)
                    Clear-Host
                    # Restore the original theme
                    omp_set $originalThemeName
                    Write-Host "Theme selection cancelled."
                    $shouldBreak = $true
                }
            }
        }
        
        if ($shouldBreak) {
            break
        }
    }
}

# Environment function
function omp_env {
    $envInfo = Get-OMPEnvironment
    Write-Host "=== OH-MY-POSH ENVIRONMENT ===" -ForegroundColor Cyan
    Write-Host "Operating System: $($envInfo.OperatingSystem)" -ForegroundColor Yellow
    Write-Host "Shell: $($envInfo.Shell)" -ForegroundColor Yellow
    Write-Host "oh-my-posh Install Dir: $($envInfo.OMPInstallDir)" -ForegroundColor Yellow
    Write-Host "oh-my-posh Themes Dir: $($envInfo.OMPThemesDir)" -ForegroundColor Yellow
    Write-Host "oh-my-posh Executable: $($envInfo.OMPExecutable)" -ForegroundColor Yellow
    Write-Host "Package Manager: $($envInfo.PackageManager)" -ForegroundColor Yellow
    Write-Host "===============================" -ForegroundColor Cyan
}

# Help function
function omp_help {
    Write-Host "=== OH-MY-POSH TOOLS HELP ===" -ForegroundColor Cyan
    Write-Host "Usage: . dot-oh-my-posh.ps1 [-h] [-e] [-v]" -ForegroundColor Yellow
    Write-Host "" -ForegroundColor White
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -h    Show this help message" -ForegroundColor White
    Write-Host "  -e    Show environment information only" -ForegroundColor White
    Write-Host "  -v    Show version information" -ForegroundColor White
    Write-Host "" -ForegroundColor White
    Write-Host "Functions:" -ForegroundColor Yellow
    Write-Host "  omp_ls    List available themes" -ForegroundColor White
    Write-Host "  omp_set   Set theme (use without args to see current/default)" -ForegroundColor White
    Write-Host "  omp_show  Interactive theme browser" -ForegroundColor White
    Write-Host "  omp_help  Show this help message" -ForegroundColor White
    Write-Host "  omp_env   Show environment information" -ForegroundColor White
    Write-Host "  omp_install Install script to home directory" -ForegroundColor White
    Write-Host "" -ForegroundColor White
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  . dot-oh-my-posh.ps1          # Load with default theme" -ForegroundColor White
    Write-Host "  . dot-oh-my-posh.ps1 -e       # Show environment info only" -ForegroundColor White
    Write-Host "  . dot-oh-my-posh.ps1 -h       # Show this help" -ForegroundColor White
    Write-Host "  . dot-oh-my-posh.ps1 -v       # Show version" -ForegroundColor White
    Write-Host "  omp_ls                        # List themes" -ForegroundColor White
    Write-Host "  omp_set nu4a                  # Set theme to nu4a" -ForegroundColor White
    Write-Host "  omp_show                      # Interactive theme browser" -ForegroundColor White
    Write-Host "  omp_help                      # Show this help" -ForegroundColor White
    Write-Host "  omp_env                       # Show environment info" -ForegroundColor White
    Write-Host "  omp_install                   # Install script permanently" -ForegroundColor White
    Write-Host "===============================" -ForegroundColor Cyan
}

# Main omp function that acts as a wrapper for all individual functions
function omp {
    param(
        [Parameter(Position=0)]
        [string]$Command,
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    
    if (-not $Command) {
        Write-Host "Usage: omp <command> [args...]" -ForegroundColor Yellow
        Write-Host "" -ForegroundColor White
        Write-Host "Available commands:" -ForegroundColor Yellow
        Write-Host "  ls       List available themes" -ForegroundColor White
        Write-Host "  set      Set theme (use without args to see current/default)" -ForegroundColor White
        Write-Host "  show     Interactive theme browser" -ForegroundColor White
        Write-Host "  help     Show help message" -ForegroundColor White
        Write-Host "  env      Show environment information" -ForegroundColor White
        Write-Host "  install  Install script to home directory" -ForegroundColor White
        Write-Host "" -ForegroundColor White
        Write-Host "Examples:" -ForegroundColor Yellow
        Write-Host "  omp ls                     # List themes" -ForegroundColor White
        Write-Host "  omp set nu4a               # Set theme to nu4a" -ForegroundColor White
        Write-Host "  omp show                   # Interactive theme browser" -ForegroundColor White
        Write-Host "  omp help                   # Show help" -ForegroundColor White
        Write-Host "  omp env                    # Show environment info" -ForegroundColor White
        Write-Host "  omp install                # Install script permanently" -ForegroundColor White
        return
    }
    
    switch ($Command) {
        "ls" {
            omp_ls @Arguments
        }
        "set" {
            omp_set @Arguments
        }
        "show" {
            omp_show @Arguments
        }
        "help" {
            omp_help @Arguments
        }
        "env" {
            omp_env @Arguments
        }
        "install" {
            omp_install @Arguments
        }
        default {
            Write-Host "Unknown command: $Command" -ForegroundColor Red
            Write-Host "Use 'omp help' for available commands" -ForegroundColor Yellow
        }
    }
}

# Tab completion for omp_set and omp_show
function _omp_completion {
    param(
        [string]$wordToComplete,
        [string]$commandAst,
        [int]$cursorPosition
    )
    
    $themes = @(Get-ChildItem $OMP_THEMES -Name "*.omp.json" | ForEach-Object { $_.Replace(".omp.json", "") })
    return $themes | Where-Object { $_ -like "*$wordToComplete*" }
}

# Register tab completion
Register-ArgumentCompleter -CommandName omp_set -ScriptBlock { _omp_completion $args[0] $args[1] $args[2] }
Register-ArgumentCompleter -CommandName omp_show -ScriptBlock { _omp_completion $args[0] $args[1] $args[2] }

function omp_install {
    $scriptDir = Split-Path -Parent $PSCommandPath
    if (-not $scriptDir) {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    }
    $homeDir = $env:USERPROFILE
    if (-not $homeDir) {
        $homeDir = $env:HOME
    }
    
    Write-Host "Installing Oh My Posh tools for PowerShell..." -ForegroundColor Green
    
    # Copy the PowerShell script to home directory
    $targetFile = Join-Path $homeDir ".oh-my-posh-tools.ps1"
    try {
        $sourceFile = Join-Path $scriptDir "dot-oh-my-posh.ps1"
        Copy-Item $sourceFile $targetFile -Force
        Write-Host "Success: PowerShell script installed to $targetFile" -ForegroundColor Green
        Write-Host ""
        Write-Host "To use the tools, add this line to your PowerShell profile:" -ForegroundColor Yellow
        Write-Host ". ~/.oh-my-posh-tools.ps1" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Or run this command to add it automatically:" -ForegroundColor Yellow
        Write-Host 'Add-Content $PROFILE ". ~/.oh-my-posh-tools.ps1"' -ForegroundColor Cyan
    }
    catch {
        Write-Host "Error: Failed to install PowerShell script" -ForegroundColor Red
        return 1
    }
}

# Initialize oh-my-posh with default theme (only if no flags provided)
if (-not $h -and -not $e -and -not $v) {
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        $themeFile = $DEFAULT_OMP_THEME + '.omp.json'
        $fullPath = Join-Path $OMP_THEMES $themeFile
        if (Test-Path $fullPath) {
            try {
                & oh-my-posh init pwsh --config "`"$fullPath`"" | Invoke-Expression
            } catch {
                Write-Host "Warning: Failed to initialize oh-my-posh theme: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "Warning: Default theme '$DEFAULT_OMP_THEME' not found at $fullPath" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Warning: oh-my-posh command not found. Please install oh-my-posh to use themes." -ForegroundColor Yellow
    }
}
