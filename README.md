# Source Branch Detection Test

This repository is used to test and validate the algorithm for detecting the source branch of a git tag. The goal is to accurately determine which branch a tag was created on, even when the tag is visible from multiple branches.

## Problem Background

In GitHub Actions workflows, when a tag is created, it's useful to know which branch the tag originated from for notification and context purposes. The simplest approach (checking which branches contain the tag commit) can be unreliable, as multiple branches might contain the same commit, especially when branches have been merged.

## Test Structure

The repository contains:

1. Multiple branches with unique commits:
   - `main` - The base branch with an initial commit
   - `feature/branch1` - Feature branch with its own commit
   - `release/1.0` - Release branch with a unique commit
   - `hotfix/critical` - Hotfix branch with a critical fix

2. Tags placed on different branches:
   - `v0.1.0` - On main branch
   - `v0.2.0-alpha` - On feature/branch1
   - `v1.0.0` - On release/1.0
   - `v1.0.1-hotfix` - On hotfix/critical

## Test Results

The final algorithm was tested against all tags and correctly identified the source branch in all cases:

```
FINAL TEST: Simulating GitHub Actions workflow
==============================================
Testing all tags with the final GitHub Actions workflow code
v0.1.0
v0.2.0-alpha
v1.0.0
v1.0.1-hotfix

Simulating GitHub Actions for tag: v0.1.0
Tag commit: 5981f5268c9d132c36a1ff9b3532e1c055cb34c3
Branch feature/branch1 - Distance from branch tip: 1
Branch hotfix/critical - Distance from branch tip: 3
Branch main - Distance from branch tip: 0
Branch release/1.0 - Distance from branch tip: 2
GITHUB ACTIONS OUTPUT - base_branch=main
Base branch for v0.1.0: main (distance: 0)
Expected base branch for v0.1.0: 
main

Simulating GitHub Actions for tag: v0.2.0-alpha
Tag commit: c3b04a1ffabf7cfbf26488ecba497e3442dcca54
Branch feature/branch1 - Distance from branch tip: 0
Branch hotfix/critical - Distance from branch tip: 2
Branch release/1.0 - Distance from branch tip: 1
GITHUB ACTIONS OUTPUT - base_branch=feature/branch1
Base branch for v0.2.0-alpha: feature/branch1 (distance: 0)
Expected base branch for v0.2.0-alpha: 
feature/branch1

Simulating GitHub Actions for tag: v1.0.0
Tag commit: 3e4bb5351ae0d67b1e32146fd7d43b5717124948
Branch hotfix/critical - Distance from branch tip: 1
Branch release/1.0 - Distance from branch tip: 0
GITHUB ACTIONS OUTPUT - base_branch=release/1.0
Base branch for v1.0.0: release/1.0 (distance: 0)
Expected base branch for v1.0.0: 
release/1.0

Simulating GitHub Actions for tag: v1.0.1-hotfix
Tag commit: e0b6295fbdb25a986220a64774bd85dbe2393330
Branch hotfix/critical - Distance from branch tip: 0
GITHUB ACTIONS OUTPUT - base_branch=hotfix/critical
Base branch for v1.0.1-hotfix: hotfix/critical (distance: 0)
Expected base branch for v1.0.1-hotfix: 
hotfix/critical
```

## Algorithm

The improved algorithm:

1. Gets all remote branches containing the tag commit
2. For each branch, calculates the "distance" from the tag commit to the branch tip
3. Selects the branch with the smallest distance (closest to the branch tip)
4. This correctly identifies the branch where the tag was most likely created
5. Falls back to the original method if the algorithm doesn't find a matching branch

## Usage

To run the test:

```bash
./test-branch-detection.sh
```
