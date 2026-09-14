#!/bin/sh
set -e

# Header-only: nothing is compiled, so there are no flags to set. meson still
# has to run to install the headers and generate tllist.pc.
mkdir _build && cd _build
meson setup --prefix=/usr --buildtype=release ..
ninja
DESTDIR="$OUTPUT_DIR" ninja install
