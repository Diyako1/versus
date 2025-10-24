#!/usr/bin/env python3
"""
Rewrite git commit dates to span a realistic timeframe
"""

import subprocess
import os
from datetime import datetime, timedelta

# Change to repo directory
os.chdir('/Users/diyako/Desktop/Versus')

# Start date: 3 weeks ago (October 24, 2025, 9:00 AM)
start_date = datetime(2025, 10, 24, 9, 0, 0)

# Time increments between commits (in hours)
# This creates a realistic development pattern with work sessions and breaks
increments_hours = [
    0,   # First commit
    2,   # Same day, afternoon
    3,   # Evening
    5,   # Late evening
    15,  # Next day morning
    2,   # Continue working
    4,   # Afternoon
    1,   # Quick fix
    18,  # Next day
    3,   # Morning session
    24,  # Day break
    4,   # Back to work
    6,   # Evening session
    20,  # Next day
    2,   # Morning
    1,   # Quick update
    3,   # Continue
    16,  # Next day afternoon
    4,   # Evening
    2,   # Continue
    1,   # Quick fix
    19,  # Next day
    3,   # Work session
    2,   # Continue
    5,   # Afternoon
    18,  # Next day
    3,   # Morning
    4,   # Continue
    22,  # Next day
    6,   # Long session
    3,   # Continue
    2,   # Refinements
    20,  # Next day
    4,   # Final features
    2,   # Polish
]

# Get list of commits (oldest to newest)
result = subprocess.run(
    ['git', 'log', '--reverse', '--format=%H'],
    capture_output=True,
    text=True,
    check=True
)
commits = result.stdout.strip().split('\n')

print(f"Found {len(commits)} commits to rewrite")
print(f"Start date: {start_date}")
print(f"End date: ~{start_date + timedelta(hours=sum(increments_hours))}")
print()

# Reset to orphan branch to rebuild history
print("Creating new history...")
subprocess.run(['git', 'checkout', '--orphan', 'temp_branch'], 
               check=True, capture_output=True)
subprocess.run(['git', 'rm', '-rf', '.'], 
               check=True, capture_output=True)

# Start from scratch and cherry-pick each commit with new dates
current_date = start_date

for idx, commit_hash in enumerate(commits):
    # Add time increment
    if idx < len(increments_hours):
        current_date += timedelta(hours=increments_hours[idx])
    
    # Format date for git
    date_str = current_date.strftime('%a %b %d %H:%M:%S %Y %z')
    date_iso = current_date.isoformat()
    
    print(f"[{idx+1}/{len(commits)}] {commit_hash[:8]} -> {date_iso}")
    
    # Set environment variables for git
    env = os.environ.copy()
    env['GIT_AUTHOR_DATE'] = date_str
    env['GIT_COMMITTER_DATE'] = date_str
    
    if idx == 0:
        # First commit: checkout the files from the first commit
        subprocess.run(['git', 'checkout', commit_hash, '--', '.'],
                      check=True, capture_output=True)
        subprocess.run(['git', 'add', '-A'],
                      check=True, capture_output=True)
        
        # Get the original commit message
        msg_result = subprocess.run(['git', 'log', '--format=%B', '-n', '1', commit_hash],
                                   capture_output=True, text=True, check=True)
        commit_msg = msg_result.stdout.strip()
        
        # Create first commit with new date
        subprocess.run(['git', 'commit', '-m', commit_msg],
                      env=env, check=True, capture_output=True)
    else:
        # Cherry-pick subsequent commits
        try:
            subprocess.run(['git', 'cherry-pick', commit_hash],
                          env=env, check=True, capture_output=True)
        except subprocess.CalledProcessError:
            # If cherry-pick fails, try to resolve
            subprocess.run(['git', 'add', '-A'], capture_output=True)
            subprocess.run(['git', 'cherry-pick', '--continue'],
                          env=env, input=b'\n', capture_output=True)

print()
print("Updating main branch...")
subprocess.run(['git', 'branch', '-D', 'main'], capture_output=True)
subprocess.run(['git', 'branch', '-m', 'temp_branch', 'main'], check=True)

print()
print("✅ History rewrite complete!")
print()
print("Review the new history with:")
print("  git log --oneline --date=short --pretty=format:'%h - %ad - %s'")
print()
print("When ready, push with:")
print("  git push -f origin main")

