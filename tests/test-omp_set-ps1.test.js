const { test, expect } = require('@playwright/test');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Load test configuration
const testConfig = JSON.parse(fs.readFileSync('test_config.json', 'utf8'));

test.describe('PowerShell omp_set Tests', () => {
  test('test-omp_set-ps1-returns-current-and-default-theme', async () => {
    // This test verifies that omp_set returns the current and default theme when called without parameters
    
    try {
      // Execute the PowerShell script and call omp_set function
      const scriptPath = path.resolve('dot-oh-my-posh.ps1');
      const result = execSync(`pwsh -ExecutionPolicy Bypass -Command "& '${scriptPath}'; omp_set"`, {
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
      
      // Filter out the environment header lines and get only the omp_set output
      const lines = result.trim().split('\n').filter(line => line.trim());
      const outputLines = lines.filter(line => 
        line.trim() && 
        !line.includes('=== OH-MY-POSH ENVIRONMENT ===') &&
        !line.includes('Operating System:') &&
        !line.includes('Shell:') &&
        !line.includes('oh-my-posh Install Dir:') &&
        !line.includes('Package Manager:') &&
        !line.includes('===============================')
      );
      
      // Check that the output contains the expected format
      expect(outputLines.some(line => line.includes('Current theme:'))).toBe(true);
      expect(outputLines.some(line => line.includes('Default theme:'))).toBe(true);
      
      // Parse the output to extract theme names
      const currentThemeLine = outputLines.find(line => line.includes('Current theme:'));
      const defaultThemeLine = outputLines.find(line => line.includes('Default theme:'));
      
      expect(currentThemeLine).toBeDefined();
      expect(defaultThemeLine).toBeDefined();
      
      // Extract theme names
      const currentTheme = currentThemeLine.split(':')[1].trim();
      const defaultTheme = defaultThemeLine.split(':')[1].trim();
      
      // Verify that theme names are not empty
      expect(currentTheme).toBeTruthy();
      expect(defaultTheme).toBeTruthy();
      
      // Verify that theme names are valid (alphanumeric, dots, hyphens, underscores)
      expect(currentTheme).toMatch(/^[a-zA-Z0-9._-]+$/);
      expect(defaultTheme).toMatch(/^[a-zA-Z0-9._-]+$/);
      
    } catch (error) {
      // If the script fails, provide detailed error information
      console.error('Script execution failed:', error.message);
      console.error('stdout:', error.stdout?.toString());
      console.error('stderr:', error.stderr?.toString());
      throw error;
    }
  });

  test('test-omp_set-ps1-sets-theme-to-specified-theme', async () => {
    // This test verifies that omp_set sets the theme to the specified theme
    
    try {
      // Execute the PowerShell script and call omp_set function
      const scriptPath = path.resolve('dot-oh-my-posh.ps1');
      
      // Set theme to a specific theme and verify in the same session
      const testTheme = 'agnoster'; // Using a common theme that should exist
      const result = execSync(`pwsh -ExecutionPolicy Bypass -Command "& '${scriptPath}'; omp_set ${testTheme}; omp_set"`, {
        encoding: 'utf8',
        timeout: 30000,
        cwd: process.cwd(),
        env: {
          ...process.env,
          OMP_THEMES: process.env.OMP_THEMES || '/opt/homebrew/opt/oh-my-posh/themes'
        }
      });
      
      // Filter out the environment header lines and get only the omp_set output
      const lines = result.trim().split('\n').filter(line => line.trim());
      const outputLines = lines.filter(line => 
        line.trim() && 
        !line.includes('=== OH-MY-POSH ENVIRONMENT ===') &&
        !line.includes('Operating System:') &&
        !line.includes('Shell:') &&
        !line.includes('oh-my-posh Install Dir:') &&
        !line.includes('Package Manager:') &&
        !line.includes('===============================')
      );
      
      // Verify that the set command output contains the expected message
      expect(outputLines.some(line => line.includes(`Setting theme to ${testTheme}`))).toBe(true);
      
      // Parse the output to extract theme information
      const currentThemeLine = outputLines.find(line => line.includes('Current theme:'));
      const defaultThemeLine = outputLines.find(line => line.includes('Default theme:'));
      
      expect(currentThemeLine).toBeDefined();
      expect(defaultThemeLine).toBeDefined();
      
      // Extract theme names
      const currentTheme = currentThemeLine.split(':')[1].trim();
      const defaultTheme = defaultThemeLine.split(':')[1].trim();
      
      // Verify that the current theme was set to the specified theme
      // PowerShell includes .omp extension in theme names
      expect(currentTheme).toBe(`${testTheme}.omp`);
      
      // Verify that the current theme differs from the default theme (as expected)
      expect(currentTheme).not.toBe(defaultTheme);
      
    } catch (error) {
      // If the script fails, provide detailed error information
      console.error('Script execution failed:', error.message);
      console.error('stdout:', error.stdout?.toString());
      console.error('stderr:', error.stderr?.toString());
      throw error;
    }
  });
}); 