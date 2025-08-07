# Oh My Posh Tools

A command-line interface project with enhanced Oh My Posh configuration and theme management tools for PowerShell, zsh, and bash.

[![Version](https://img.shields.io/badge/version-v01.10.02-blue.svg)](https://github.com/your-repo/oh-my-posh-tools)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell Support](https://img.shields.io/badge/shell-PowerShell%20%7C%20Zsh%20%7C%20Bash-orange.svg)](https://ohmyposh.dev/)

> **Quick Start**: Clone the repo and source the appropriate script for your shell. See [Installation](#installation) for detailed instructions.

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

### Prerequisites

Before installing, ensure you have:
- [Oh My Posh](https://ohmyposh.dev/docs/installation) installed on your system
- The appropriate shell version (see [Requirements](#requirements))

### Quick Installation

1. **Clone this repository**
   ```bash
   git clone https://github.com/your-repo/oh-my-posh-tools.git
   cd oh-my-posh-tools
   ```

2. **Source the appropriate configuration file for your shell:**

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

### Verification

After sourcing the script, verify the installation:

```bash
# Check if functions are available
omp_help

# Show environment information
omp_env

# List available themes
omp_ls
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

### Default Theme
The default theme is stored in `~/.config/omp_tools/default` and defaults to "nu4a" if not set.

### Customization
You can customize the default theme by:

```bash
# Set a new default theme
omp_set your-theme-name

# Or manually edit the config file
echo "your-theme-name" > ~/.config/omp_tools/default
```

### Profile Integration
For permanent installation, use the `omp_install` function:

```bash
# Install to home directory
omp_install

# Add to your shell profile (examples)
echo "source ~/dot-oh-my-posh.bash" >> ~/.bashrc    # Bash
echo "source ~/dot-oh-my-posh.zsh" >> ~/.zshrc      # Zsh
# For PowerShell, add to your profile
```

## Requirements

- Oh My Posh installed (via Homebrew, winget, Chocolatey, Scoop, apt, or yum)
- **For PowerShell**: PowerShell 7+ (cross-platform)
- **For Zsh**: Zsh shell (macOS default, available on Linux/Windows)
- **For Bash**: Bash 5.x+ (required - install via `brew install bash` on macOS/Linux)
- GitHub CLI (for repository management)

## Testing

The project includes a comprehensive test suite. See [tests/README.md](tests/README.md) for detailed testing instructions.

```bash
# Run all tests
./tests/run_all_tests.sh

# Run tests with verbose output
./tests/run_all_tests.sh --verbose

# Run individual shell tests
bash tests/test_bash_omp_help.sh --verbose
zsh tests/test_zsh_omp_help.sh --verbose
pwsh -ExecutionPolicy Bypass -File tests/test_ps1_omp_help.ps1 -Verbose
```

## Troubleshooting

### Common Issues
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

### Oh My Posh Not Found
If you see "oh-my-posh: command not found":
```bash
# Install Oh My Posh (macOS)
brew install oh-my-posh

# Install Oh My Posh (Windows)
winget install JanDeDobbeleer.OhMyPosh

# Install Oh My Posh (Linux)
# See https://ohmyposh.dev/docs/installation
```

### Theme Not Found
If you see "theme not found" errors:
```bash
# List available themes
omp_ls

# Check theme directory
ls $(brew --prefix oh-my-posh)/themes/

# Set a known theme
omp_set nu4a
```

### Version Requirements

#### Bash Version Check
The script automatically checks for bash 5.x+ compatibility:
- **macOS**: System bash (3.2.x) is too old - use Homebrew bash
- **Linux**: Ensure bash 5.x+ is installed
- **Windows**: Use WSL with bash 5.x+

The version check prevents compatibility issues with older bash versions.

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

1. Clone the repository
2. Install dependencies
3. Run tests to ensure everything works
4. Make your changes
5. Submit a pull request

### Testing Your Changes

```bash
# Run the test suite
./tests/run_all_tests.sh --verbose

# Test specific shell functionality
bash -c "source dot-oh-my-posh.bash && omp_help"
zsh -c "source dot-oh-my-posh.zsh && omp_help"
pwsh -ExecutionPolicy Bypass -Command ". dot-oh-my-posh.ps1; omp_help"
```

## License

[Add your license here]

## Acknowledgments

- [Oh My Posh](https://ohmyposh.dev/) for the amazing prompt engine
- The open source community for inspiration and feedback 
