#!/bin/bash
set -e

VERSION="${version:-0.29.3}"

echo "Installing PocketBase ${VERSION}..."

# Detect architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case $OS in
    linux)
        OS="linux"
        ;;
    darwin)
        OS="darwin"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Construct download URL
FILENAME="pocketbase_${VERSION}_${OS}_${ARCH}.zip"
URL="https://github.com/pocketbase/pocketbase/releases/download/v${VERSION}/${FILENAME}"

# Install dependencies
apt-get update
apt-get install -y --no-install-recommends wget unzip ca-certificates

# Download PocketBase
cd /tmp
echo "Downloading from ${URL}"
wget -q "${URL}" -O pocketbase.zip

# Extract
echo "Extracting ${FILENAME}"
unzip -q pocketbase.zip

# Install to /usr/local/bin
chmod +x pocketbase
mv pocketbase /usr/local/bin/

# Cleanup
rm -f pocketbase.zip
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "PocketBase ${VERSION} installed successfully at /usr/local/bin/pocketbase"
