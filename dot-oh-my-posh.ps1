## -------- OH-MY-POSH --------

# Environment Detection for Windows Compatibility
function Get-OMPEnvironment {
    $envInfo = @{
        OperatingSystem = $null
        Shell = $null
        OMPInstallDir = $null
        PackageManager = $null
    }
    
    # Determine Operating System
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        $envInfo.OperatingSystem = "Windows"
    } elseif ($IsMacOS) {
        $envInfo.OperatingSystem = "macOS"
    } elseif ($IsLinux) {
        $envInfo.OperatingSystem = "Linux"
    } else {
        $envInfo.OperatingSystem = "Unknown"
    }
    
    # Determine Shell
    $envInfo.Shell = $PSVersionTable.PSEdition
    
    # Determine oh-my-posh installation directory
    $ompPath = $null
    
    # Check common installation paths
    $possiblePaths = @(
        "$(brew --prefix oh-my-posh 2>$null)",
        "$env:USERPROFILE\.oh-my-posh",
        "$env:LOCALAPPDATA\oh-my-posh",
        "/usr/local/share/oh-my-posh",
        "/opt/oh-my-posh"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $ompPath = $path
            break
        }
    }
    
    if (-not $ompPath) {
        # Try to find oh-my-posh executable
        $ompExe = Get-Command oh-my-posh -ErrorAction SilentlyContinue
        if ($ompExe) {
            $ompPath = Split-Path $ompExe.Source
        }
    }
    
    $envInfo.OMPInstallDir = $ompPath
    
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

# Get and display environment information
$OMP_ENVIRONMENT = Get-OMPEnvironment
Write-Host "=== OH-MY-POSH ENVIRONMENT ===" -ForegroundColor Cyan
Write-Host "Operating System: $($OMP_ENVIRONMENT.OperatingSystem)" -ForegroundColor Yellow
Write-Host "Shell: $($OMP_ENVIRONMENT.Shell)" -ForegroundColor Yellow
Write-Host "oh-my-posh Install Dir: $($OMP_ENVIRONMENT.OMPInstallDir)" -ForegroundColor Yellow
Write-Host "Package Manager: $($OMP_ENVIRONMENT.PackageManager)" -ForegroundColor Yellow
Write-Host "===============================" -ForegroundColor Cyan

$DEFAULT_OMP_THEME = Get-Content ~/.config/omp_tools/default -ErrorAction SilentlyContinue | ForEach-Object { $_ } | Where-Object { $_ } | Select-Object -First 1
if (-not $DEFAULT_OMP_THEME) {
    $DEFAULT_OMP_THEME = "nu4a"
}

$OMP_THEMES = "$(brew --prefix oh-my-posh)/themes"

function omp_ls {
    Get-ChildItem $OMP_THEMES -Name "*.omp.json" | ForEach-Object { $_.Replace(".omp.json", "") }
}

function omp_set {
    param(
        [Parameter(Position=0)]
        [string]$Theme
    )
    
    if (-not $Theme) {
        # Display current and default themes when no parameter is provided
        $currentThemeName = Split-Path $env:POSH_THEME -LeafBase -ErrorAction SilentlyContinue
        $defaultTheme = Get-Content ~/.config/omp_tools/default -ErrorAction SilentlyContinue | ForEach-Object { $_ } | Where-Object { $_ } | Select-Object -First 1
        if (-not $defaultTheme) {
            $defaultTheme = "nu4a"
        }
        
        Write-Host "Current theme: $currentThemeName"
        Write-Host "Default theme: $defaultTheme"
        return
    }
    
    Write-Host "Setting theme to $Theme"
    $themeCmd = oh-my-posh init pwsh --config "$OMP_THEMES/$Theme.omp.json"
    Invoke-Expression $themeCmd
}

function omp_show {
    param(
        [Parameter(Position=0)]
        [string]$StartTheme
    )
    
    # Get a list of all theme files
    $themes = @(Get-ChildItem $OMP_THEMES -Name "*.omp.json" | ForEach-Object { $_.Replace(".omp.json", "") })
    $numThemes = $themes.Count
    $currentIndex = 0

    # Get the current theme name from the POSH_THEME env var
    $currentThemeName = Split-Path $env:POSH_THEME -LeafBase -ErrorAction SilentlyContinue

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
    $originalConfig = oh-my-posh export config
    $originalThemeName = Split-Path $env:POSH_THEME -LeafBase -ErrorAction SilentlyContinue

    # Function to display the current theme
    function Display-Theme {
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
        
        # Print the rendered prompt
        $promptOutput = oh-my-posh print primary --config $themeFile
        Write-Host $promptOutput
        
        # Print the instructions
        Write-Host " Use j/k to cycle, Enter to set, s to set default, q to quit " -BackgroundColor Blue -ForegroundColor White -NoNewline
    }

    # Main loop to handle keypresses
    while ($true) {
        Display-Theme
        
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

# Initialize oh-my-posh with default theme
$initCmd = oh-my-posh init pwsh --config "$OMP_THEMES/$DEFAULT_OMP_THEME.omp.json"
Invoke-Expression $initCmd 