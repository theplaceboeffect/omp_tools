#!/bin/bash

# Update version numbers in dot-oh-my-posh scripts based on current git branch

# Get current branch name
CURRENT_BRANCH=$(git branch --show-current)

# Check if branch name follows version format
if [[ ! $CURRENT_BRANCH =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Warning: Current branch '$CURRENT_BRANCH' doesn't follow version format (vXX.XX.XX)"
    echo "Version will be set to: v$CURRENT_BRANCH"
    VERSION="v$CURRENT_BRANCH"
else
    VERSION="$CURRENT_BRANCH"
fi

echo "Updating version to: $VERSION"

# Update PowerShell script
if [[ -f "dot-oh-my-posh.ps1" ]]; then
    sed -i '' "s/## Version: v[0-9]\+\.[0-9]\+\.[0-9]\+/## Version: $VERSION/" dot-oh-my-posh.ps1
    sed -i '' "s/Write-Host \"Version: v[0-9]\+\.[0-9]\+\.[0-9]\+\"/Write-Host \"Version: $VERSION\"/" dot-oh-my-posh.ps1
    echo "✓ Updated dot-oh-my-posh.ps1"
else
    echo "✗ dot-oh-my-posh.ps1 not found"
fi

# Update zsh script
if [[ -f "dot-oh-my-posh.zsh" ]]; then
    sed -i '' "s/## Version: v[0-9]\+\.[0-9]\+\.[0-9]\+/## Version: $VERSION/" dot-oh-my-posh.zsh
    sed -i '' "s/echo \"Version: v[0-9]\+\.[0-9]\+\.[0-9]\+\"/echo \"Version: $VERSION\"/" dot-oh-my-posh.zsh
    echo "✓ Updated dot-oh-my-posh.zsh"
else
    echo "✗ dot-oh-my-posh.zsh not found"
fi

echo "Version update complete!" 