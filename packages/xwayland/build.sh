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

# glamor renders through EGL/gbm and provides GLX to X11 clients. Both depend on
# mesa being built with glx enabled and a Wayland EGL platform; with no GPU this
# resolves to llvmpipe, i.e. software rendering rather than failure.
#
# xkb_output_dir is where the server writes keymaps compiled by xkbcomp. The
# usual /var/lib/xkb is not writable in this sandbox, so it points at /tmp.
mkdir build && cd build
meson setup --prefix=/usr --buildtype=release \
  -Dglamor=true \
  -Dglx=true \
  -Ddri3=true \
  -Dxvfb=false \
  -Dxdmcp=false \
  -Dxcsecurity=true \
  `# SUN-DES-1 auth; would need libtirpc and nothing uses it.` \
  -Dsecure-rpc=false \
  -Dipv6=true \
  -Dsha1=libnettle \
  -Dxkb_dir=/usr/share/X11/xkb \
  -Dxkb_output_dir=/tmp \
  -Ddocs=false \
  -Ddevel-docs=false \
  ..
ninja
DESTDIR="$OUTPUT_DIR" ninja install

# Shipped by xorg-server proper, not by Xwayland's own package in any distro.
rm -f "$OUTPUT_DIR/usr/share/man/man1/Xserver.1"
rm -f "$OUTPUT_DIR/usr/lib/xorg/protocol.txt"
