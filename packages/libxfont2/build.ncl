let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let make = import "../make/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
let xorgproto = import "../xorgproto/build.ncl" in
let xtrans = import "../xtrans/build.ncl" in

let freetype = import "../freetype/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let libfontenc = import "../libfontenc/build.ncl" in
let zlib = import "../zlib/build.ncl" in

let version = "2.0.9" in
{
  name = "libxfont2",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://xorg.freedesktop.org/archive/individual/lib/libXfont2-%{version}.tar.xz",
      sha256 = "f042a370666815e7b941e9b7019024755bd1c6c2954afbfa515af378251799e2",
      extract = true,
      strip_prefix = "libXfont2-%{version}",
    } | Source,
    base,
    make,
    pkgconf,
    toolchain,
    xorgproto,
    # Header-only package; needed for the transport layer used by the font server
    # code paths, even though we build with --disable-fontserver-transport.
    xtrans,
  ],
  runtime_deps = [
    glibc,
    freetype,
    libfontenc,
    zlib,
  ],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/libXfont2.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "libxfont",
    } | Attrs,
} | BuildSpec
