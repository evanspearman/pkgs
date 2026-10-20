let { Attrs, BuildSpec, Local, OutputBin, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let glibc = import "../glibc/build.ncl" in
let wayland = import "../wayland/build.ncl" in

let version = "0.5.0" in
{
  name = "wlr-randr",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      # Canonical development is at git.sr.ht/~emersion/wlr-randr, but sr.ht
      # 403s the sandbox fetcher (see seatd), and the GitHub mirror stops at
      # 0.2.0. Debian's orig tarball is sr.ht's archive of the v0.5.0 tag,
      # hence the commit-suffixed top-level directory.
      url = "https://deb.debian.org/debian/pool/main/w/wlr-randr/wlr-randr_%{version}.orig.tar.gz",
      sha256 = "01aeaf1aef220486bee0fcb0d5a5658af91ae52440f10ce44b64bd8cfe477abf",
      extract = true,
      strip_prefix = "wlr-randr-v%{version}-7d06fafc35e2d951f251a89a05d414ee726cccfd",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
  ],
  runtime_deps = [
    glibc,
    wayland,
  ],

  cmd = "./build.sh",

  outputs = {
    wlr-randr = { glob = "usr/bin/wlr-randr" } | OutputBin,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "wlr-randr",
    } | Attrs,

  tests = {
    smoke =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          # Even --help connects to a compositor before parsing arguments, so
          # without one only presence can be checked here. minimal-display's
          # test runs it against a live headless cage.
          ["/bin/bash", "-c", "test -x /usr/bin/wlr-randr"],
        ],
      } | Test,
  },
} | BuildSpec
