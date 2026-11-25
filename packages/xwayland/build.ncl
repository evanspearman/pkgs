let { Attrs, BuildSpec, Local, OutputBin, OutputData, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
let xorgproto = import "../xorgproto/build.ncl" in
let xtrans = import "../xtrans/build.ncl" in

let dbus = import "../dbus/build.ncl" in
let font-util = import "../font-util/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let libdrm = import "../libdrm/build.ncl" in
let libepoxy = import "../libepoxy/build.ncl" in
let libxcvt = import "../libxcvt/build.ncl" in
let libxfont2 = import "../libxfont2/build.ncl" in
let mesa = import "../mesa/build.ncl" in
let nettle = import "../nettle/build.ncl" in
let pixman = import "../pixman/build.ncl" in
let wayland = import "../wayland/build.ncl" in
let wayland-protocols = import "../wayland-protocols/build.ncl" in
let xkbcomp = import "../xkbcomp/build.ncl" in
let xkeyboard-config = import "../xkeyboard-config/build.ncl" in

let version = "24.1.13" in
{
  name = "xwayland",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://xorg.freedesktop.org/archive/individual/xserver/xwayland-%{version}.tar.xz",
      sha256 = "173aea3d6f79609164c04528e1c8e4c9b60fcd59391c3c9dad4667297d727fb6",
      extract = true,
      strip_prefix = "xwayland-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
    xorgproto,
    # Header-only: the X transport layer.
    xtrans,
    font-util,
    # wayland is a build dep too, for wayland-scanner.
    wayland-protocols,
  ],
  runtime_deps = [
    glibc,
    dbus,
    libdrm,
    libepoxy,
    libxcvt,
    libxfont2,
    # Provides libgbm and the EGL/GLES that glamor renders through. With no GPU
    # this resolves to llvmpipe, i.e. software rendering.
    mesa,
    # SHA1 for the X resource/security hashing, via -Dsha1=libnettle.
    nettle,
    pixman,
    wayland,
    # Execed at runtime to compile keymaps, and the dataset it compiles from.
    xkbcomp,
    xkeyboard-config,
  ],

  cmd = "./build.sh",

  outputs = {
    bin = { glob = "usr/bin/Xwayland" } | OutputBin,
    man = { glob = "usr/share/man/**" } | OutputData,
    # Compositors read xwayland.pc to discover the server's path and version.
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
    desktop = { glob = "usr/share/applications/*.desktop" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "xwayland",
    } | Attrs,

  tests = {
    smoke =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          # Xwayland needs a compositor to attach to, so the most that can be
          # checked standalone is that it links and reports its version.
          ["/bin/bash", "-c", "Xwayland -version 2>&1 | grep -q 'X.Org'"],
        ],
      } | Test,
  },
} | BuildSpec
