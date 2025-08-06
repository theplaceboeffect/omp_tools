# Oh My Posh Tools - Product Requirements Document

## Overview

Oh My Posh Tools is a command-line interface project that provides enhanced Oh My Posh configuration and theme management tools. The tool offers interactive theme browsing, persistent configuration, and cross-platform support for PowerShell, zsh, and bash environments.

## Core Requirements

### 1. Theme Management Functions

#### 1.1 `omp_set [theme]`
**Purpose:** Set Oh My Posh theme to specified theme or display current status

**Requirements:**
- **With theme parameter:** Sets the Oh My Posh theme to the specified theme
- **Without parameters:** Displays the current theme and default theme
- **Tab completion:** Available for all installed themes
- **Error handling:** Graceful handling of invalid theme names
- **Feedback:** Clear confirmation message when theme is set

**Implementation Details:**
- Use `oh-my-posh init` command with appropriate shell parameter
- Store theme configuration in environment variables
- Read default theme from `~/.config/omp_tools/default`
- Fallback to "nu4a" if no default is configured

#### 1.2 `omp_show [theme]`
**Purpose:** Interactive theme previewer with navigation

**Requirements:**
- **Interactive browser:** Browse and preview all available themes
- **With theme parameter:** Starts the preview with the specified theme
- **Navigation:** Use `j`/`k` keys to cycle through themes
- **Actions:**
  - `Enter`: Set the current theme
  - `s`: Set as default theme
  - `q`: Quit and restore original theme
- **Tab completion:** Available for all installed themes
- **Visual indicators:** Show current and default theme status
- **Theme restoration:** Restore original theme when quitting

**Implementation Details:**
- Clear screen between theme displays
- Store original theme configuration for restoration
- Handle keyboard input for navigation
- Display theme status (CURRENT, DEFAULT)
- Provide helpful exit messages

#### 1.3 `omp_ls`
**Purpose:** List all available Oh My Posh themes

**Requirements:**
- Display all available themes in a readable format
- Simple list output without additional formatting
- Use standard `ls` command with theme directory

### 2. Configuration Management

#### 2.1 Default Theme Storage
**Requirements:**
- Store default theme in `~/.config/omp_tools/default`
- Automatic creation of config directory if it doesn't exist
- Fallback to "nu4a" if no default is configured
- Support for reading/writing default theme configuration

#### 2.2 Theme Discovery
**Requirements:**
- Automatically discover themes from Oh My Posh installation
- Use `$(brew --prefix oh-my-posh)/themes` for theme location
- Support for `.omp.json` theme files
- Handle missing theme directories gracefully

### 3. User Experience

#### 3.1 Tab Completion
**Requirements:**
- Tab completion for `omp_set` and `omp_show` commands
- Complete theme names from available themes
- Platform-specific implementation (zsh vs PowerShell)

#### 3.2 Visual Feedback
**Requirements:**
- Clear visual indicators for current and default themes
- Color-coded headers and instructions
- Helpful exit messages when themes differ from default
- Consistent styling across platforms

#### 3.3 Error Handling
**Requirements:**
- Graceful handling of invalid theme names
- Clear error messages for missing themes
- Fallback behavior for missing configuration
- Robust keyboard input handling

### 4. Cross-Platform Support

#### 4.1 Windows Compatibility
**Requirements:**
- **Environment Detection:** Automatically detect operating system, shell, and package manager
- **Installation Path Detection:** Support multiple oh-my-posh installation locations
- **Shell Support:** Full support for PowerShell, zsh, and bash environments
- **Package Manager Support:** Detect and support various package managers (Homebrew, winget, Chocolatey, Scoop, apt, yum)
- **Cross-Platform Paths:** Handle different installation paths for Windows, macOS, and Linux
- **Environment Information:** Display comprehensive environment information to users

**Implementation Details:**
- Detect operating system using platform-specific methods
- Identify shell type and version
- Search for oh-my-posh installation in common locations
- Detect available package managers
- Store environment information in `OMP_ENVIRONMENT` variable
- Display formatted environment information to users

#### 4.2 Zsh Support (`dot-oh-my-posh.zsh`)
**Requirements:**
- Full functionality in zsh environment
- zsh-specific syntax and commands
- Proper shell initialization
- zsh completion system integration

#### 4.3 PowerShell Support (`dot-oh-my-posh.ps1`)
**Requirements:**
- Full functionality in PowerShell environment
- PowerShell-specific syntax and commands
- Proper PowerShell initialization
- PowerShell completion system integration
- Equivalent feature parity with zsh version

### 5. Installation and Setup

#### 5.1 Prerequisites
**Requirements:**
- Oh My Posh installed via Homebrew
- Zsh shell (for zsh version)
- PowerShell (for PowerShell version)
- GitHub CLI (for repository management)

#### 5.2 Installation Process
**Requirements:**
- Clone repository
- Source the appropriate configuration file
- Automatic theme initialization
- Configuration directory creation

## Technical Specifications

### File Structure
```
oh-my-posh-tools/
├── dot-oh-my-posh.zsh      # Zsh configuration
├── dot-oh-my-posh.ps1      # PowerShell configuration
├── README.md               # Documentation
├── HISTORY.md              # Development history
└── PRD.md                 # This document
```

### Configuration Files
- **Default theme:** `~/.config/omp_tools/default`
- **Theme location:** `$(brew --prefix oh-my-posh)/themes`
- **Theme format:** `.omp.json` files

### Environment Variables
- `DEFAULT_OMP_THEME`: Current default theme
- `OMP_THEMES`: Path to theme directory
- `POSH_THEME`: Current active theme (Oh My Posh internal)

### Functions and Commands

#### Core Functions
1. `omp_set [theme]` - Set or display theme
2. `omp_show [theme]` - Interactive theme browser
3. `omp_ls` - List available themes

#### Helper Functions
1. `_omp_set_completion` - Tab completion for zsh
2. `_omp_completion` - Tab completion for PowerShell
3. `Display-Theme` - Theme display function (PowerShell)

### Keyboard Controls
- `j` - Navigate down
- `k` - Navigate up
- `Enter` - Set current theme
- `s` - Set as default theme
- `q` - Quit and restore original theme

## Implementation Guidelines

### Zsh Implementation
- Use zsh-specific syntax and features
- Implement proper completion system
- Handle zsh-specific environment variables
- Use zsh color codes for styling

### PowerShell Implementation
- Use PowerShell-specific syntax and features
- Implement proper completion system
- Handle PowerShell-specific environment variables
- Use PowerShell color formatting

### Common Patterns
- Consistent error handling across platforms
- Similar user experience and feedback
- Equivalent functionality between versions
- Robust theme discovery and validation

## Testing Requirements

### Functional Testing
- Theme setting functionality
- Interactive navigation
- Default theme persistence
- Tab completion
- Error handling

### Platform Testing
- Zsh compatibility
- PowerShell compatibility
- Cross-platform feature parity
- Installation and setup procedures

## Documentation Requirements

### User Documentation
- Clear installation instructions
- Usage examples for all functions
- Keyboard navigation guide
- Troubleshooting section

### Developer Documentation
- Code structure and organization
- Function documentation
- Platform-specific considerations
- Extension guidelines

## Future Enhancements

### Potential Features
- Theme customization options
- Theme import/export functionality
- Theme rating and favorites
- Batch theme operations
- Integration with Oh My Posh updates

### Technical Improvements
- Enhanced error handling
- Performance optimizations
- Additional platform support
- Plugin architecture
- Automated testing

## Success Criteria

### Functional Requirements
- All core functions work correctly
- Cross-platform compatibility
- Proper error handling
- User-friendly interface

### Quality Requirements
- Clean, maintainable code
- Comprehensive documentation
- Consistent user experience
- Robust error handling

### Performance Requirements
- Fast theme switching
- Responsive navigation
- Efficient theme discovery
- Minimal resource usage

This PRD provides a complete specification for rebuilding the Oh My Posh Tools from scratch, ensuring all functionality and user experience requirements are met. 