#!/bin/sh
set -e

mkdir build &&
cd    build

case $(uname -m) in
  x86_64)  MARCH="-march=x86-64-v3" ;;
  aarch64) MARCH="-march=armv8-a" ;;
  *)       MARCH="" ;;
esac
export CFLAGS="$MARCH -O2 -pipe -gno-record-gcc-switches -ffile-prefix-map=$(pwd)=/builddir"
export LDFLAGS="-Wl,--build-id=none"
export CXXFLAGS="${CFLAGS}"

# glib=enabled builds libcairo-gobject and its cairo-gobject.pc. Without it,
# anything binding cairo through GObject introspection (the Rust cairo-sys-rs
# crate, and so niri) fails to configure.
meson setup --prefix=/usr --buildtype=release --wrap-mode=nofallback \
  -Dglib=enabled \
  ..
ninja

DESTDIR="$OUTPUT_DIR" ninja install
