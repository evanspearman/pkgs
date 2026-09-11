#!/bin/sh
set -e

# Nothing here is compiled, so there are no CFLAGS to set. The test suite is the
# only thing that would pull in libwayland, so it stays off.
mkdir build && cd build
meson setup --prefix=/usr --buildtype=release \
  -Dtests=false \
  ..
ninja
DESTDIR="$OUTPUT_DIR" ninja install
