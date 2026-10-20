#!/bin/sh
set -e

case $(uname -m) in
  x86_64)  MARCH="-march=x86-64-v3" ;;
  aarch64) MARCH="-march=armv8-a" ;;
  *)       MARCH="" ;;
esac
export CFLAGS="$MARCH -O2 -pipe -gno-record-gcc-switches -ffile-prefix-map=$(pwd)=/builddir"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-Wl,--build-id=none"

# screencopy-dmabuf: off, there is no GPU to copy from.
# pam: off, wayvnc listens on a unix socket inside the box only.
mkdir build && cd build
meson setup --prefix=/usr --buildtype=release \
  -Dscreencopy-dmabuf=disabled \
  -Dpam=disabled \
  -Dman-pages=disabled \
  -Dtests=false \
  ..
ninja
DESTDIR="$OUTPUT_DIR" ninja install
