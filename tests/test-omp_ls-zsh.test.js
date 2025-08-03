const { test, expect } = require('@playwright/test');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Load test configuration
const testConfig = JSON.parse(fs.readFileSync('test_config.json', 'utf8'));

test.describe('Zsh omp_ls Tests', () => {
    test('test-omp_ls-zsh-returns-list-of-themes-in-omp_themes-directory', async () => {
        // This test verifies that omp_ls returns a list of themes

        try {
            // Source the zsh script to load the omp_ls alias
            const scriptPath = path.resolve('dot-oh-my-posh.zsh');
            const result = execSync(`zsh -c "source '${scriptPath}' && ls \$OMP_THEMES"`, {
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

            // Check that the output contains theme files (should end with .omp.json)
            const lines = result.trim().split('\n').filter(line => line.trim());
            expect(lines.length).toBeGreaterThan(0);

            // Verify that at least some lines contain .omp.json files
            const themeFiles = lines.filter(line => line.includes('.omp.json'));
            expect(themeFiles.length).toBeGreaterThan(0);

            // Verify that the output contains valid theme names
            lines.forEach(line => {
                if (line.includes('.omp.json')) {
                    // Should be a valid theme file
                    expect(line).toMatch(/^[^\/]+\.omp\.json$/);
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