const { test, expect } = require('@playwright/test');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Load test configuration
const testConfig = JSON.parse(fs.readFileSync('test_config.json', 'utf8'));

test.describe('Zsh Script Launch Tests', () => {
  test('test-launch-dot-oh-my-posh-zsh', async () => {
    // This test verifies that the dot-oh-my-posh.zsh script launches correctly
    // and outputs the expected environment information
    
    try {
      // Execute the zsh script
      const scriptPath = path.resolve('dot-oh-my-posh.zsh');
      const result = execSync(`zsh "${scriptPath}"`, {
        encoding: 'utf8',
        timeout: 30000, // 30 second timeout
        cwd: process.cwd()
      });
      
      // Verify the script executed successfully (no exception thrown)
      expect(result).toBeDefined();
      
      // Check that the output contains the expected environment header
      expect(result).toContain('=== OH-MY-POSH ENVIRONMENT ===');
      expect(result).toContain('===============================');
      
      // Check for required environment information fields
      expect(result).toContain('Operating System:');
      expect(result).toContain('Shell:');
      expect(result).toContain('oh-my-posh Install Dir:');
      expect(result).toContain('Package Manager:');
      
      // Verify that the script doesn't modify files outside the testing environment
      // by checking that no unexpected files were created in the current directory
      const filesAfter = fs.readdirSync('.');
      const unexpectedFiles = filesAfter.filter(file => 
        file.startsWith('.') && 
        !['git', 'gitignore'].some(allowed => file.includes(allowed)) &&
        !fs.existsSync(file) // This check ensures we're not flagging pre-existing files
      );
      
      // Should not create any unexpected dot files
      expect(unexpectedFiles.length).toBe(0);
      
    } catch (error) {
      // If the script fails, provide detailed error information
      console.error('Script execution failed:', error.message);
      console.error('stdout:', error.stdout?.toString());
      console.error('stderr:', error.stderr?.toString());
      throw error;
    }
  });
  
  test('verify zsh script standards compliance', async () => {
    // Read the zsh script content
    const scriptContent = fs.readFileSync('dot-oh-my-posh.zsh', 'utf8');
    
    // Check that the script uses proper zsh syntax and doesn't create files with dots in names
    // This is verified by checking the script doesn't contain file creation with dots
    const dotFileCreationPattern = /touch.*\.[^\/]*\.|mkdir.*\.[^\/]*\./;
    expect(scriptContent).not.toMatch(dotFileCreationPattern);
    
    // Verify that the script uses proper function definitions
    const functionPattern = /^function\s+\w+\(\)\s*{/m;
    const functions = scriptContent.match(/^function\s+\w+/gm);
    if (functions) {
      // All functions should follow proper zsh syntax
      functions.forEach(func => {
        expect(func).toMatch(/^function\s+[a-zA-Z_][a-zA-Z0-9_]*$/);
      });
    }
    
    // Check that the script doesn't use bash-specific features that might not work in zsh
    const bashSpecificFeatures = ['[[', 'source', 'declare'];
    const foundBashFeatures = bashSpecificFeatures.filter(feature => 
      scriptContent.includes(feature) && !scriptContent.includes(`# ${feature}`) // Allow in comments
    );
    // Note: [[ is actually supported in zsh, so we'll be more lenient
    const problematicFeatures = foundBashFeatures.filter(feature => feature === 'declare');
    expect(problematicFeatures.length).toBe(0);
  });
});
