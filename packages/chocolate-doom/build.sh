#!/bin/sh
set -e

case $(uname -m) in
  x86_64)  MARCH="-march=x86-64-v3" ;;
  aarch64) MARCH="-march=armv8-a" ;;
  *)       MARCH="" ;;
esac
export CFLAGS="$MARCH -O2 -pipe -gno-record-gcc-switches -ffile-prefix-map=$(pwd)=/builddir"
export LDFLAGS="-Wl,--build-id=none"

# SDL2_mixer and SDL2_net are optional and left out: a box has no sound
# device, and netplay is not what this is for. Music and sound effects are
# then silent, which the game handles.
cmake -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DENABLE_SDL2_MIXER=OFF \
  -DENABLE_SDL2_NET=OFF
cmake --build build --target chocolate-doom chocolate-setup

# The cmake build has no install rules.
install -Dm755 build/src/chocolate-doom "$OUTPUT_DIR/usr/bin/chocolate-doom"
install -Dm755 build/src/chocolate-setup "$OUTPUT_DIR/usr/bin/chocolate-setup"
# Upstream's autotools install names it this way for Doom too.
ln -s chocolate-setup "$OUTPUT_DIR/usr/bin/chocolate-doom-setup"
install -Dm644 data/doom.png "$OUTPUT_DIR/usr/share/icons/hicolor/64x64/apps/chocolate-doom.png"
