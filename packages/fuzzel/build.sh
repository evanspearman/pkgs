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

# nanosvg for SVG icons, bundled rather than system (system-nanosvg=disabled),
# which keeps librsvg and its cairo/gdk-pixbuf tail out of the dependency set.
# libpng covers raster icons. enable-cairo stays off for the same reason: it is
# only needed by the librsvg backend.
mkdir _build && cd _build
meson setup --prefix=/usr --buildtype=release \
  -Dpng-backend=libpng \
  -Dsvg-backend=nanosvg \
  -Dsystem-nanosvg=disabled \
  -Denable-cairo=disabled \
  ..
ninja -j"${NINJA_JOBS:-6}"
DESTDIR="$OUTPUT_DIR" ninja install
