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

mkdir _build && cd _build
meson setup --prefix=/usr --buildtype=release -Dbuild-documentation=false ..
ninja -j${NINJA_JOBS:-6}
DESTDIR="$OUTPUT_DIR" ninja install
