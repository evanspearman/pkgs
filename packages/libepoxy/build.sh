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

# glx=no drops the libX11 dependency: Xwayland uses epoxy for EGL and GLES only.
mkdir build && cd build
meson setup --prefix=/usr --buildtype=release \
  -Dglx=no \
  -Degl=yes \
  -Dx11=false \
  -Dtests=false \
  ..
ninja
DESTDIR="$OUTPUT_DIR" ninja install
