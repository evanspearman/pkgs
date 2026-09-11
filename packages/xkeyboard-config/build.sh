#!/bin/sh
set -e

# Data-only package: no compiler flags apply. The test suite wants xkbcli from
# libxkbcommon's tools plus pytest, neither of which belongs in this dependency
# set, so it stays off.
mkdir build && cd build
meson setup --prefix=/usr --buildtype=release \
  -Dxorg-rules-symlinks=true \
  ..
ninja
DESTDIR="$OUTPUT_DIR" ninja install

# Upstream installs /usr/share/X11/xkb as an ABSOLUTE symlink to
# /usr/share/xkeyboard-config-<major>. The sandbox rejects that as pointing
# outside $OUTPUT_DIR, so rewrite it relative to its own directory. Consumers
# (xkbcomp, Xwayland) are configured against the legacy X11 path, so the link
# has to stay.
xkbdir=$(cd "$OUTPUT_DIR/usr/share" && ls -d xkeyboard-config-*)
ln -sfn "../$xkbdir" "$OUTPUT_DIR/usr/share/X11/xkb"
