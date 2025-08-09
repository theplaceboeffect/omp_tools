#!/bin/zsh
# Test for omp_env function in zsh script
# This test verifies that omp_env displays environment information

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

# Test omp_env function
if [[ "$VERBOSE" == "true" ]]; then
    echo "Testing omp_env function..." 
fi

# Capture the output of omp_env
output=$(omp_env)

# Verify that output is not empty and contains expected patterns
if [[ -n "$output" ]]; then
    # Check for expected patterns in output
    env_header_pattern="=== OH-MY-POSH ENVIRONMENT ==="
    os_pattern="Operating System:"
    shell_pattern="Shell:"
    install_dir_pattern="oh-my-posh Install Dir:"
    
    has_env_header=$(echo "$output" | grep "$env_header_pattern")
    has_os=$(echo "$output" | grep "$os_pattern")
    has_shell=$(echo "$output" | grep "$shell_pattern")
    has_install_dir=$(echo "$output" | grep "$install_dir_pattern")
    
    # All patterns must be present for the test to pass
    if [[ -n "$has_env_header" && -n "$has_os" && -n "$has_shell" && -n "$has_install_dir" ]]; then
        if [[ "$VERBOSE" == "true" ]]; then
            echo "✓ omp_env returned output"
            echo "✓ Found environment header"
            echo "✓ Found Operating System info"
            echo "✓ Found Shell info"
            echo "✓ Found Install Directory info"
            
            # Display the output
            echo "omp_env output:"
            echo "$output" | while read -r line; do
                echo "  $line"
            done
        fi
        echo "PASS: omp_env (zsh)"
    else
        if [[ "$VERBOSE" == "true" ]]; then
            echo "✓ omp_env returned output"
            
            if [[ -n "$has_env_header" ]]; then
                echo "✓ Found environment header"
            else
                echo "✗ Environment header not found"
            fi
            
            if [[ -n "$has_os" ]]; then
                echo "✓ Found Operating System info"
            else
                echo "✗ Operating System info not found"
            fi
            
            if [[ -n "$has_shell" ]]; then
                echo "✓ Found Shell info"
            else
                echo "✗ Shell info not found"
            fi
            
            if [[ -n "$has_install_dir" ]]; then
                echo "✓ Found Install Directory info"
            else
                echo "✗ Install Directory info not found"
            fi
            
            # Display the output
            echo "omp_env output:"
            echo "$output" | while read -r line; do
                echo "  $line"
            done
        fi
        echo "FAIL: omp_env (zsh)"
        exit 1
    fi
else
    if [[ "$VERBOSE" == "true" ]]; then
        echo "✗ omp_env returned no output"
    fi
    echo "FAIL: omp_env (zsh)"
    exit 1
fi 