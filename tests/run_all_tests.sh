#!/bin/zsh
# Comprehensive test runner for oh-my-posh-tools
# This script runs all tests for all script versions

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

if [[ "$VERBOSE" == "true" ]]; then
    echo "=== OH-MY-POSH TOOLS TEST SUITE ==="
    echo "Running tests for all script versions..."
    echo ""
fi

# Function to run a test and report results
run_test() {
    local test_name="$1"
    local test_file="$2"
    local script_type="$3"
    
    if [[ "$VERBOSE" == "true" ]]; then
        echo "Running $test_name for $script_type..."
        echo "----------------------------------------"
    fi
    
    if [[ -f "$test_file" ]]; then
        if [[ "$test_file" == *.ps1 ]]; then
            # Run PowerShell test
            if [[ "$VERBOSE" == "true" ]]; then
                pwsh -ExecutionPolicy Bypass -File "$test_file" -Verbose
            else
                pwsh -ExecutionPolicy Bypass -File "$test_file"
            fi
        else
            # Run shell test
            if [[ "$test_file" == *bash* ]]; then
                # Use bash for bash tests
                if [[ "$VERBOSE" == "true" ]]; then
                    bash "$test_file" --verbose
                else
                    bash "$test_file"
                fi
            else
                # Use zsh for zsh tests
                if [[ "$VERBOSE" == "true" ]]; then
                    zsh "$test_file" --verbose
                else
                    zsh "$test_file"
                fi
            fi
        fi
        if [[ "$VERBOSE" == "true" ]]; then
            echo ""
        fi
    else
        if [[ "$VERBOSE" == "true" ]]; then
            echo "✗ Test file not found: $test_file"
            echo ""
        fi
    fi
}

# Test all PowerShell functions
if [[ "$VERBOSE" == "true" ]]; then
    echo "=== POWERSHELL TESTS ==="
fi
run_test "omp_ls" "tests/test_ps1_omp_ls.ps1" "PowerShell"
run_test "omp_set" "tests/test_ps1_omp_set.ps1" "PowerShell"
run_test "omp_help" "tests/test_ps1_omp_help.ps1" "PowerShell"
run_test "omp_envs" "tests/test_ps1_omp_envs.ps1" "PowerShell"

if [[ "$VERBOSE" == "true" ]]; then
    echo "=== ZSH TESTS ==="
fi
run_test "omp_ls" "tests/test_zsh_omp_ls.sh" "Zsh"
run_test "omp_set" "tests/test_zsh_omp_set.sh" "Zsh"
run_test "omp_help" "tests/test_zsh_omp_help.sh" "Zsh"
run_test "omp_envs" "tests/test_zsh_omp_envs.sh" "Zsh"

if [[ "$VERBOSE" == "true" ]]; then
    echo "=== BASH TESTS ==="
fi
run_test "omp_ls" "tests/test_bash_omp_ls.sh" "Bash"
run_test "omp_set" "tests/test_bash_omp_set.sh" "Bash"
run_test "omp_help" "tests/test_bash_omp_help.sh" "Bash"
run_test "omp_envs" "tests/test_bash_omp_envs.sh" "Bash"

if [[ "$VERBOSE" == "true" ]]; then
    echo "=== TEST SUITE COMPLETED ==="
    echo "All tests have been executed."
    echo "Check the output above for any failures or warnings."
fi 