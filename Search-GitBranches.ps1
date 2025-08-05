param (
    [Parameter(Mandatory = $true)]
    [string]$Search,

    [string]$File
)

# Save current branch to restore later
$currentBranch = git rev-parse --abbrev-ref HEAD

# Fetch all remotes quietly
git fetch --all --quiet

# Get all remote branches (excluding HEAD pointer)
$branches = git branch -r | Where-Object { $_ -notmatch '->' }

foreach ($branch in $branches) {
    $branchName = $branch.Trim()

    # Checkout in detached HEAD quietly
    git checkout --detach $branchName --quiet 2>$null

    # Run git grep
    if ($File) {
        $matches = git grep -n -i -F "$Search" -- "$File"
    } else {
        $matches = git grep -n -i -F "$Search"
    }

    if ($matches) {
        Write-Host "`n🔍 Found in $branchName" -ForegroundColor Green
        $matches | ForEach-Object { Write-Host $_ -ForegroundColor Cyan }
    }
}

# Restore original branch
git checkout $currentBranch --quiet 2>$null
Write-Host "`nRestored branch: $currentBranch"
