#!/bin/sh
set -e

# Nothing here is compiled, so there are no CFLAGS to set. wayland-scanner only
# generates enum headers; the test suite would compile and link, so it stays off.
mkdir build && cd build
meson setup --prefix=/usr --buildtype=release \
  -Dtests=false \
  ..
ninja
DESTDIR="$OUTPUT_DIR" ninja install
