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

# Loaders we deliberately leave out: their libraries are not packaged yet, and
# letting configure auto-detect them would make the build depend on whatever
# happens to be in the sandbox. PNG/GIF/QOI/XWD are handled by the bundled
# lodepng and libnsgif, so they need no flags.
./configure --prefix=/usr \
            --disable-static \
            --disable-man \
            --disable-gtk-doc \
            --disable-rpath \
            --without-avif \
            --without-heif \
            --without-jxl \
            --without-svg \
            --without-tiff

make -j"$(nproc)"
make DESTDIR="$OUTPUT_DIR" install

# Libtool archives bake in build-tree paths and nothing downstream reads them.
find "$OUTPUT_DIR" -name '*.la' -delete
