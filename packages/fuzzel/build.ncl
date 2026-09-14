let { Attrs, BuildSpec, Local, OutputBin, OutputData, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let python = import "../python/build.ncl" in
let scdoc = import "../scdoc/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
let wayland-protocols = import "../wayland-protocols/build.ncl" in

let fcft = import "../fcft/build.ncl" in
let fontconfig = import "../fontconfig/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let libpng = import "../libpng/build.ncl" in
let libxkbcommon = import "../libxkbcommon/build.ncl" in
let pixman = import "../pixman/build.ncl" in
let tllist = import "../tllist/build.ncl" in
let wayland = import "../wayland/build.ncl" in

let version = "1.15.0" in
{
  name = "fuzzel",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://codeberg.org/dnkl/fuzzel/releases/download/%{version}/fuzzel-%{version}.tar.gz",
      sha256 = "11bee600e19ee1638db592e41980445673224716fbedbd0213b25153325f4182",
      extract = true,
      strip_prefix = "fuzzel-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    # srgb.py generates a lookup table at build time.
    python,
    # doc/meson.build requires scdoc unconditionally -- there is no option to
    # skip the man pages.
    scdoc,
    toolchain,
    wayland-protocols,
    # Header-only.
    tllist,
  ],
  # Draws a zwlr_layer_shell_v1 surface, so it needs a compositor implementing
  # that protocol. niri does; term.everything does not, so fuzzel is a client of
  # the nested niri rather than of the terminal compositor.
  runtime_deps = [
    glibc,
    fcft,
    fontconfig,
    libpng,
    libxkbcommon,
    pixman,
    wayland,
  ],

  cmd = "./build.sh",

  outputs = {
    bin = { glob = "usr/bin/fuzzel" } | OutputBin,
    config = { glob = "etc/xdg/fuzzel/**" } | OutputData,
    man = { glob = "usr/share/man/**" } | OutputData,
    completions = { glob = "usr/share/{zsh,fish,bash-completion}/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "fuzzel",
    } | Attrs,

  tests = {
    smoke =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          # Anything further needs a layer-shell compositor.
          ["fuzzel", "--version"],
        ],
      } | Test,
  },
} | BuildSpec
