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

# logind/elogind backends are disabled: this build targets the standalone seatd
# daemon plus the builtin backend, which is what a compositor links against.
mkdir build && cd build
meson setup --prefix=/usr --buildtype=release \
  -Dlibseat-logind=disabled \
  -Dlibseat-seatd=enabled \
  -Dlibseat-builtin=enabled \
  -Dserver=enabled \
  -Dexamples=disabled \
  -Dman-pages=disabled \
  ..
ninja
DESTDIR="$OUTPUT_DIR" ninja install
