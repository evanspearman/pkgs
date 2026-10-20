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

# Headless-only build. auto_features=disabled resolves the renderers, backends
# and allocators arrays to empty, which still leaves what is always built: the
# headless and wayland backends, the pixman renderer and the shm allocator.
# That is exactly what a compositor needs to run with no GPU and no seat, as
# inside a box (WLR_BACKENDS=headless). The DRM/libinput backends would pull in
# libseat, libudev, libinput, hwdata and libdisplay-info for hardware a box
# never has, so they are left out until something needs them.
mkdir build && cd build
meson setup --prefix=/usr --buildtype=release \
  -Dauto_features=disabled \
  -Dxwayland=disabled \
  -Dsession=disabled \
  -Dexamples=false \
  -Dwerror=false \
  ..
ninja
DESTDIR="$OUTPUT_DIR" ninja install
