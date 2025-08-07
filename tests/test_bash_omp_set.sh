#!/usr/bin/env bash
# Test for omp_set function in bash script
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

# Ensure we're using the correct bash version
if [[ -n "$(brew --prefix bash 2>/dev/null)" ]]; then
    BREW_BASH="$(brew --prefix bash)/bin/bash"
    if [[ -x "$BREW_BASH" ]]; then
        # Re-execute with Homebrew bash if we're not already using it
        if [[ "$BASH_VERSION" != "5."* ]]; then
            exec "$BREW_BASH" "$0" "$@"
        fi
    fi
fi

# Load the script
source ./dot-oh-my-posh.bash

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
        echo "PASS: omp_set"
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
        echo "FAIL: omp_set"
        exit 1
    fi
else
    if [[ "$VERBOSE" == "true" ]]; then
        echo "✗ omp_set returned no output"
    fi
    echo "FAIL: omp_set"
    exit 1
fi 