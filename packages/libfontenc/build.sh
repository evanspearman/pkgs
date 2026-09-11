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

# Pin encodingsdir rather than letting configure derive it from font-util's
# prefix, so the path is identical regardless of where the dep landed.
./configure --prefix=/usr \
            --disable-static \
            --with-encodingsdir=/usr/share/fonts/X11/encodings
make -j"$(nproc)"
make DESTDIR="$OUTPUT_DIR" install

find "$OUTPUT_DIR" -name '*.la' -delete
