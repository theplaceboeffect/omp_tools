#!/bin/bash
# Test for omp_help function in bash script
# This test verifies that omp_help displays a standard help message

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
source ./dot-oh-my-posh.bash

# Test omp_help function
if [[ "$VERBOSE" == "true" ]]; then
    echo "Testing omp_help function..." 
fi

# Capture the output of omp_help
output=$(omp_help)

# Verify that output is not empty and contains expected patterns
if [[ -n "$output" ]]; then
    # Check for expected patterns in output
    help_header_pattern="=== OH-MY-POSH TOOLS HELP ==="
    usage_pattern="Usage:"
    options_pattern="Options:"
    functions_pattern="Functions:"
    
    has_help_header=$(echo "$output" | grep "$help_header_pattern")
    has_usage=$(echo "$output" | grep "$usage_pattern")
    has_options=$(echo "$output" | grep "$options_pattern")
    has_functions=$(echo "$output" | grep "$functions_pattern")
    
    # All patterns must be present for the test to pass
    if [[ -n "$has_help_header" && -n "$has_usage" && -n "$has_options" && -n "$has_functions" ]]; then
        if [[ "$VERBOSE" == "true" ]]; then
            echo "✓ omp_help returned output"
            echo "✓ Found help header"
            echo "✓ Found usage section"
            echo "✓ Found options section"
            echo "✓ Found functions section"
            
            # Display the output
            echo "omp_help output:"
            echo "$output" | while read -r line; do
                echo "  $line"
            done
        fi
        echo "PASS: omp_help"
    else
        if [[ "$VERBOSE" == "true" ]]; then
            echo "✓ omp_help returned output"
            
            if [[ -n "$has_help_header" ]]; then
                echo "✓ Found help header"
            else
                echo "✗ Help header not found"
            fi
            
            if [[ -n "$has_usage" ]]; then
                echo "✓ Found usage section"
            else
                echo "✗ Usage section not found"
            fi
            
            if [[ -n "$has_options" ]]; then
                echo "✓ Found options section"
            else
                echo "✗ Options section not found"
            fi
            
            if [[ -n "$has_functions" ]]; then
                echo "✓ Found functions section"
            else
                echo "✗ Functions section not found"
            fi
            
            # Display the output
            echo "omp_help output:"
            echo "$output" | while read -r line; do
                echo "  $line"
            done
        fi
        echo "FAIL: omp_help"
        exit 1
    fi
else
    if [[ "$VERBOSE" == "true" ]]; then
        echo "✗ omp_help returned no output"
    fi
    echo "FAIL: omp_help"
    exit 1
fi 