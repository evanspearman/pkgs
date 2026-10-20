let { subsetOf, Attrs, BuildSpec, Local, OutputBin, OutputData, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
# Generates the built-in terminfo, emoji tables and sRGB lookup at build time.
let python = import "../python/build.ncl" in
let scdoc = import "../scdoc/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
let wayland-protocols = import "../wayland-protocols/build.ncl" in
# Header-only.
let tllist = import "../tllist/build.ncl" in

let fcft = import "../fcft/build.ncl" in
let fontconfig = import "../fontconfig/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let libxkbcommon = import "../libxkbcommon/build.ncl" in
let ncurses = import "../ncurses/build.ncl" in
let pixman = import "../pixman/build.ncl" in
let utf8proc = import "../utf8proc/build.ncl" in
let wayland = import "../wayland/build.ncl" in

let version = "1.28.0" in
{
  name = "foot",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://codeberg.org/dnkl/foot/releases/download/%{version}/foot-%{version}.tar.gz",
      sha256 = "ee73c292a4b457004b38c2df178eac025ab0b849fdd9e13253c1f8b5cf110710",
      extract = true,
      strip_prefix = "foot-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    python,
    scdoc,
    toolchain,
    wayland-protocols,
    tllist,
  ],
  runtime_deps = [
    glibc,
    fcft,
    fontconfig,
    libxkbcommon,
    pixman,
    utf8proc,
    # libwayland-client and libwayland-cursor.
    wayland,
    # foot sets TERM=foot; ncurses carries that entry (see build.sh).
    subsetOf ncurses ["terminfo"],
  ],

  cmd = "./build.sh",

  outputs = {
    foot = { glob = "usr/bin/foot" } | OutputBin,
    footclient = { glob = "usr/bin/footclient" } | OutputBin,
    config = { glob = "etc/xdg/foot/**" } | OutputData,
    themes = { glob = "usr/share/foot/**" } | OutputData,
    desktop = { glob = "usr/share/{applications,icons}/**" } | OutputData,
    man = { glob = "usr/share/man/**" } | OutputData,
    doc = { glob = "usr/share/doc/foot/**" } | OutputData,
    completions = { glob = "usr/share/{zsh,fish,bash-completion}/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "foot",
    } | Attrs,

  tests = {
    smoke =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          # Anything further needs a compositor.
          ["foot", "--version"],
          ["footclient", "--version"],
        ],
      } | Test,
  },
} | BuildSpec
