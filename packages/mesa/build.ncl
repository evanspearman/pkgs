let { subsetOf, Attrs, BuildSpec, Local, OutputData, OutputLib, Source, Test, .. } = import "minimal.ncl" in
let bash-bootstrap = import "../bash-bootstrap/build.ncl" in
let base = import "../base/build.ncl" in
let gcc = import "../gcc/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let python = import "../python/build.ncl" in
let bison = import "../bison/build.ncl" in
let flex = import "../flex/build.ncl" in
let m4 = import "../m4/build.ncl" in

let libdrm = import "../libdrm/build.ncl" in
let libxcb = import "../libxcb/build.ncl" in
let libx11 = import "../libx11/build.ncl" in
let libxdamage = import "../libxdamage/build.ncl" in
let libxext = import "../libxext/build.ncl" in
let libxfixes = import "../libxfixes/build.ncl" in
let libxrandr = import "../libxrandr/build.ncl" in
let libxshmfence = import "../libxshmfence/build.ncl" in
let libxxf86vm = import "../libxxf86vm/build.ncl" in
let llvm = import "../llvm/build.ncl" in
let wayland = import "../wayland/build.ncl" in
let wayland-protocols = import "../wayland-protocols/build.ncl" in
let xorgproto = import "../xorgproto/build.ncl" in
let expat = import "../expat/build.ncl" in
let zlib = import "../zlib/build.ncl" in
let glibc = import "../glibc/build.ncl" in

let version = "26.3.1" in
{
  name = "mesa",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      # https://archive.mesa3d.org/mesa-26.3.1.tar.xz
      # (mesa is developed at gitlab.freedesktop.org/mesa/mesa; archive.mesa3d.org
      #  serves the release tarballs. The gs:// URL is a staged mirror of that.)
      url = "gs://minimal-staging-archives/mesa-%{version}.tar.xz",
      sha256 = "4e4e438eac7b840a9383988cbb7c08dad8041da544b9319fc26d319fa7348961",
      extract = true,
      strip_prefix = "mesa-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
    python,
    bison,
    flex,
    m4,
    xorgproto,
    # Supplies the XML for the Wayland EGL platform's protocol bindings.
    wayland-protocols,
  ],
  runtime_deps = [
    libdrm,
    libxcb,
    libx11,
    # GLX/DRI2 pull these in on top of the base X set.
    libxdamage,
    libxext,
    libxfixes,
    libxrandr,
    libxshmfence,
    libxxf86vm,
    # llvmpipe JITs its shaders through LLVM, so libLLVM is linked, not optional.
    llvm,
    # libwayland-{client,server} back the Wayland EGL platform.
    wayland,
    expat,
    zlib,
    glibc,
    subsetOf gcc ["libstdcpp", "libgcc"],
  ],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/lib{gbm,EGL,GL,GLESv,glapi,gallium}*.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
    drivers = { glob = "usr/lib/dri/*.so" } | OutputLib,
  },
  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT AND SGI-B-2.0",
    } | Attrs,

  tests = {
    smoketest =
      {
        class = 'Standalone,
        test_deps = [bash-bootstrap, toolchain],
        cmds = [
          [
            "/usr/bin/bash",
            "-c",
            m%%%"
              set -e
              cd /tmp
              gcc -x c - -o t -x none -lEGL <<'EOF'
              #include <stdio.h>
              #include <EGL/egl.h>
              int main(void) {
                /* client extensions need no display: proves libEGL and its deps load */
                const char *ext = eglQueryString(EGL_NO_DISPLAY, EGL_EXTENSIONS);
                printf("EGL client extensions: %s\n", ext ? ext : "(null)");
                return ext == NULL;
              }
              EOF
              ./t
            "%%%
          ],
        ],
      } | Test,
  },
} | BuildSpec
