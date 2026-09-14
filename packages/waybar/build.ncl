let { Attrs, BuildSpec, Local, OutputBin, OutputData, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
let wayland-protocols = import "../wayland-protocols/build.ncl" in

let eudev = import "../eudev/build.ncl" in
let fmt = import "../fmt/build.ncl" in
let gcc = import "../gcc/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let glibmm = import "../glibmm/build.ncl" in
let gtk-layer-shell = import "../gtk-layer-shell/build.ncl" in
let gtkmm = import "../gtkmm/build.ncl" in
let jsoncpp = import "../jsoncpp/build.ncl" in
let libxkbcommon = import "../libxkbcommon/build.ncl" in
let spdlog = import "../spdlog/build.ncl" in
let wayland = import "../wayland/build.ncl" in

let version = "0.15.0" in
{
  name = "waybar",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://github.com/Alexays/Waybar/archive/refs/tags/%{version}.tar.gz",
      sha256 = "21c2bbef88c40473c355003582f9331d2f9b8a01efdcce0935edfc5f6b023a3e",
      extract = true,
      strip_prefix = "Waybar-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
    wayland-protocols,
  ],
  runtime_deps = [
    glibc,
    gcc,
    eudev,
    fmt,
    # giomm-2.4 / sigc++-2.0 come through here.
    glibmm,
    # The bar is a zwlr_layer_shell_v1 surface; this is what drives it.
    gtk-layer-shell,
    gtkmm,
    jsoncpp,
    # For the `xkbregistry` dependency behind the keyboard-state module.
    libxkbcommon,
    spdlog,
    wayland,
  ],

  cmd = "./build.sh",

  outputs = {
    bin = { glob = "usr/bin/waybar" } | OutputBin,
    config = { glob = "etc/xdg/waybar/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "waybar",
      source_provenance = {
        category = 'GithubRepo,
        owner = "Alexays",
        repo = "Waybar",
      },
    } | Attrs,

  tests = {
    smoke =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          # Anything past argument parsing wants a layer-shell compositor.
          ["waybar", "--version"],
          ["waybar", "--help"],
        ],
      } | Test,
  },
} | BuildSpec
