INSTALL_LIBVPX="${libcpx:-false}"

PACKAGES=ffmpeg
if [ "${INSTALL_LIBVPX}" = true]; then
  PACKAGES="${PACKAGES} libvpx6"
fi

apt-get update
apt-get -y install ffmpeg --no-install-recommends
