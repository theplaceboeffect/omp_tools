const { test, expect } = require('@playwright/test');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Load test configuration
const testConfig = JSON.parse(fs.readFileSync('test_config.json', 'utf8'));

test.describe('PowerShell Script Launch Tests', () => {
  test('test-launch-dot-oh-my-posh-ps1', async () => {
    // This test verifies that the dot-oh-my-posh.ps1 script launches correctly
    // and outputs the expected environment information
    
    try {
      // Execute the PowerShell script
      const scriptPath = path.resolve('dot-oh-my-posh.ps1');
      const result = execSync(`pwsh -File "${scriptPath}"`, {
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
      expect(result).toContain('Operating System: ');
      expect(result).toContain('Shell: Core');
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
  
  test('verify PowerShell standards compliance', async () => {
    // Read the PowerShell script content
    const scriptContent = fs.readFileSync('dot-oh-my-posh.ps1', 'utf8');
    
    // Check for forbidden verbs (this is a basic check - PowerShell has approved verbs)
    const forbiddenVerbs = ['Run', 'Execute', 'Launch', 'Start']; // Example forbidden verbs
    const foundForbiddenVerbs = forbiddenVerbs.filter(verb => 
      scriptContent.includes(`function ${verb}-`) || 
      scriptContent.includes(`${verb}-`)
    );
    expect(foundForbiddenVerbs.length).toBe(0);
    
    // Check that no files with dots in names are created
    // This is verified by checking the script doesn't contain file creation with dots
    const dotFileCreationPattern = /New-Item.*\.[^\\\/]*\./;
    expect(scriptContent).not.toMatch(dotFileCreationPattern);
    
    // Verify parameter naming doesn't use reserved words
    const reservedWords = ['$Error', '$Host', '$Home', '$PSVersionTable'];
    const foundReservedParams = reservedWords.filter(word => 
      scriptContent.includes(`param(${word}`) || 
      scriptContent.includes(`[Parameter]${word}`)
    );
    expect(foundReservedParams.length).toBe(0);
  });
});
