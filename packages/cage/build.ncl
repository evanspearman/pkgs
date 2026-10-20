let { Attrs, BuildSpec, Local, OutputBin, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
let wayland-protocols = import "../wayland-protocols/build.ncl" in

let glibc = import "../glibc/build.ncl" in
let libxkbcommon = import "../libxkbcommon/build.ncl" in
let wayland = import "../wayland/build.ncl" in
let wlroots = import "../wlroots/build.ncl" in

let version = "0.3.1" in
{
  name = "cage",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://github.com/cage-kiosk/cage/releases/download/v%{version}/cage-%{version}.tar.gz",
      sha256 = "edafc173b6f56a3e1564933e272a54aaa9fe158d330e6a415d57b44ab880fe2b",
      extract = true,
      strip_prefix = "cage-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
    # wlroots' public headers include generated protocol headers whose XML
    # comes from here.
    wayland-protocols,
  ],
  runtime_deps = [
    glibc,
    libxkbcommon,
    wayland,
    wlroots,
  ],

  cmd = "./build.sh",

  outputs = {
    cage = { glob = "usr/bin/cage" } | OutputBin,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "cage",
      source_provenance = {
        category = 'GithubRepo,
        owner = "cage-kiosk",
        repo = "cage",
      },
    } | Attrs,

  tests = {
    smoke =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          ["cage", "-v"],
        ],
      } | Test,
  },
} | BuildSpec
