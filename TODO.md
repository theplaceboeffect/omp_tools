# 🚀 TODO List for Oh-My-Posh Tools Improvements

Based on comprehensive review using latest library documentation for Oh My Posh, PowerShell, and related technologies.

## 🔥 **High Priority (Critical Security & Functionality)**

### 1. **Fix Merge Conflicts & Critical Issues**
- [x] ~~Resolve merge conflict in `dot-oh-my-posh.ps1`~~ ✅ **COMPLETED**
- [ ] Fix bash script loading issue (tests show "command not found")
- [ ] Ensure all scripts have consistent version numbers (v01.10.02)
- [ ] Update version numbers in all scripts before committing

### 2. **Security Improvements**
- [ ] Replace `Invoke-Expression` with safer alternatives in PowerShell
- [ ] Add input validation for theme names in all scripts
- [ ] Implement path sanitization for all file operations
- [ ] Add execution policy handling for PowerShell

### 3. **PowerShell Best Practices**
- [ ] Add `[CmdletBinding()]` attribute to all functions
- [ ] Implement proper parameter validation with `[ValidateScript]`
- [ ] Add pipeline support where appropriate
- [ ] Use strongly-typed parameters instead of generic types

## 🚀 **Medium Priority (Enhanced Functionality)**

### 4. **Modern Oh My Posh Integration**
- [ ] Update to use latest Oh My Posh initialization patterns
- [ ] Implement theme export/import functionality
- [ ] Add image export for theme previews
- [ ] Support transient prompt configuration

### 5. **Configuration Management**
- [ ] Create configuration file support (`~/.oh-my-posh-tools.json`)
- [ ] Allow custom default themes via config
- [ ] Add theme validation against Oh My Posh schema
- [ ] Implement configuration migration for existing users

### 6. **Error Handling & User Experience**
- [ ] Implement structured error handling with proper exit codes
- [ ] Add detailed error messages with troubleshooting hints
- [ ] Create user-friendly error recovery suggestions
- [ ] Add progress indicators for long-running operations

## 📊 **Low Priority (Quality of Life)**

### 7. **Performance Optimizations**
- [ ] Add caching for theme lists and environment detection
- [ ] Implement lazy loading for theme resources
- [ ] Add async operations for interactive features
- [ ] Optimize startup time for scripts

### 8. **Testing & Documentation**
- [ ] Implement Pester tests for PowerShell functions
- [ ] Add integration tests for cross-platform compatibility
- [ ] Create comprehensive user documentation
- [ ] Add inline code documentation

### 9. **Advanced Features**
- [ ] Add custom segment creation support
- [ ] Implement theme backup/restore functionality
- [ ] Add theme sharing capabilities
- [ ] Create theme recommendation system

## 🛠️ **Implementation Order**

### **Phase 1: Critical Fixes (Week 1)**

```bash
# 1. Fix bash script issues
- Investigate why bash tests fail with "command not found"
- Ensure proper script sourcing in bash environment
- Test bash script functionality

# 2. Security improvements
- Replace Invoke-Expression in PowerShell
- Add input validation
- Test security changes

# 3. Update version numbers
- Run update-version.sh
- Verify all scripts have matching versions
```

### **Phase 2: Modern Integration (Week 2)**

```bash
# 1. Update Oh My Posh integration
- Research latest initialization patterns
- Update initialization code
- Test with latest Oh My Posh version

# 2. Add configuration support
- Design configuration file format
- Implement config loading/saving
- Add migration for existing users
```

### **Phase 3: Enhanced Features (Week 3)**

```bash
# 1. Add theme export/import
- Implement theme export functionality
- Add theme import with validation
- Create theme sharing workflow

# 2. Improve error handling
- Add structured error handling
- Create user-friendly error messages
- Implement error recovery
```

### **Phase 4: Testing & Documentation (Week 4)**

```bash
# 1. Implement comprehensive testing
- Add Pester tests for PowerShell
- Create integration test suite
- Set up CI/CD pipeline

# 2. Update documentation
- Write comprehensive user guide
- Add developer documentation
- Create migration guide
```

## 📝 **Specific Code Changes Needed**

### **PowerShell Script (`dot-oh-my-posh.ps1`)**

```powershell
# Add to top of script
[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [ValidateNotNullOrEmpty()]
    [switch]$h,
    
    [Parameter(Position=1)]
    [ValidateNotNullOrEmpty()]
    [switch]$e,
    
    [Parameter(Position=2)]
    [ValidateNotNullOrEmpty()]
    [switch]$v
)

# Replace Invoke-Expression with safer alternative
oh-my-posh init pwsh --config "$themeFile" | Invoke-Expression

# Add configuration file support
$ConfigPath = Join-Path $env:USERPROFILE ".oh-my-posh-tools.json"
```

### **Zsh Script (`dot-oh-my-posh.zsh`)**

```bash
# Add input validation
if [[ -z "$theme" ]]; then
    echo "Error: Theme name is required"
    return 1
fi

# Add configuration file support
CONFIG_FILE="$HOME/.oh-my-posh-tools.json"
```

### **Bash Script (`dot-oh-my-posh.bash`)**

```bash
# Fix script loading issues
# Ensure proper function export
export -f omp_ls omp_set omp_show omp_help omp_env

# Add configuration file support
CONFIG_FILE="$HOME/.oh-my-posh-tools.json"
```

## 🎯 **Success Metrics**

- [ ] All tests pass (PowerShell, Zsh, Bash)
- [ ] No security vulnerabilities (no `Invoke-Expression`)
- [ ] Proper error handling with meaningful messages
- [ ] Configuration file support working
- [ ] Modern Oh My Posh integration
- [ ] Comprehensive test coverage (>80%)
- [ ] User documentation complete

## 📅 **Timeline Estimate**

- **Phase 1**: 1 week (Critical fixes)
- **Phase 2**: 1 week (Modern integration)
- **Phase 3**: 1 week (Enhanced features)
- **Phase 4**: 1 week (Testing & documentation)

**Total Estimated Time**: 4 weeks for complete implementation

## 📋 **Quick Start Commands**

```bash
# Update version numbers
./update-version.sh

# Run all tests
./tests/run_all_tests.sh

# Run tests with verbose output
./tests/run_all_tests.sh --verbose

# Test individual scripts
pwsh -ExecutionPolicy Bypass -File tests/test_ps1_omp_help.ps1
zsh tests/test_zsh_omp_help.sh
$(brew --prefix bash)/bin/bash tests/test_bash_omp_help.sh
```

---

**Last Updated**: $(date)
**Based on**: Latest Oh My Posh, PowerShell, and shell scripting best practices
**Priority**: Security > Functionality > Performance > Documentation
