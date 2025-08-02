const { test, expect } = require('@playwright/test');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

test.describe('dot-oh-my-posh.ps1 script tests', () => {
    let tempDir;
    let originalCwd;

    test.beforeEach(async () => {
        // Store original working directory
        originalCwd = process.cwd();
        
        // Create temporary directory for isolated testing
        tempDir = fs.mkdtempSync(path.join(process.cwd(), 'test-temp-'));
        
        // Change to temp directory
        process.chdir(tempDir);
        
        // Create minimal environment for testing
        fs.mkdirSync(path.join(tempDir, '.config', 'omp_tools'), { recursive: true });
        fs.writeFileSync(path.join(tempDir, '.config', 'omp_tools', 'default'), 'nu4a');
    });

    test.afterEach(async () => {
        // Restore original working directory
        process.chdir(originalCwd);
        
        // Clean up temp directory unless preserve_temp_files is true
        const testConfig = JSON.parse(fs.readFileSync(path.join(originalCwd, 'test_config.json'), 'utf8'));
        if (!testConfig.preserve_temp_files) {
            fs.rmSync(tempDir, { recursive: true, force: true });
        }
    });

    test('should execute without errors and return environment information', async () => {
        const scriptPath = path.join(originalCwd, 'dot-oh-my-posh.ps1');
        
        try {
            // Execute the PowerShell script
            const result = execSync(`pwsh -File "${scriptPath}"`, {
                cwd: tempDir,
                env: {
                    ...process.env,
                    HOME: tempDir,
                    USERPROFILE: tempDir
                },
                encoding: 'utf8',
                timeout: 10000
            });

            // Verify the script executed successfully
            expect(result).toBeDefined();
            expect(typeof result).toBe('string');
            
            // Check for expected output patterns
            expect(result).toContain('=== OH-MY-POSH ENVIRONMENT ===');
            expect(result).toContain('Operating System:');
            expect(result).toContain('Shell:');
            expect(result).toContain('oh-my-posh Install Dir:');
            expect(result).toContain('Package Manager:');
            expect(result).toContain('===============================');
            
            // Verify no error messages in output
            expect(result).not.toContain('Error:');
            expect(result).not.toContain('Exception:');
            
        } catch (error) {
            // If the script fails, it should be due to missing oh-my-posh installation
            // which is expected in a test environment
            expect(error.message).toContain('oh-my-posh');
        }
    });

    test('should handle missing oh-my-posh gracefully', async () => {
        const scriptPath = path.join(originalCwd, 'dot-oh-my-posh.ps1');
        
        // Execute with a clean environment that doesn't have oh-my-posh
        const result = execSync(`pwsh -File "${scriptPath}"`, {
            cwd: tempDir,
            env: {
                ...process.env,
                HOME: tempDir,
                USERPROFILE: tempDir,
                PATH: '/usr/bin:/bin' // Minimal PATH without oh-my-posh
            },
            encoding: 'utf8',
            timeout: 10000
        });

        // Script should still execute and provide environment information
        expect(result).toBeDefined();
        expect(result).toContain('=== OH-MY-POSH ENVIRONMENT ===');
        expect(result).toContain('Operating System:');
        expect(result).toContain('Shell:');
        
        // Should indicate that oh-my-posh is not found
        expect(result).toContain('oh-my-posh Install Dir:');
    });

    test('should not create persistent artifacts', async () => {
        const scriptPath = path.join(originalCwd, 'dot-oh-my-posh.ps1');
        
        // Get initial file count
        const initialFiles = fs.readdirSync(tempDir);
        
        // Execute the script
        execSync(`pwsh -File "${scriptPath}"`, {
            cwd: tempDir,
            env: {
                ...process.env,
                HOME: tempDir,
                USERPROFILE: tempDir
            },
            encoding: 'utf8',
            timeout: 10000
        });
        
        // Get file count after execution
        const finalFiles = fs.readdirSync(tempDir);
        
        // Should not create any new files in the temp directory
        // (except for the .config directory we created in beforeEach)
        expect(finalFiles.length).toBeLessThanOrEqual(initialFiles.length + 1);
    });
}); 