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

# Every optional module is off. Each one is a dependency that is either absent
# from the registry (pipewire, libnl, upower, playerctl, libmpdclient, jack,
# wireplumber, libgps, mm-glib, libcava) or only meaningful on a real desktop
# session (systemd, dbusmenu tray). What remains is the built-in set: clock,
# cpu, memory, disk, temperature, custom scripts, and the niri modules.
#
# -j is bounded: waybar is C++ and the default width has been enough to exhaust
# memory on a many-core builder.
mkdir _build && cd _build
meson setup --prefix=/usr --buildtype=release \
  -Dniri=true \
  -Dlibinput=disabled \
  -Dlibnl=disabled \
  `# factory.cpp includes util/udev_deleter.hpp unconditionally, so a disabled
  # libudev still fails to compile in 0.15.0. eudev is already packaged.` \
  -Dlibudev=enabled \
  -Dlibevdev=disabled \
  -Dpulseaudio=disabled \
  -Dpipewire=disabled \
  -Dwireplumber=disabled \
  -Dupower_glib=disabled \
  -Dmpris=disabled \
  -Dmpd=disabled \
  -Djack=disabled \
  -Dcava=disabled \
  -Dgps=disabled \
  -Drfkill=disabled \
  -Dsystemd=disabled \
  -Ddbusmenu-gtk=disabled \
  -Dsndio=disabled \
  -Dlogind=disabled \
  -Dlogin-proxy=false \
  -Dman-pages=disabled \
  -Dtests=disabled \
  -Dexperimental=false \
  ..
ninja -j"${NINJA_JOBS:-6}"
DESTDIR="$OUTPUT_DIR" ninja install
