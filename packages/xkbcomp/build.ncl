let { Attrs, BuildSpec, Local, OutputBin, OutputData, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let make = import "../make/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
let xorgproto = import "../xorgproto/build.ncl" in

let glibc = import "../glibc/build.ncl" in
let libx11 = import "../libx11/build.ncl" in
let libxkbfile = import "../libxkbfile/build.ncl" in

let version = "1.5.0" in
{
  name = "xkbcomp",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://xorg.freedesktop.org/archive/individual/app/xkbcomp-%{version}.tar.xz",
      sha256 = "2ac31f26600776db6d9cd79b3fcd272263faebac7eb85fb2f33c7141b8486060",
      extract = true,
      strip_prefix = "xkbcomp-%{version}",
    } | Source,
    base,
    make,
    pkgconf,
    toolchain,
    xorgproto,
  ],
  # The X server execs xkbcomp at runtime to compile keymaps, and xkbcomp reads
  # its rules/symbols from xkeyboard-config's data. That data is a separate
  # package rather than a runtime_dep here: the path is baked in below, and
  # tying them together would make every xkbcomp consumer pull the full dataset.
  runtime_deps = [
    glibc,
    libx11,
    libxkbfile,
  ],

  cmd = "./build.sh",

  outputs = {
    bin = { glob = "usr/bin/xkbcomp" } | OutputBin,
    man = { glob = "usr/share/man/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "xkbcomp",
    } | Attrs,

  tests = {
    smoke =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          # xkbcomp has no --version; -help exits non-zero by design, so just
          # prove the binary loads and links.
          ["/bin/bash", "-c", "xkbcomp -help 2>&1 | grep -q Usage"],
        ],
      } | Test,
  },
} | BuildSpec
