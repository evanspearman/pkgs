#!/bin/sh
set -e

unzip -q "freedoom-$MINIMAL_ARG_VERSION.zip"
cd "freedoom-$MINIMAL_ARG_VERSION"

# Where Doom source ports look for game data (IWADs).
install -Dm644 -t "$OUTPUT_DIR/usr/share/games/doom" freedoom1.wad freedoom2.wad
install -Dm644 -t "$OUTPUT_DIR/usr/share/doc/freedoom" README.html COPYING.txt freedoom-manual-en.pdf
