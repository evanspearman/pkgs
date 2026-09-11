let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
let xorgproto = import "../xorgproto/build.ncl" in

let glibc = import "../glibc/build.ncl" in
let libx11 = import "../libx11/build.ncl" in

let version = "1.2.0" in
{
  name = "libxkbfile",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://xorg.freedesktop.org/archive/individual/lib/libxkbfile-%{version}.tar.xz",
      sha256 = "7f71884e5faf56fb0e823f3848599cf9b5a9afce51c90982baeb64f635233ebf",
      extract = true,
      strip_prefix = "libxkbfile-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
    xorgproto,
  ],
  runtime_deps = [
    glibc,
    libx11,
  ],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/libxkbfile.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "libxkbfile",
    } | Attrs,
} | BuildSpec
