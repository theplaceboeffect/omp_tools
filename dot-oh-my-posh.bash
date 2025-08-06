## Version: v01.10.02
## -------- OH-MY-POSH --------

# Verify bash is being used
if [[ -z "$BASH_VERSION" ]]; then
    echo "Error: This script requires bash. Current shell: $SHELL"
    echo "Please run this script with bash."
    return 1
fi

# Parse command-line arguments
SHOW_HELP=false
SHOW_ENV=false
SHOW_VERSION=false

# Check for flags in arguments
for arg in "$@"; do
    case "$arg" in
        -h)
            SHOW_HELP=true
            ;;
        -e)
            SHOW_ENV=true
            ;;
        -v)
            SHOW_VERSION=true
            ;;
    esac
done

# Show version if -v flag is provided
if [[ "$SHOW_VERSION" == "true" ]]; then
    echo "Version: v01.10.02"
    return
fi

# Show help if -h flag is provided
if [[ "$SHOW_HELP" == "true" ]]; then
    echo "=== OH-MY-POSH TOOLS HELP ==="
    echo "Usage: . dot-oh-my-posh.bash [-h] [-e] [-v]"
    echo ""
    echo "Options:"
    echo "  -h    Show this help message"
    echo "  -e    Show environment information only"
    echo "  -v    Show version information"
    echo ""
    echo "Functions:"
    echo "  omp_ls    List available themes"
    echo "  omp_set   Set theme (use without args to see current/default)"
    echo "  omp_show  Interactive theme browser"
    echo "  omp_help  Show this help message"
    echo "  omp_env   Show environment information"
    echo "  omp_install Install script to home directory"
    echo ""
    echo "Examples:"
    echo "  . dot-oh-my-posh.bash         # Load with default theme"
    echo "  . dot-oh-my-posh.bash -e      # Show environment info only"
    echo "  . dot-oh-my-posh.bash -h      # Show this help"
    echo "  . dot-oh-my-posh.bash -v      # Show version"
    echo "  omp_ls                        # List themes"
    echo "  omp_set nu4a                  # Set theme to nu4a"
    echo "  omp_show                      # Interactive theme browser"
    echo "  omp_help                      # Show this help"
    echo "  omp_env                       # Show environment info"
    echo "  omp_install                   # Install script permanently"
    echo "==============================="
    return
fi

# Environment Detection for Windows Compatibility
get_omp_environment() {
    # Determine Operating System
    local os=""
    case "$(uname -s)" in
        Darwin*)    os="macOS" ;;
        Linux*)     os="Linux" ;;
        CYGWIN*|MINGW*|MSYS*) os="Windows" ;;
        *)          os="Unknown" ;;
    esac
    
    # Determine Shell
    local shell="bash"
    
    # Determine oh-my-posh installation directory
    local omp_path=""
    
    # Check common installation paths
    if [[ -d "$(brew --prefix oh-my-posh 2>/dev/null)" ]]; then
        omp_path="$(brew --prefix oh-my-posh)"
    elif [[ -d "/home/linuxbrew/.linuxbrew/opt/oh-my-posh" ]]; then
        omp_path="/home/linuxbrew/.linuxbrew/opt/oh-my-posh"
    elif [[ -d "$HOME/.oh-my-posh" ]]; then
        omp_path="$HOME/.oh-my-posh"
    elif [[ -d "$LOCALAPPDATA/oh-my-posh" ]]; then
        omp_path="$LOCALAPPDATA/oh-my-posh"
    elif [[ -d "/usr/local/share/oh-my-posh" ]]; then
        omp_path="/usr/local/share/oh-my-posh"
    elif [[ -d "/opt/oh-my-posh" ]]; then
        omp_path="/opt/oh-my-posh"
    else
        # Try to find oh-my-posh executable
        local omp_exe
        omp_exe=$(command -v oh-my-posh 2>/dev/null)
        if [[ -n "$omp_exe" ]]; then
            omp_path=$(dirname "$omp_exe")
        fi
    fi
    
    # Determine Package Manager
    local package_manager="Unknown"
    
    # Test each package manager individually
    if command -v brew >/dev/null 2>&1; then
        package_manager="Homebrew"
    fi
    
    if [[ "$package_manager" == "Unknown" ]] && command -v winget >/dev/null 2>&1; then
        package_manager="winget"
    fi
    
    if [[ "$package_manager" == "Unknown" ]] && command -v choco >/dev/null 2>&1; then
        package_manager="Chocolatey"
    fi
    
    if [[ "$package_manager" == "Unknown" ]] && command -v scoop >/dev/null 2>&1; then
        package_manager="Scoop"
    fi
    
    if [[ "$package_manager" == "Unknown" ]] && command -v apt >/dev/null 2>&1; then
        package_manager="apt"
    fi
    
    if [[ "$package_manager" == "Unknown" ]] && command -v yum >/dev/null 2>&1; then
        package_manager="yum"
    fi
    
    # Create environment info string
    local env_info="OS:$os|Shell:$shell|OMPDir:$omp_path|PackageManager:$package_manager"
    echo "$env_info"
}

# Get environment information
OMP_ENVIRONMENT=$(get_omp_environment)

# Show environment information only if -e flag is provided
if [[ "$SHOW_ENV" == "true" ]]; then
    echo "=== OH-MY-POSH ENVIRONMENT ==="
    echo "Operating System: $(echo "$OMP_ENVIRONMENT" | cut -d'|' -f1 | cut -d':' -f2)"
    echo "Shell: $(echo "$OMP_ENVIRONMENT" | cut -d'|' -f2 | cut -d':' -f2)"
    echo "oh-my-posh Install Dir: $(echo "$OMP_ENVIRONMENT" | cut -d'|' -f3 | cut -d':' -f2)"
    echo "Package Manager: $(echo "$OMP_ENVIRONMENT" | cut -d'|' -f4 | cut -d':' -f2)"
    echo "==============================="
    return
fi

DEFAULT_OMP_THEME=$(cat ~/.config/omp_tools/default 2>/dev/null || echo "nu4a")

# Set OMP_THEMES with fallback for Linuxbrew
if [[ -d "$(brew --prefix oh-my-posh 2>/dev/null)/themes" ]]; then
    OMP_THEMES="$(brew --prefix oh-my-posh)/themes"
elif [[ -d "/home/linuxbrew/.linuxbrew/opt/oh-my-posh/themes" ]]; then
    OMP_THEMES="/home/linuxbrew/.linuxbrew/opt/oh-my-posh/themes"
else
    OMP_THEMES="$(brew --prefix oh-my-posh)/themes"
fi

alias omp_ls="ls $OMP_THEMES"

function omp_set() {
    if [[ -z "$1" ]]; then
        # Display current and default themes when no parameter is provided
        local current_theme_name
        current_theme_name=$(basename "$POSH_THEME" .omp.json)
        local default_theme
        default_theme=$(cat ~/.config/omp_tools/default 2>/dev/null || echo "nu4a")
        
        echo "Current theme: $current_theme_name"
        echo "Default theme: $default_theme"
        return
    fi
    
    echo "Setting theme to $1"
    local theme_cmd
    theme_cmd="$(oh-my-posh init bash --config "$OMP_THEMES/$1.omp.json")"
    eval "$theme_cmd"
}

function omp_show() {
    # Get a list of all theme files
    local themes=("$OMP_THEMES"/*.omp.json)
    local num_themes=${#themes[@]}
    local current_index=1

    # Get the current theme name from the POSH_THEME env var
    local current_theme_name
    current_theme_name=$(basename "$POSH_THEME" .omp.json)

    # If a theme is specified as argument, start with that theme
    if [[ -n "$1" ]]; then
        local specified_theme="$1"
        # Find the index of the specified theme
        for i in {1..$num_themes}; do
            if [[ "$(basename "${themes[$i]}" .omp.json)" == "$specified_theme" ]]; then
                current_index=$i
                break
            fi
        done
    else
        # Find the index of the current theme
        for i in {1..$num_themes}; do
            if [[ "$(basename "${themes[$i]}" .omp.json)" == "$current_theme_name" ]]; then
                current_index=$i
                break
            fi
        done
    fi

    # Store original theme to restore on quit
    local original_config
    original_config=$(oh-my-posh export config)
    local original_theme_name
    original_theme_name=$(basename "$POSH_THEME" .omp.json)

    # Function to display the current theme
    display_theme() {
        clear
        local theme_file=${themes[$current_index]}
        local theme_name
        theme_name=$(basename "$theme_file" .omp.json)
        
        # Check if this is the default theme
        local default_theme
        default_theme=$(cat ~/.config/omp_tools/default 2>/dev/null || echo "nu4a")
        
        # Check if this is the currently active theme
        local is_current=""
        local is_default=""
        
        if [[ "$theme_name" == "$current_theme_name" ]]; then
            is_current=" (CURRENT)"
        fi
        
        if [[ "$theme_name" == "$default_theme" ]]; then
            is_default=" (DEFAULT)"
        fi
        
        local header_text=" Previewing theme: $theme_name$is_current$is_default "

        # Print the header with blue background and white text
        printf "\033[44m\033[1;37m%s\033[0m\n" "$header_text"
        
        # Print the rendered prompt
        echo ""
        oh-my-posh print primary --config "$theme_file" --shell universal
        echo "echo Hello World"
        echo ""

        # Print the instructions
        printf "\n\033[44m\033[1;37m%s\033[0m" " Use j/k to cycle, Enter to set, s to set default, q to quit "
    }

    # Main loop to handle keypresses
    while true; do
        display_theme
        
        # Read a single keypress
        read -s -r -n 1 key

        case "$key" in
            'k') # Up
                current_index=$((current_index - 1))
                if [[ $current_index -lt 1 ]]; then
                    current_index=$num_themes
                fi
                ;;
            'j') # Down
                current_index=$((current_index + 1))
                if [[ $current_index -gt $num_themes ]]; then
                    current_index=1
                fi
                ;;
            $'\n') # Enter
                clear
                local selected_theme
                selected_theme=$(basename "${themes[$current_index]}" .omp.json)
                omp_set "$selected_theme"
                echo "Theme set to $selected_theme"
                
                # Check if theme differs from default
                local default_theme
                default_theme=$(cat ~/.config/omp_tools/default 2>/dev/null || echo "nu4a")
                if [[ "$selected_theme" != "$default_theme" ]]; then
                    echo "Note: Current theme ($selected_theme) differs from default theme ($default_theme)"
                fi
                break
                ;;
            's') # Set as default
                clear
                local selected_theme
                selected_theme=$(basename "${themes[$current_index]}" .omp.json)
                mkdir -p ~/.config/omp_tools
                echo "$selected_theme" > ~/.config/omp_tools/default
                omp_set "$selected_theme"
                echo "Theme set to $selected_theme and saved as default"
                break
                ;;
            'q') # Quit
                clear
                # Restore the original theme
                omp_set "$original_theme_name"
                echo "Theme selection cancelled."
                
                # Check if restored theme differs from default
                local default_theme
                default_theme=$(cat ~/.config/omp_tools/default 2>/dev/null || echo "nu4a")
                if [[ "$original_theme_name" != "$default_theme" ]]; then
                    echo "Note: Current theme ($original_theme_name) differs from default theme ($default_theme)"
                fi
                break
                ;;
        esac
    done
}

# Install function
omp_install() {
    local script_path
    script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local script_file="$script_path/dot-oh-my-posh.bash"
    local home_dir="$HOME"
    local install_path="$home_dir/dot-oh-my-posh.bash"
    
    if [[ ! -f "$script_file" ]]; then
        echo "Error: Script not found at expected location: $script_file"
        return 1
    fi
    
    if cp "$script_file" "$install_path"; then
        echo "✓ Script installed to: $install_path"
        echo ""
        echo "To use permanently, add this line to your bash profile:"
        echo "  . ~/dot-oh-my-posh.bash"
        echo ""
        echo "To find your profile location, run:"
        echo "  echo \$HOME/.bashrc"
    else
        echo "Error installing script"
        return 1
    fi
}

# Environment function
omp_env() {
    local env_info
    env_info=$(get_omp_environment)
    echo "=== OH-MY-POSH ENVIRONMENT ==="
    echo "Operating System: $(echo "$env_info" | cut -d'|' -f1 | cut -d':' -f2)"
    echo "Shell: $(echo "$env_info" | cut -d'|' -f2 | cut -d':' -f2)"
    echo "oh-my-posh Install Dir: $(echo "$env_info" | cut -d'|' -f3 | cut -d':' -f2)"
    echo "Package Manager: $(echo "$env_info" | cut -d'|' -f4 | cut -d':' -f2)"
    echo "==============================="
}

# Help function
omp_help() {
    echo "=== OH-MY-POSH TOOLS HELP ==="
    echo "Usage: . dot-oh-my-posh.bash [-h] [-e] [-v]"
    echo ""
    echo "Options:"
    echo "  -h    Show this help message"
    echo "  -e    Show environment information only"
    echo "  -v    Show version information"
    echo ""
    echo "Functions:"
    echo "  omp_ls    List available themes"
    echo "  omp_set   Set theme (use without args to see current/default)"
    echo "  omp_show  Interactive theme browser"
    echo "  omp_help  Show this help message"
    echo "  omp_env   Show environment information"
    echo "  omp_install Install script to home directory"
    echo ""
    echo "Examples:"
    echo "  . dot-oh-my-posh.bash         # Load with default theme"
    echo "  . dot-oh-my-posh.bash -e      # Show environment info only"
    echo "  . dot-oh-my-posh.bash -h      # Show this help"
    echo "  . dot-oh-my-posh.bash -v      # Show version"
    echo "  omp_ls                        # List themes"
    echo "  omp_set nu4a                  # Set theme to nu4a"
    echo "  omp_show                      # Interactive theme browser"
    echo "  omp_help                      # Show this help"
    echo "  omp_env                       # Show environment info"
    echo "  omp_install                   # Install script permanently"
    echo "==============================="
}

# Initialize oh-my-posh with default theme (only if no flags provided)
if [[ "$SHOW_HELP" != "true" && "$SHOW_ENV" != "true" && "$SHOW_VERSION" != "true" ]]; then
    eval "$(oh-my-posh init bash --config "$OMP_THEMES/$DEFAULT_OMP_THEME.omp.json")"
fi 
