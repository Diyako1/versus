#!/bin/bash

# This script rewrites git history with realistic timestamps
# Starting from 3 weeks ago with varied intervals

cd /Users/diyako/Desktop/Versus

# Start from the first commit
git checkout --detach c7aa72a

# Base timestamp: October 24, 2025, 9:00 AM
BASE_TIMESTAMP=1729771200

# Time increments between commits (in hours)
INCREMENTS=(0 2 3 5 15 2 4 1 18 3 24 4 6 20 2 1 3 16 4 2 1 19 3 2 5 18 3 4 22 6 3 2 20 4 2)

# Get all commits in order (oldest first)
COMMITS=($(git log --reverse --pretty=format:"%H" c7aa72a..main))

# Add the first commit
ALL_COMMITS=(c7aa72a "${COMMITS[@]}")

echo "Rewriting ${#ALL_COMMITS[@]} commits with new timestamps..."

TIMESTAMP=$BASE_TIMESTAMP

for i in "${!ALL_COMMITS[@]}"; do
    COMMIT="${ALL_COMMITS[$i]}"
    INCREMENT="${INCREMENTS[$i]}"
    
    # Add increment to timestamp
    TIMESTAMP=$((TIMESTAMP + INCREMENT * 3600))
    
    # Format date for git
    DATE=$(date -r $TIMESTAMP "+%a %b %d %H:%M:%S %Y %z")
    
    echo "[$((i+1))/${#ALL_COMMITS[@]}] Rewriting commit $COMMIT to $DATE"
    
    # Checkout the commit
    git checkout --detach $COMMIT 2>/dev/null
    
    # Amend with new date
    GIT_COMMITTER_DATE="$DATE" git commit --amend --no-edit --date="$DATE" >/dev/null 2>&1
done

# Update main branch to point to the new HEAD
NEW_HEAD=$(git rev-parse HEAD)
git branch -f main $NEW_HEAD
git checkout main

echo ""
echo "✓ History rewrite complete!"
echo ""
echo "To push to GitHub, run:"
echo "  git push -f origin main"

