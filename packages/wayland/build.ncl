let { Attrs, BuildSpec, Local, OutputBin, OutputData, OutputLib, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let expat = import "../expat/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let libffi = import "../libffi/build.ncl" in
let libxml2 = import "../libxml2/build.ncl" in

let version = "1.26.0" in
{
  name = "wayland",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://gitlab.freedesktop.org/wayland/wayland/-/releases/%{version}/downloads/wayland-%{version}.tar.xz",
      sha256 = "64176eaa46e4969903e286f8e5ef8331affc17fdf03ac9b58381d2b23162b7a3",
      extract = true,
      strip_prefix = "wayland-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
  ],
  runtime_deps = [
    glibc,
    # libffi backs the wire-format argument marshalling in libwayland-{client,server}.
    libffi,
    # expat parses the protocol XML in wayland-scanner; libxml2 is only used for
    # its optional DTD validation of that same XML.
    expat,
    libxml2,
  ],

  cmd = "./build.sh",

  outputs = {
    scanner = { glob = "usr/bin/wayland-scanner" } | OutputBin,
    libs = { glob = "usr/lib/libwayland-*.so*" } | OutputLib,

    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
    # wayland-scanner.mo / wayland.dtd, plus the aclocal macro consumers expect.
    datafiles = { glob = "usr/share/wayland/**" } | OutputData,
    aclocals = { glob = "usr/share/aclocal/*" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "wayland",
    } | Attrs,

  tests = {
    smoke =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          ["wayland-scanner", "--version"],
        ],
      } | Test,
  },
} | BuildSpec
