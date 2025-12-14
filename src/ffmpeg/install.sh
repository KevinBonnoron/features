#!/bin/bash
set -e

VERSION="${version:-latest}"
INSTALL_LIBVPX="${libvpx:-false}"
INSTALL_OPENSSL="${openssl:-true}"

install_from_apt() {
  echo "Installing pre-compiled FFmpeg from apt repositories..."
  apt-get update
  apt-get -y install --no-install-recommends ffmpeg
  INSTALLED_VERSION=$(ffmpeg -version | head -n 1)
  echo "FFmpeg installed: ${INSTALLED_VERSION}"
}

install_from_source() {
  echo "Building FFmpeg ${VERSION} from source..."

  DEPS="build-essential pkg-config yasm nasm git wget ca-certificates libx264-dev libx265-dev libnuma-dev libmp3lame-dev libopus-dev"

  if [ "${INSTALL_OPENSSL}" = "true" ]; then
    DEPS="${DEPS} libssl-dev"
  fi

  if [ "${INSTALL_LIBVPX}" = "true" ]; then
    DEPS="${DEPS} libvpx-dev"
  fi

  apt-get update
  apt-get -y install --no-install-recommends ${DEPS}

  if [ "${VERSION}" = "latest" ]; then
    echo "Detecting latest available FFmpeg version from releases..."
    FFMPEG_VERSION=$(curl -s https://ffmpeg.org/releases/ |
      grep -o 'ffmpeg-[0-9.]*\.tar\.bz2' |
      sed -n 's/ffmpeg-\([0-9.]*\)\.tar\.bz2/\1/p' |
      sort -Vru |
      head -n 1)

    if [ -z "${FFMPEG_VERSION}" ]; then
      echo "Failed to detect latest version, falling back to git method..."
      FFMPEG_VERSION=$(git ls-remote --tags https://git.ffmpeg.org/ffmpeg.git |
        grep -v '\^{}' |
        grep -o 'refs/tags/n[0-9.]*' |
        sed 's/refs\/tags\/n//' |
        sort -V |
        tail -n 1)
    fi

    echo "Latest version detected: ${FFMPEG_VERSION}"
  else
    FFMPEG_VERSION="${VERSION}"
  fi

  cd /tmp
  TARBALL_URL="https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2"

  echo "Checking if ${TARBALL_URL} exists..."
  if wget --spider "${TARBALL_URL}" 2>&1 | grep -q '200 OK'; then
    echo "Downloading FFmpeg ${FFMPEG_VERSION} from releases..."
    wget -O ffmpeg.tar.bz2 "${TARBALL_URL}"
    tar xjf ffmpeg.tar.bz2
    cd "ffmpeg-${FFMPEG_VERSION}"
  else
    echo "Tarball not found, cloning from git instead..."
    git clone --depth 1 --branch "n${FFMPEG_VERSION}" https://git.ffmpeg.org/ffmpeg.git ffmpeg-git
    cd ffmpeg-git
  fi

  CONFIGURE_FLAGS="--enable-gpl --enable-nonfree --enable-libx264 --enable-libx265 --enable-libmp3lame --enable-libopus"

  if [ "${INSTALL_OPENSSL}" = "true" ]; then
    CONFIGURE_FLAGS="${CONFIGURE_FLAGS} --enable-openssl"
  fi

  if [ "${INSTALL_LIBVPX}" = "true" ]; then
    CONFIGURE_FLAGS="${CONFIGURE_FLAGS} --enable-libvpx"
  fi

  ./configure ${CONFIGURE_FLAGS}
  make -j$(nproc)
  make install

  ldconfig

  cd /
  rm -rf /tmp/ffmpeg*

  echo "FFmpeg ${FFMPEG_VERSION} installed successfully from source"
}

echo "Installing FFmpeg ${VERSION}..."

if [ "${VERSION}" = "system" ] || [ "${VERSION}" = "apt" ]; then
  install_from_apt
else
  install_from_source
fi
