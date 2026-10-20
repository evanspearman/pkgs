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

# Built for headless use. auto_features=disabled leaves the renderers and
# allocators arrays empty, so there is no EGL, GBM or
# Vulkan: the pixman renderer and shm allocator, which are always built, are
# what a compositor uses in a box with no GPU (WLR_RENDERER=pixman).
#
# The DRM backend and session support are on even so, because cage, the one
# consumer, includes <wlr/types/wlr_drm_lease_v1.h> and calls
# wlr_session_change_vt() unconditionally; wlroots installs neither without
# them. With WLR_BACKENDS=headless the compositor never opens a seat or a DRM
# device, so libseat and libudev are linked but unused at runtime. The libinput
# and x11 backends stay off: nothing here needs them.
mkdir build && cd build
meson setup --prefix=/usr --buildtype=release \
  -Dauto_features=disabled \
  -Dbackends=drm \
  -Dsession=enabled \
  -Dxwayland=disabled \
  -Dexamples=false \
  -Dwerror=false \
  ..
ninja
DESTDIR="$OUTPUT_DIR" ninja install
