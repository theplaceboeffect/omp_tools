# Oh-My-Posh Tools Testing Framework

Testing framework for the oh-my-posh tools scripts.

## Quick Start

1. Initialize test environment:
   ```powershell
   ./bin/test_init.ps1 -BranchName "feature-branch"
   ```

2. Run tests:
   ```powershell
   cd tests/<branch>/bin
   ./run_tests.ps1
   ```

## Test Categories

- **Script Loading**: Verify scripts load without errors
- **Function Existence**: Test all expected functions are available
- **Invalid Arguments**: Test error handling
- **Cross-Platform**: Test compatibility across platforms

## Directory Structure

```
tests/
├── bin/                    # Common utilities
├── <branch>/              # Branch-specific data
│   ├── bin/               # Test scripts
│   ├── test/              # Test artifacts
│   └── test_config.json   # Configuration
└── README.md              # This file
```

## Test Utilities

- `Import-OmpToolsPS1`: Load and mock scripts
- `Test-FunctionExists`: Verify functions exist
- `Mock-OhMyPosh`: Simulate oh-my-posh commands
- `New-TestEnvironment`: Create isolated test environments 