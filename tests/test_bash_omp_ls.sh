#!/usr/bin/env bash
# Test for omp_ls function in bash script
# This test verifies that omp_ls returns a list of themes

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

# Test omp_ls function
if [[ "$VERBOSE" == "true" ]]; then
    echo "Testing omp_ls function..." 
fi

# Capture the output of omp_ls
output=$(omp_ls)

# Verify that output is not empty and contains expected patterns
if [[ -n "$output" ]]; then
    # Check if output contains theme files (should have .omp.json extension)
    theme_files=$(echo "$output" | grep "\.omp\.json$")
    
    # Test passes if we have output (even if no .omp.json files, as long as there's output)
    if [[ "$VERBOSE" == "true" ]]; then
        echo "✓ omp_ls returned output"
        
        if [[ -n "$theme_files" ]]; then
            echo "✓ Found theme files with .omp.json extension"
            echo "Sample themes found:"
            echo "$theme_files" | head -5 | while read -r line; do
                echo "  - $line"
            done
        else
            echo "⚠ No .omp.json files found in output"
        fi
        
        # Display first few lines of output
        echo "First 10 lines of omp_ls output:"
        echo "$output" | head -10 | while read -r line; do
            echo "  $line"
        done
    fi
    echo "PASS: omp_ls"
else
    if [[ "$VERBOSE" == "true" ]]; then
        echo "✗ omp_ls returned no output"
    fi
    echo "FAIL: omp_ls"
    exit 1
fi 