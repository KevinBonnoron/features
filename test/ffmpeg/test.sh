#!/bin/bash
set -e

# Import test library for `check` command
source dev-container-features-test-lib

# Check ffmpeg is installed and working
check "ffmpeg is installed" ffmpeg -version
check "ffmpeg command exists" which ffmpeg

# Check ffmpeg has basic codec support
check "ffmpeg has libx264" ffmpeg -hide_banner -codecs | grep libx264
check "ffmpeg has libx265" ffmpeg -hide_banner -codecs | grep libx265
check "ffmpeg has libmp3lame" ffmpeg -hide_banner -codecs | grep libmp3lame
check "ffmpeg has libopus" ffmpeg -hide_banner -codecs | grep libopus

# Check if libvpx is enabled (when option is true)
if [ "${LIBVPX}" = "true" ]; then
    check "ffmpeg has libvpx" ffmpeg -hide_banner -codecs | grep libvpx
fi

# Report results
reportResults
