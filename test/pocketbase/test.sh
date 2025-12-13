#!/bin/bash
set -e

# Import test library for `check` command
source dev-container-features-test-lib

# Check pocketbase is installed and working
check "pocketbase is installed" pocketbase --version
check "pocketbase command exists" which pocketbase

# Verify pocketbase can show help
check "pocketbase help works" pocketbase --help

# Report results
reportResults
