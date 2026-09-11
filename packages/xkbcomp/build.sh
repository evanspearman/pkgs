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

# Where xkbcomp looks for rules/symbols/geometry at runtime. This must match the
# install prefix used by the xkeyboard-config package.
./configure --prefix=/usr \
            --with-xkb-config-root=/usr/share/X11/xkb
make -j"$(nproc)"
make DESTDIR="$OUTPUT_DIR" install
