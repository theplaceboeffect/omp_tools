const { test, expect } = require('@playwright/test');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Load test configuration
const testConfig = JSON.parse(fs.readFileSync('test_config.json', 'utf8'));

test.describe('PowerShell omp_ls Tests', () => {
  test('test-omp_ls-ps1-returns-list-of-themes-in-omp_themes-directory', async () => {
    // This test verifies that omp_ls returns a list of themes in PowerShell
    
    try {
      // Execute the PowerShell script and call omp_ls function
      const scriptPath = path.resolve('dot-oh-my-posh.ps1');
      const result = execSync(`pwsh -ExecutionPolicy Bypass -Command "& '${scriptPath}'; omp_ls"`, {
        encoding: 'utf8',
        timeout: 30000, // 30 second timeout
        cwd: process.cwd(),
        env: {
          ...process.env,
          // Ensure we have the required environment variables
          OMP_THEMES: process.env.OMP_THEMES || '/opt/homebrew/opt/oh-my-posh/themes'
        }
      });
      
      // Verify the script executed successfully (no exception thrown)
      expect(result).toBeDefined();
      
      // Check that the output contains theme names (PowerShell returns names without .omp.json extension)
      const lines = result.trim().split('\n').filter(line => line.trim());
      expect(lines.length).toBeGreaterThan(0);
      
      // Filter out the environment header lines and get only theme names
      const themeLines = lines.filter(line => 
        line.trim() && 
        !line.includes('=== OH-MY-POSH ENVIRONMENT ===') &&
        !line.includes('Operating System:') &&
        !line.includes('Shell:') &&
        !line.includes('oh-my-posh Install Dir:') &&
        !line.includes('Package Manager:') &&
        !line.includes('===============================')
      );
      
      expect(themeLines.length).toBeGreaterThan(0);
      
      // Verify that the output contains valid theme names (no .omp.json extension in PowerShell)
      themeLines.forEach(line => {
        if (line.trim()) {
          // Should be a valid theme name without extension
          expect(line.trim()).toMatch(/^[a-zA-Z0-9._-]+$/);
        }
      });
      
    } catch (error) {
      // If the script fails, provide detailed error information
      console.error('Script execution failed:', error.message);
      console.error('stdout:', error.stdout?.toString());
      console.error('stderr:', error.stderr?.toString());
      throw error;
    }
  });
}); 