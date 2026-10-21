let { Attrs, BuildSpec, Local, OutputBin, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let cmake = import "../cmake/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
# mesa's egl.pc requires x11 and xext, whose .pc files require the X
# protocol headers: without them pkg-config fails the egl check and SDL
# silently builds without its Wayland driver.
let xorgproto = import "../xorgproto/build.ncl" in

let glibc = import "../glibc/build.ncl" in
let libxkbcommon = import "../libxkbcommon/build.ncl" in
let mesa = import "../mesa/build.ncl" in
let wayland = import "../wayland/build.ncl" in

# SDL 2, the last of the 2.x series: what most open-source games still build
# against (chocolate-doom among them).
let version = "2.32.10" in
{
  name = "sdl2",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://github.com/libsdl-org/SDL/releases/download/release-%{version}/SDL2-%{version}.tar.gz",
      sha256 = "5f5993c530f084535c65a6879e9b26ad441169b3e25d789d83287040a9ca5165",
      extract = true,
      strip_prefix = "SDL2-%{version}",
    } | Source,
    base,
    cmake,
    ninja,
    pkgconf,
    toolchain,
    xorgproto,
  ],
  runtime_deps = [
    glibc,
    # The keymap for Wayland keyboard input.
    libxkbcommon,
    # EGL and wayland-egl: SDL's Wayland driver renders through them, on the
    # CPU here (llvmpipe).
    mesa,
    # libwayland-client and -cursor; wayland-scanner at build time.
    wayland,
  ],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/libSDL2*.so*" } | OutputLib,
    # sdl2-config is a shell script reporting compile flags.
    config = { glob = "usr/bin/sdl2-config", allow_missing_interpreter = true } | OutputBin,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
    cmake_data = { glob = "usr/lib/cmake/**" } | OutputData,
    static_main = { glob = "usr/lib/libSDL2main.a" } | OutputData,
    aclocal = { glob = "usr/share/aclocal/*" } | OutputData,
    licenses = { glob = "usr/share/licenses/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "Zlib",
      repology_project = "sdl2",
      source_provenance = {
        category = 'GithubRepo,
        owner = "libsdl-org",
        repo = "SDL",
      },
    } | Attrs,
} | BuildSpec
