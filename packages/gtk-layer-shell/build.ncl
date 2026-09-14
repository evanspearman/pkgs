let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
let wayland-protocols = import "../wayland-protocols/build.ncl" in

let glibc = import "../glibc/build.ncl" in
let gtk3 = import "../gtk3/build.ncl" in
let wayland = import "../wayland/build.ncl" in

let version = "0.10.1" in
{
  name = "gtk-layer-shell",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://github.com/wmww/gtk-layer-shell/archive/refs/tags/v%{version}.tar.gz",
      sha256 = "88c3a3e0a5300532f3d368d5df64838a87f1fb85273f22d41df0a6b8d0ec59c6",
      extract = true,
      strip_prefix = "gtk-layer-shell-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
    wayland-protocols,
  ],
  # Drives zwlr_layer_shell_v1, so it only works under a compositor that
  # implements that protocol. niri does; term.everything does not, which is why
  # waybar has to be a client of the nested niri rather than of the terminal
  # compositor itself.
  runtime_deps = [glibc, gtk3, wayland],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/libgtk-layer-shell.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "gtk-layer-shell",
      source_provenance = {
        category = 'GithubRepo,
        owner = "wmww",
        repo = "gtk-layer-shell",
      },
    } | Attrs,
} | BuildSpec
