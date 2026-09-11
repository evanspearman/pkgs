let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let make = import "../make/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
let xorgproto = import "../xorgproto/build.ncl" in

let glibc = import "../glibc/build.ncl" in
let libx11 = import "../libx11/build.ncl" in
let libxext = import "../libxext/build.ncl" in

let version = "1.1.7" in
{
  name = "libxxf86vm",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://xorg.freedesktop.org/archive/individual/lib/libXxf86vm-%{version}.tar.xz",
      sha256 = "ae50c0f669e0af5a67cc4cd0f54f21d64a64d2660af883e80e95d3fe51b945d8",
      extract = true,
      strip_prefix = "libXxf86vm-%{version}",
    } | Source,
    base,
    make,
    pkgconf,
    toolchain,
    xorgproto,
  ],
  runtime_deps = [
    glibc,
    libx11,
    libxext,
  ],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/libXxf86vm.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
    man = { glob = "usr/share/man/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "libxxf86vm",
    } | Attrs,
} | BuildSpec
