#!/bin/sh
set -e

case $(uname -m) in
  x86_64)  MARCH="-march=x86-64-v3" ;;
  aarch64) MARCH="-march=armv8-a" ;;
  *)       MARCH="" ;;
esac
export CFLAGS="$MARCH -O2 -pipe -gno-record-gcc-switches -ffile-prefix-map=$(pwd)=/builddir"
export LDFLAGS="-Wl,--build-id=none"

# The sandbox has no `cc` symlink and scdoc's Makefile defaults to it, which
# fails as a bare "Error 127" with the command echoed but no diagnostic.
export CC=gcc

# Plain Makefile, no configure. PREFIX is read at both build and install time
# (it is baked into the generated .pc), so pass it to each.
make -j"$(nproc)" PREFIX=/usr
make PREFIX=/usr DESTDIR="$OUTPUT_DIR" install
