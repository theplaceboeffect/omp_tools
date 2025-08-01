# Oh My Posh Tools

A command-line interface project with enhanced Oh My Posh configuration and theme management tools.

## Features

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

## Installation

1. Clone this repository
2. Source the configuration file in your shell:
   ```bash
   source dot-oh-my-posh.zsh
   ```

## Usage Examples

```bash
# Set a theme
omp_set nu4a

# Show current and default themes
omp_set

# Interactive theme browser
omp_show

# Start theme browser with specific theme
omp_show nu4a

# List all available themes
omp_ls
```

## Configuration

The default theme is stored in `~/.config/omp_tools/default` and defaults to "nu4a" if not set.

## Requirements

- Oh My Posh installed via Homebrew
- Zsh shell
- GitHub CLI (for repository management)

## License

[Add your license here] 