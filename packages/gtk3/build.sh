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

# Wayland only: the X11 backend would pull the whole libX11/libXi/libXcursor set
# in for a backend nothing here uses -- waybar runs against niri.
#
# -j is bounded because gtk3 is the widest C build in this chain and the default
# (nproc+2) has been enough to exhaust memory on a many-core builder.
mkdir _build && cd _build
meson setup --prefix=/usr --buildtype=release \
  -Dwayland_backend=true \
  -Dx11_backend=false \
  -Dbroadway_backend=false \
  -Dprint_backends=file \
  -Dintrospection=false \
  -Dgtk_doc=false \
  -Dman=false \
  -Ddemos=false \
  -Dexamples=false \
  -Dtests=false \
  -Dcolord=no \
  -Dcloudproviders=false \
  -Dtracker3=false \
  ..
ninja -j"${NINJA_JOBS:-6}"
DESTDIR="$OUTPUT_DIR" ninja install

# meson skips its own post-install hooks whenever DESTDIR is set, so the
# compiled schema cache and the module caches are never produced. Run them by
# hand against the staged tree: without gschemas.compiled every GTK app aborts
# on the first settings lookup.
glib-compile-schemas "$OUTPUT_DIR/usr/share/glib-2.0/schemas"
for d in "$OUTPUT_DIR"/usr/lib/gtk-3.0/3.0.0/*; do
  [ -d "$d" ] && gio-querymodules "$d"
done
