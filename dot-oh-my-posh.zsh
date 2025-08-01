## -------- OH-MY-POSH --------

DEFAULT_OMP_THEME=$(cat ~/.config/omp_tools/default 2>/dev/null || echo "nu4a")
OMP_THEMES=$(brew --prefix oh-my-posh)/themes

alias omp_ls="ls $OMP_THEMES"

function omp_set() {
    echo "Setting theme to $1"
    local theme_cmd
    theme_cmd="$(oh-my-posh init zsh --config "$OMP_THEMES/$1.omp.json")"
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
        tput clear
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

        # Print the header
        print "\e[48;2;0;0;255m\e[1;97m$header_text\e[0m"
        
        # Print the rendered prompt
        print -P "$(oh-my-posh print primary --config "$theme_file")"
        
        # Print the instructions
        print -n "\e[48;2;0;0;255m\e[1;97m Use j/k to cycle, \u23ce to set, s to set default, q to quit \e[0m"
    }

    # Main loop to handle keypresses
    while true; do
        display_theme
        
        # Read a single keypress
        read -s -r -k 1 key

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
                tput clear
                local selected_theme
                selected_theme=$(basename "${themes[$current_index]}" .omp.json)
                omp_set "$selected_theme"
                echo "Theme set to $selected_theme"
                break
                ;;
            's') # Set as default
                tput clear
                local selected_theme
                selected_theme=$(basename "${themes[$current_index]}" .omp.json)
                mkdir -p ~/.config/omp_tools
                echo "$selected_theme" > ~/.config/omp_tools/default
                omp_set "$selected_theme"
                echo "Theme set to $selected_theme and saved as default"
                break
                ;;
            'q') # Quit
                tput clear
                # Restore the original theme
                omp_set "$original_theme_name"
                echo "Theme selection cancelled."
                break
                ;;
        esac
    done
}

autoload -Uz compinit
compinit
_omp_set_completion() {
	local -a themes
	themes=(${(f)"$(find "$OMP_THEMES" -name '*.omp.json' -exec basename {} .omp.json \;)"})
	compadd -a themes
}

compdef _omp_set_completion omp_set
compdef _omp_set_completion omp_show
