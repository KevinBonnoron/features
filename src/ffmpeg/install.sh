#!/bin/bash
set -e

VERSION="${version:-latest}"
INSTALL_LIBVPX="${libvpx:-false}"

echo "Installing FFmpeg ${VERSION} from source..."

# Install build dependencies
apt-get update
apt-get -y install --no-install-recommends \
    build-essential \
    pkg-config \
    yasm \
    nasm \
    git \
    wget \
    ca-certificates \
    libx264-dev \
    libx265-dev \
    libnuma-dev \
    libmp3lame-dev \
    libopus-dev

# Install libvpx if requested
if [ "${INSTALL_LIBVPX}" = "true" ]; then
    apt-get -y install --no-install-recommends libvpx-dev
fi

# Determine version to install
if [ "${VERSION}" = "latest" ]; then
    # Get latest release tag from FFmpeg git
    FFMPEG_VERSION=$(git ls-remote --tags https://git.ffmpeg.org/ffmpeg.git | \
        grep -v '\^{}' | \
        grep -o 'refs/tags/n[0-9.]*$' | \
        sed 's/refs\/tags\/n//' | \
        sort -V | \
        tail -n 1)
    echo "Latest version detected: ${FFMPEG_VERSION}"
else
    FFMPEG_VERSION="${VERSION}"
fi

# Download FFmpeg source
cd /tmp
wget -O ffmpeg.tar.bz2 "https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2"
tar xjf ffmpeg.tar.bz2
cd "ffmpeg-${FFMPEG_VERSION}"

# Configure options
CONFIGURE_FLAGS="--enable-gpl --enable-nonfree --enable-libx264 --enable-libx265 --enable-libmp3lame --enable-libopus"

if [ "${INSTALL_LIBVPX}" = "true" ]; then
    CONFIGURE_FLAGS="${CONFIGURE_FLAGS} --enable-libvpx"
fi

# Configure, compile and install
./configure ${CONFIGURE_FLAGS}
make -j$(nproc)
make install

# Update library cache
ldconfig

# Cleanup
cd /
rm -rf /tmp/ffmpeg*

echo "FFmpeg ${FFMPEG_VERSION} installed successfully"
