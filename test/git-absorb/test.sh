#!/bin/bash
set -e

# Import test library for `check` command
source dev-container-features-test-lib

# Check git-absorb is installed and working
check "git-absorb is installed" git absorb --version
check "git-absorb command exists" which git-absorb

# Report results
reportResults
