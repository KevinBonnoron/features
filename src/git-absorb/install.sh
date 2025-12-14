#!/bin/bash
set -e

echo "Installing git-absorb..."

apt-get update
apt-get -y install git-absorb --no-install-recommends

echo "git-absorb installed successfully"
