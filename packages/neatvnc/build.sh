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

# jpeg: Tight encoding, the cheapest good-quality encoding over a slow link.
# tls/nettle: off. wayvnc only listens on a unix socket inside the box (reached
#   over minimal's own SSH channel), so transport security is not its job.
# gbm/h264: off. There is no GPU in the box; both need one to be worth having.
mkdir build && cd build
meson setup --prefix=/usr --buildtype=release \
  -Djpeg=enabled \
  -Dtls=disabled \
  -Dnettle=disabled \
  -Dgbm=disabled \
  -Dh264=disabled \
  -Dexamples=false \
  -Dbenchmarks=false \
  -Dtests=false \
  ..
ninja
DESTDIR="$OUTPUT_DIR" ninja install
