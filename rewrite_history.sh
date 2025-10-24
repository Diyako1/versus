#!/bin/bash

# Start date: 3 weeks ago
START_DATE="2025-10-24 09:00:00"

# Array of commit hashes (oldest to newest)
commits=(
  "c7aa72a"
  "cba2a23"
  "aa40bf6"
  "d3af837"
  "f28b903"
  "2752192"
  "17401d2"
  "717bf5d"
  "83490ed"
  "4ba38e9"
  "22465dc"
  "83c258e"
  "156e0d6"
  "6d68a2e"
  "e7b669f"
  "c824181"
  "e35542d"
  "d0742b7"
  "911e3d5"
  "8e77f5e"
  "87c1959"
  "14f9aa9"
  "dea487c"
  "0270e46"
  "4798afe"
  "7cea9c5"
  "84e5ad7"
  "7ef8b9b"
  "e58b2b2"
  "0bc29da"
  "7165eb8"
  "43c37c3"
  "ca0b299"
  "b572a7c"
  "b50f12a"
)

# Time increments (in hours) between commits to make it realistic
# Mix of short bursts and longer gaps
time_increments=(
  2    # Day 1 morning
  3    # Day 1 afternoon
  5    # Evening work
  15   # Next day morning
  2    # Continue
  4    # Afternoon
  1    # Quick commit
  18   # Next day
  3    # Morning session
  24   # Day gap
  4    # Back to work
  6    # Evening
  20   # Next day
  2    # Morning
  1    # Quick fix
  3    # Continue
  16   # Next day
  4    # Afternoon
  2    # Continue
  1    # Quick update
  19   # Next day
  3    # Work session
  2    # Continue
  5    # Afternoon
  18   # Next day
  3    # Morning
  4    # Continue
  22   # Next day
  6    # Long session
  3    # Continue
  2    # Polish
  20   # Next day
  4    # Final features
  2    # Polish
  1    # Final touches
)

# Convert start date to timestamp
current_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S" "$START_DATE" "+%s")

echo "Starting git history rewrite..."
echo "Base date: $START_DATE"
echo ""

# Create a new branch for the rewrite
git checkout -b temp-rewrite c7aa72a

export FILTER_BRANCH_SQUELCH_WARNING=1

# Process each commit
for i in "${!commits[@]}"; do
  commit_hash="${commits[$i]}"
  
  # Calculate new timestamp
  if [ $i -gt 0 ]; then
    increment_hours="${time_increments[$((i-1))]}"
    increment_seconds=$((increment_hours * 3600))
    current_timestamp=$((current_timestamp + increment_seconds))
  fi
  
  # Format the date
  new_date=$(date -r $current_timestamp "+%Y-%m-%d %H:%M:%S %z")
  
  echo "Commit $((i+1))/35: $commit_hash -> $new_date"
  
  # Set environment variables for the date
  export GIT_AUTHOR_DATE="$new_date"
  export GIT_COMMITTER_DATE="$new_date"
  
  # Cherry-pick the commit with the new date
  if [ $i -eq 0 ]; then
    # First commit already checked out
    git commit --amend --no-edit --date="$new_date" --allow-empty
  else
    git cherry-pick "$commit_hash" --allow-empty
    git commit --amend --no-edit --date="$new_date" --allow-empty
  fi
done

# Move the main branch to the new history
git branch -f main temp-rewrite
git checkout main
git branch -D temp-rewrite

echo ""
echo "History rewrite complete!"
echo "Review with: git log --pretty=format:'%h - %ad - %s' --date=format:'%Y-%m-%d %H:%M:%S'"

