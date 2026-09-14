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

# Text shaping has no option in 3.3.x -- it turns on automatically when
# harfbuzz and utf8proc are found, which is why both are runtime deps.
# system-nanosvg=disabled uses the bundled copy, so no librsvg is needed for
# SVG (colour emoji) glyphs.
mkdir _build && cd _build
meson setup --prefix=/usr --buildtype=release \
  -Dsvg-backend=nanosvg \
  -Dsystem-nanosvg=disabled \
  -Dexamples=false \
  ..
ninja -j"${NINJA_JOBS:-6}"
DESTDIR="$OUTPUT_DIR" ninja install
