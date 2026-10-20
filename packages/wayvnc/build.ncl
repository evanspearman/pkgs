let { Attrs, BuildSpec, Local, OutputBin, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
let wayland-protocols = import "../wayland-protocols/build.ncl" in

let aml = import "../aml/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let jansson = import "../jansson/build.ncl" in
let libdrm = import "../libdrm/build.ncl" in
let libxkbcommon = import "../libxkbcommon/build.ncl" in
let neatvnc = import "../neatvnc/build.ncl" in
let pixman = import "../pixman/build.ncl" in
let wayland = import "../wayland/build.ncl" in

let version = "0.10.2" in
{
  name = "wayvnc",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://github.com/any1/wayvnc/archive/refs/tags/v%{version}.tar.gz",
      sha256 = "a85c6556a249b631551213f1e0fc20861458aea381996fd30a11fea431a465f9",
      extract = true,
      strip_prefix = "wayvnc-%{version}",
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
    aml,
    # The control socket (wayvncctl) speaks JSON.
    jansson,
    libdrm,
    # Builds the keymap it injects key events through.
    libxkbcommon,
    neatvnc,
    pixman,
    wayland,
  ],

  cmd = "./build.sh",

  outputs = {
    wayvnc = { glob = "usr/bin/wayvnc" } | OutputBin,
    wayvncctl = { glob = "usr/bin/wayvncctl" } | OutputBin,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "ISC",
      repology_project = "wayvnc",
      source_provenance = {
        category = 'GithubRepo,
        owner = "any1",
        repo = "wayvnc",
      },
    } | Attrs,

  tests = {
    smoke =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          ["wayvnc", "--version"],
          ["wayvncctl", "--version"],
        ],
      } | Test,
  },
} | BuildSpec
