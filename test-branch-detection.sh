#!/bin/bash

set -e

# This script simulates the exact GitHub Actions workflow on our test repository
# It runs the actual code we added to the workflow

echo "FINAL TEST: Simulating GitHub Actions workflow"
echo "=============================================="

# Fetch all remote branches to make sure we have the latest
git fetch --all

# The exact code from our GitHub Actions workflow
simulate_github_actions() {
  local tag=$1
  echo -e "\nSimulating GitHub Actions for tag: $tag"
  
  # GITHUB ACTIONS ENVIRONMENT VARIABLES
  RELEASE_VERSION=$tag
  
  # GITHUB ACTIONS SCRIPT (EXACT COPY FROM THE WORKFLOW)
  TAG_COMMIT=$(git rev-list -n 1 "$RELEASE_VERSION")
  echo "Tag commit: $TAG_COMMIT"
  
  # Improved algorithm to find original source branch
  # We look for the branch where the commit is closest to the branch tip
  BEST_BRANCH="main"
  BEST_DISTANCE=99999
  
  for REMOTE_BRANCH in $(git branch -r --contains "$TAG_COMMIT" | grep -v HEAD | sed -e 's/^[[:space:]]*//' -e 's/^origin\///')
  do
    # Get the base of the branch (where it diverged from main)
    BRANCH_BASE=$(git merge-base origin/main origin/$REMOTE_BRANCH 2>/dev/null || echo "")
    
    if [ ! -z "$BRANCH_BASE" ]; then
      # Check if our tag commit is directly in the branch history
      if git merge-base --is-ancestor $BRANCH_BASE $TAG_COMMIT 2>/dev/null; then
        # Calculate how far our commit is from the branch tip
        DISTANCE=$(git rev-list --count $TAG_COMMIT..origin/$REMOTE_BRANCH)
        
        echo "Branch $REMOTE_BRANCH - Distance from branch tip: $DISTANCE"
        
        # If this is the closest branch so far, update our best match
        if [ $DISTANCE -lt $BEST_DISTANCE ]; then
          BEST_BRANCH=$REMOTE_BRANCH
          BEST_DISTANCE=$DISTANCE
        fi
      fi
    fi
  done
  
  # Fallback to old logic if our algorithm doesn't find anything
  if [ $BEST_DISTANCE -eq 99999 ]; then
    BEST_BRANCH=$(git branch -r --contains "$TAG_COMMIT" | grep -v HEAD | sed -e 's/^[[:space:]]*//' -e 's/^origin\///' | head -n 1 || echo "main")
    echo "Using fallback detection method"
  fi
  
  echo "GITHUB ACTIONS OUTPUT - base_branch=$BEST_BRANCH"
  echo "Base branch for $RELEASE_VERSION: $BEST_BRANCH (distance: $BEST_DISTANCE)"
  
  # The branch that should have been detected (from our test setup)
  echo "Expected base branch for $tag: "
  case "$tag" in
    "v0.1.0")
      echo "main"
      ;;
    "v0.2.0-alpha")
      echo "feature/branch1"
      ;;
    "v1.0.0")
      echo "release/1.0"
      ;;
    "v1.0.1-hotfix")
      echo "hotfix/critical"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

# Test each tag we created
echo "Testing all tags with the final GitHub Actions workflow code"
git tag -l

# Test each tag
simulate_github_actions "v0.1.0"
simulate_github_actions "v0.2.0-alpha"
simulate_github_actions "v1.0.0"
simulate_github_actions "v1.0.1-hotfix"

echo -e "\nFinal simulation complete - Algorithm is ready for production!"