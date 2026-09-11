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

# Xwayland is the only consumer here and it reads fonts from local disk, so the
# font-server transport and its libtirpc dependency are switched off.
./configure --prefix=/usr \
            --disable-static \
            --disable-devel-docs \
            --disable-fontserver-transport
make -j"$(nproc)"
make DESTDIR="$OUTPUT_DIR" install

find "$OUTPUT_DIR" -name '*.la' -delete
