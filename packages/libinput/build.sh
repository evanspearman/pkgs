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

# libwacom (tablet support), the GTK debug-gui, docs and tests are all optional
# and would each drag in a dependency tree niri does not need.
mkdir build && cd build
meson setup --prefix=/usr --buildtype=release \
  -Dlibwacom=false \
  -Ddebug-gui=false \
  -Dtests=false \
  -Ddocumentation=false \
  -Dinstall-tests=false \
  ..
ninja
DESTDIR="$OUTPUT_DIR" ninja install

# The measure/analyze/replay helpers are "#!/usr/bin/env python3" scripts that
# additionally need python-libevdev and pyudev, neither of which is packaged --
# they would ship guaranteed-broken. Drop them and keep the C helpers that the
# libinput CLI dispatches to for list-devices, debug-events and record.
find "$OUTPUT_DIR/usr/libexec/libinput" -type f \
  -exec grep -lI '^#!.*python' {} + 2>/dev/null | xargs -r rm -f
