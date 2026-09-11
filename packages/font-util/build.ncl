let { Attrs, BuildSpec, Local, OutputBin, OutputData, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let make = import "../make/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let glibc = import "../glibc/build.ncl" in

let version = "1.4.2" in
{
  name = "font-util",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://xorg.freedesktop.org/archive/individual/font/font-util-%{version}.tar.xz",
      sha256 = "02e4f8afdcf03cc8372ca9c37aa104b1e36b47722dbc79531be08f0a4c622999",
      extract = true,
      strip_prefix = "font-util-%{version}",
    } | Source,
    base,
    make,
    pkgconf,
    toolchain,
  ],
  runtime_deps = [glibc],

  cmd = "./build.sh",

  outputs = {
    bdftruncate = { glob = "usr/bin/bdftruncate" } | OutputBin,
    ucs2any = { glob = "usr/bin/ucs2any" } | OutputBin,

    # The encoding tables and the fontutil.m4 macros are the reason anything
    # depends on this package; the two binaries above are incidental.
    encodings = { glob = "usr/share/fonts/X11/util/**" } | OutputData,
    aclocals = { glob = "usr/share/aclocal/*" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "font-util",
    } | Attrs,
} | BuildSpec
