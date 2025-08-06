# Oh-My-Posh Tools Test Suite

This directory contains comprehensive tests for all versions of the oh-my-posh-tools scripts.

## Test Structure

### Script Versions Tested
- **PowerShell**: `dot-oh-my-posh.ps1`
- **Zsh**: `dot-oh-my-posh.zsh`
- **Bash**: `dot-oh-my-posh.bash`

### Functions Tested
Each script version has tests for the following functions:

1. **omp_ls** - Lists available themes
   - Verifies output is not empty
   - Checks for `.omp.json` theme files
   - Displays sample themes found

2. **omp_set** - Shows current and default themes
   - Verifies output contains "Current theme:" and "Default theme:"
   - Displays the actual output for verification

3. **omp_help** - Displays help information
   - Checks for help header "=== OH-MY-POSH TOOLS HELP ==="
   - Verifies presence of Usage, Options, and Functions sections
   - Displays the help output

4. **omp_envs** - Shows environment information
   - Checks for environment header "=== OH-MY-POSH ENVIRONMENT ==="
   - Verifies Operating System, Shell, and Install Directory information
   - Displays the environment output

## Test Files

### PowerShell Tests
- `test_ps1_omp_ls.ps1` - Tests omp_ls function
- `test_ps1_omp_set.ps1` - Tests omp_set function
- `test_ps1_omp_help.ps1` - Tests omp_help function
- `test_ps1_omp_envs.ps1` - Tests omp_env function

### Zsh Tests
- `test_zsh_omp_ls.sh` - Tests omp_ls function
- `test_zsh_omp_set.sh` - Tests omp_set function
- `test_zsh_omp_help.sh` - Tests omp_help function
- `test_zsh_omp_envs.sh` - Tests omp_env function

### Bash Tests
- `test_bash_omp_ls.sh` - Tests omp_ls function
- `test_bash_omp_set.sh` - Tests omp_set function
- `test_bash_omp_help.sh` - Tests omp_help function
- `test_bash_omp_envs.sh` - Tests omp_env function

## Running Tests

### Quiet Mode (Default)
Tests run silently and only show PASS/FAIL results:

```bash
# Run all tests quietly
./tests/run_all_tests.sh

# Run individual tests quietly
pwsh -ExecutionPolicy Bypass -File tests/test_ps1_omp_help.ps1
zsh tests/test_zsh_omp_help.sh
bash tests/test_bash_omp_help.sh
```

### Verbose Mode
Use `--verbose` flag to see detailed test output:

```bash
# Run all tests with verbose output
./tests/run_all_tests.sh --verbose

# Run individual tests with verbose output
pwsh -ExecutionPolicy Bypass -File tests/test_ps1_omp_help.ps1 -Verbose
zsh tests/test_zsh_omp_help.sh --verbose
bash tests/test_bash_omp_help.sh --verbose
```

### Run All Tests
```bash
# Quiet mode (default)
./tests/run_all_tests.sh

# Verbose mode
./tests/run_all_tests.sh --verbose
```

### Run Individual Tests

#### PowerShell Tests
```bash
# Quiet mode
pwsh -ExecutionPolicy Bypass -File tests/test_ps1_omp_ls.ps1
pwsh -ExecutionPolicy Bypass -File tests/test_ps1_omp_set.ps1
pwsh -ExecutionPolicy Bypass -File tests/test_ps1_omp_help.ps1
pwsh -ExecutionPolicy Bypass -File tests/test_ps1_omp_envs.ps1

# Verbose mode
pwsh -ExecutionPolicy Bypass -File tests/test_ps1_omp_ls.ps1 -Verbose
pwsh -ExecutionPolicy Bypass -File tests/test_ps1_omp_set.ps1 -Verbose
pwsh -ExecutionPolicy Bypass -File tests/test_ps1_omp_help.ps1 -Verbose
pwsh -ExecutionPolicy Bypass -File tests/test_ps1_omp_envs.ps1 -Verbose
```

#### Zsh Tests
```bash
# Quiet mode
zsh tests/test_zsh_omp_ls.sh
zsh tests/test_zsh_omp_set.sh
zsh tests/test_zsh_omp_help.sh
zsh tests/test_zsh_omp_envs.sh

# Verbose mode
zsh tests/test_zsh_omp_ls.sh --verbose
zsh tests/test_zsh_omp_set.sh --verbose
zsh tests/test_zsh_omp_help.sh --verbose
zsh tests/test_zsh_omp_envs.sh --verbose
```

#### Bash Tests
```bash
# Quiet mode
bash tests/test_bash_omp_ls.sh
bash tests/test_bash_omp_set.sh
bash tests/test_bash_omp_help.sh
bash tests/test_bash_omp_envs.sh

# Verbose mode
bash tests/test_bash_omp_ls.sh --verbose
bash tests/test_bash_omp_set.sh --verbose
bash tests/test_bash_omp_help.sh --verbose
bash tests/test_bash_omp_envs.sh --verbose
```

## Test Output

### Quiet Mode Output
```
PASS: omp_ls
PASS: omp_set
PASS: omp_help
PASS: omp_env
```

### Verbose Mode Output
Each test provides:
- ✅ Success indicators for passed checks
- ❌ Error indicators for failed checks
- ⚠️ Warning indicators for potential issues
- Detailed output from the functions being tested

## Requirements

- **PowerShell 7+** for PowerShell tests
- **Zsh** for zsh tests
- **Bash** for bash tests
- **oh-my-posh** installed and accessible

## Notes

- Tests account for different environments having different values
- Tests check for non-variable text patterns that should be consistent
- All test files are executable and can be run independently
- The test suite provides comprehensive coverage of all major functions
- Tests exit with code 1 on failure for CI/CD integration 