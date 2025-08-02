#!/usr/bin/env pwsh

# Playwright initialization script for oh-my-posh-tools project
# This script sets up Playwright testing infrastructure

param(
    [switch]$Force
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "Initializing Playwright for oh-my-posh-tools project..." -ForegroundColor Green

# Check if we're in the project root
if (-not (Test-Path "README.md")) {
    Write-Error "This script must be run from the project root directory"
    exit 1
}

# Check if package.json already exists
if (Test-Path "package.json") {
    if (-not $Force) {
        Write-Warning "package.json already exists. Use -Force to overwrite."
        exit 1
    }
    Write-Host "Removing existing package.json..." -ForegroundColor Yellow
    Remove-Item "package.json" -Force
}

# Initialize npm project
Write-Host "Initializing npm project..." -ForegroundColor Cyan
npm init -y

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to initialize npm project"
    exit 1
}

# Install Playwright
Write-Host "Installing Playwright..." -ForegroundColor Cyan
npm install --save-dev @playwright/test

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to install Playwright"
    exit 1
}

# Install Playwright browsers (only Chromium as specified)
Write-Host "Installing Playwright browsers (Chromium only)..." -ForegroundColor Cyan
npx playwright install chromium

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to install Playwright browsers"
    exit 1
}

# Create playwright.config.js
Write-Host "Creating Playwright configuration..." -ForegroundColor Cyan
$playwrightConfig = @"
const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
"@

$playwrightConfig | Out-File -FilePath "playwright.config.js" -Encoding UTF8

# Create tests directory
if (-not (Test-Path "tests")) {
    New-Item -ItemType Directory -Path "tests" | Out-Null
    Write-Host "Created tests directory" -ForegroundColor Green
}

# Verify the setup worked correctly
Write-Host "Verifying setup..." -ForegroundColor Cyan

$requiredFiles = @("package.json", "package-lock.json", "node_modules")
$missingFiles = @()

foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Error "Setup verification failed. Missing files: $($missingFiles -join ', ')"
    exit 1
}

Write-Host "Playwright initialization completed successfully!" -ForegroundColor Green
Write-Host "Required files verified:" -ForegroundColor Green
foreach ($file in $requiredFiles) {
    Write-Host "  ✓ $file" -ForegroundColor Green
} 