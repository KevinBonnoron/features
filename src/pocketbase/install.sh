#!/bin/bash
set -e

VERSION="${version:-latest}"

echo "Installing PocketBase ${VERSION}..."

# Detect latest version if needed
if [ "${VERSION}" = "latest" ]; then
  echo "Detecting latest PocketBase version from GitHub..."

  apt-get update
  apt-get install -y --no-install-recommends curl
  # Get latest release tag from GitHub API
  POCKETBASE_VERSION=$(curl -s https://api.github.com/repos/pocketbase/pocketbase/releases/latest |
    grep '"tag_name":' |
    sed -E 's/.*"v([^"]+)".*/\1/')

  if [ -z "${POCKETBASE_VERSION}" ]; then
    echo "Failed to detect latest version, falling back to default..."
    POCKETBASE_VERSION="0.34.2"
  fi

  echo "Latest version detected: ${POCKETBASE_VERSION}"

  apt-get clean
  rm -rf /var/lib/apt/lists/*

else
  POCKETBASE_VERSION="${VERSION}"
fi

# Detect architecture
ARCH=$(uname -m)
case $ARCH in
x86_64)
  ARCH="amd64"
  ;;
aarch64 | arm64)
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
FILENAME="pocketbase_${POCKETBASE_VERSION}_${OS}_${ARCH}.zip"
URL="https://github.com/pocketbase/pocketbase/releases/download/v${POCKETBASE_VERSION}/${FILENAME}"

# Install dependencies
apt-get update
apt-get install -y --no-install-recommends wget unzip ca-certificates curl

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

echo "PocketBase ${POCKETBASE_VERSION} installed successfully at /usr/local/bin/pocketbase"
