#!/bin/zsh
# Test for omp_set function in zsh script
# This test verifies that omp_set shows current and default themes

# Parse command line arguments
VERBOSE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Load the script
source ./dot-oh-my-posh.zsh

# Test omp_set function
if [[ "$VERBOSE" == "true" ]]; then
    echo "Testing omp_set function..." 
fi

# Capture the output of omp_set (without arguments)
output=$(omp_set)

# Verify that output is not empty and contains expected patterns
if [[ -n "$output" ]]; then
    # Check for expected patterns in output
    current_theme_pattern="Current theme:"
    default_theme_pattern="Default theme:"
    
    has_current_theme=$(echo "$output" | grep "$current_theme_pattern")
    has_default_theme=$(echo "$output" | grep "$default_theme_pattern")
    
    # Both patterns must be present for the test to pass
    if [[ -n "$has_current_theme" && -n "$has_default_theme" ]]; then
        if [[ "$VERBOSE" == "true" ]]; then
            echo "✓ omp_set returned output"
            echo "✓ Found 'Current theme:' in output"
            echo "✓ Found 'Default theme:' in output"
            
            # Display the output
            echo "omp_set output:"
            echo "$output" | while read -r line; do
                echo "  $line"
            done
        fi
        echo "PASS: omp_set (zsh)"
    else
        if [[ "$VERBOSE" == "true" ]]; then
            echo "✓ omp_set returned output"
            
            if [[ -n "$has_current_theme" ]]; then
                echo "✓ Found 'Current theme:' in output"
            else
                echo "✗ 'Current theme:' not found in output"
            fi
            
            if [[ -n "$has_default_theme" ]]; then
                echo "✓ Found 'Default theme:' in output"
            else
                echo "✗ 'Default theme:' not found in output"
            fi
            
            # Display the output
            echo "omp_set output:"
            echo "$output" | while read -r line; do
                echo "  $line"
            done
        fi
        echo "FAIL: omp_set (zsh)"
        exit 1
    fi
else
    if [[ "$VERBOSE" == "true" ]]; then
        echo "✗ omp_set returned no output"
    fi
    echo "FAIL: omp_set (zsh)"
    exit 1
fi 