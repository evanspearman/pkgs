#!/bin/sh
set -e

case $(uname -m) in
  x86_64)  MARCH="-march=x86-64-v3" ;;
  aarch64) MARCH="-march=armv8-a" ;;
  *)       MARCH="" ;;
esac
export CFLAGS="$MARCH -O2 -pipe -gno-record-gcc-switches -ffile-prefix-map=$(pwd)=/builddir"
export LDFLAGS="-Wl,--build-id=none"
export CXXFLAGS="${CFLAGS}"

# Mesa requires python packaging and mako modules
pip3 install packaging mako pyyaml 2>/dev/null || pip install packaging mako pyyaml 2>/dev/null || true

# platforms: wayland was added alongside x11 so that EGL has a Wayland platform
# at all -- without it libwayland-egl exists but nothing can bind a Wayland
# display, which blocks every nested Wayland compositor and toolkit.
#
# llvmpipe replaces softpipe as the default software rasterizer. softpipe is the
# reference implementation and is far too slow to composite with; llvmpipe JITs
# through LLVM and is the driver every distro ships for software GL. softpipe is
# kept as a fallback for when LLVM codegen is unavailable.
#
# glx=dri restores GLX, which was previously disabled and left no gl.pc in the
# tree -- that is what forced Xwayland to build without GLX support.
mkdir build && cd build
meson setup --prefix=/usr --buildtype=release \
  -Dplatforms=x11,wayland \
  -Dgallium-drivers=llvmpipe,softpipe \
  -Dvulkan-drivers='' \
  -Dglx=dri \
  -Degl=enabled \
  -Dgles2=enabled \
  -Dgbm=enabled \
  -Dllvm=enabled \
  -Dshared-llvm=enabled \
  ..

# Bounded width on purpose. ninja defaults to nproc+2, and llvmpipe's
# translation units compile against the LLVM headers at 1-2 GB per job, so the
# default fans out to tens of GB on a many-core builder and gets OOM-killed.
# Six jobs keeps the peak well under control at a modest cost in wall clock.
ninja -j6
DESTDIR="$OUTPUT_DIR" ninja install
