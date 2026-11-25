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

# Wayland only, linked directly rather than dlopened, so the dependencies are
# declared ones. Rendering goes through EGL, which mesa provides on the CPU
# (llvmpipe). No sound server is packaged, so audio is the dummy and disk
# drivers only. X11, KMS/DRM, joysticks over HID/udev, IBus, D-Bus and
# libdecor (not packaged; niri draws server-side decorations) are off.
cmake -S . -B build -G Ninja \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_BUILD_TYPE=Release \
  -DSDL_STATIC=OFF \
  -DSDL_TEST=OFF \
  -DSDL_RPATH=OFF \
  -DSDL_WAYLAND=ON \
  -DSDL_WAYLAND_SHARED=OFF \
  -DSDL_WAYLAND_LIBDECOR=OFF \
  -DSDL_X11=OFF \
  -DSDL_KMSDRM=OFF \
  -DSDL_VULKAN=OFF \
  -DSDL_ALSA=OFF \
  -DSDL_JACK=OFF \
  -DSDL_PIPEWIRE=OFF \
  -DSDL_PULSEAUDIO=OFF \
  -DSDL_SNDIO=OFF \
  -DSDL_LIBSAMPLERATE=OFF \
  -DSDL_HIDAPI=OFF \
  -DSDL_LIBUDEV=OFF \
  -DSDL_IBUS=OFF \
  -DSDL_DBUS=OFF
# SDL turns a backend off rather than failing when a dependency is missing.
grep -q "^#define SDL_VIDEO_DRIVER_WAYLAND 1" build/include-config-*/SDL2/SDL_config.h \
  || { echo "SDL was configured without its Wayland driver" >&2; exit 1; }
cmake --build build
DESTDIR="$OUTPUT_DIR" cmake --install build
