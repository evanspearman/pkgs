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

# terminfo: off. ncurses already ships foot and foot-direct, and two packages
#   writing usr/share/terminfo/f*/foot would collide.
# utmp-backend: none. libutempter is not packaged, and a box has no utmp.
# grapheme-clustering: fcft is built with harfbuzz and utf8proc, so it is
#   useful here.
mkdir _build && cd _build
meson setup --prefix=/usr --buildtype=release \
  -Dterminfo=disabled \
  -Dutmp-backend=none \
  -Dgrapheme-clustering=enabled \
  -Ddocs=enabled \
  -Dtests=false \
  ..
ninja
DESTDIR="$OUTPUT_DIR" ninja install
