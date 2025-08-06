# Oh My Posh Tools

A command-line interface project with enhanced Oh My Posh configuration and theme management tools for PowerShell, zsh, and bash.

## Features

### Windows Compatibility

This project includes comprehensive Windows compatibility features:

- **Environment Detection**: Automatically detects operating system, shell, and package manager
- **Cross-Platform Support**: Works on Windows, macOS, and Linux
- **Package Manager Detection**: Supports Homebrew, winget, Chocolatey, Scoop, apt, and yum
- **Installation Path Detection**: Automatically finds oh-my-posh installation in common locations
- **Environment Information**: Displays comprehensive environment information to users

### Oh My Posh Theme Management

This project includes a comprehensive set of functions for managing Oh My Posh themes:

#### `omp_set [theme]`
- **With theme parameter**: Sets the Oh My Posh theme to the specified theme
- **Without parameters**: Displays the current theme and default theme
- **Tab completion**: Available for all installed themes

#### `omp_show [theme]`
- **Interactive theme previewer**: Browse and preview all available themes
- **With theme parameter**: Starts the preview with the specified theme
- **Navigation**: Use `j`/`k` keys to cycle through themes
- **Actions**:
  - `Enter`: Set the current theme
  - `s`: Set as default theme
  - `q`: Quit and restore original theme
- **Tab completion**: Available for all installed themes

#### `omp_ls`
- Lists all available Oh My Posh themes

#### `omp_help`
- Displays comprehensive help information
- Shows all available functions and usage examples
- Includes command-line options and keyboard shortcuts

#### `omp_env`
- Shows detailed environment information
- Displays operating system, shell version, and Oh My Posh installation details
- Useful for troubleshooting and system information

#### `omp_install`
- Copies the script to your home directory for permanent installation
- Provides instructions for adding to shell profile
- Available in all shell versions

## Installation

1. Clone this repository
2. Source the appropriate configuration file in your shell:

### For Zsh Users
```bash
source dot-oh-my-posh.zsh
omp_install  # Optional: install script to home directory
```

### For PowerShell Users
```powershell
. dot-oh-my-posh.ps1
omp_install  # Optional: install script to home directory
```

### For Bash Users
**Requirements:** Bash 5.x or higher

```bash
# Check your bash version
bash --version

# If using bash < 5.x, install Homebrew bash (macOS/Linux)
brew install bash

# Source the script
source dot-oh-my-posh.bash

# Optional: install script to home directory
omp_install
```

**macOS Users:** The system bash (3.2.x) is too old. Use Homebrew bash:
```bash
brew install bash
$(brew --prefix bash)/bin/bash --login
source dot-oh-my-posh.bash
```

The installation script will automatically detect your shell and provide the appropriate setup instructions.

## Command-Line Options

All scripts support these command-line flags:

```bash
# Show help information
source dot-oh-my-posh.bash -h

# Show environment information only
source dot-oh-my-posh.bash -e

# Show version information
source dot-oh-my-posh.bash -v
```

## Usage Examples

### Basic Theme Management
```bash
# Set a theme
omp_set nu4a

# Show current and default themes
omp_set

# List all available themes
omp_ls
```

### Interactive Theme Browser
```bash
# Interactive theme browser
omp_show

# Start theme browser with specific theme
omp_show nu4a

# Navigation keys in omp_show:
# j/k - Navigate up/down through themes
# Enter - Set current theme
# s - Set as default theme
# q - Quit and restore original theme
```

### Utility Functions
```bash
# Show help information
omp_help

# Show environment details
omp_env

# Install script permanently
omp_install
```

### Bash-Specific Examples
```bash
# Check bash version first
bash --version

# Source with Homebrew bash (macOS)
$(brew --prefix bash)/bin/bash -c "source dot-oh-my-posh.bash && omp_help"

# Or start a new bash session
$(brew --prefix bash)/bin/bash --login
source dot-oh-my-posh.bash
omp_help
```

## Configuration

The default theme is stored in `~/.config/omp_tools/default` and defaults to "nu4a" if not set.

## Requirements

- Oh My Posh installed (via Homebrew, winget, Chocolatey, Scoop, apt, or yum)
- **For PowerShell**: PowerShell 7+ (cross-platform)
- **For Zsh**: Zsh shell (macOS default, available on Linux/Windows)
- **For Bash**: Bash 5.x+ (required - install via `brew install bash` on macOS/Linux)
- GitHub CLI (for repository management)

## Troubleshooting

### Bash Version Issues
If you see "Error: Oh-My-Posh requires Bash 5.x or higher":
```bash
# Check current bash version
bash --version

# Install Homebrew bash (macOS/Linux)
brew install bash

# Use Homebrew bash
$(brew --prefix bash)/bin/bash --login
source dot-oh-my-posh.bash
```

### Function Not Found Errors
If bash functions aren't available after sourcing:
```bash
# Ensure you're using bash 5.x+
bash --version

# Source the script properly
source dot-oh-my-posh.bash

# Verify functions are available
declare -f omp_help
```

### Version Requirements

#### Bash Version Check
The script automatically checks for bash 5.x+ compatibility:
- **macOS**: System bash (3.2.x) is too old - use Homebrew bash
- **Linux**: Ensure bash 5.x+ is installed
- **Windows**: Use WSL with bash 5.x+

The version check prevents compatibility issues with older bash versions.

## License

[Add your license here] 
