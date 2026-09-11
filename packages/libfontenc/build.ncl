let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let make = import "../make/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
let xorgproto = import "../xorgproto/build.ncl" in

let font-util = import "../font-util/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let zlib = import "../zlib/build.ncl" in

let version = "1.1.9" in
{
  name = "libfontenc",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://xorg.freedesktop.org/archive/individual/lib/libfontenc-%{version}.tar.xz",
      sha256 = "9d8392705cb10803d5fe1d27d236cbab3f664e26841ce01916bbbe430cf273e2",
      extract = true,
      strip_prefix = "libfontenc-%{version}",
    } | Source,
    base,
    make,
    pkgconf,
    toolchain,
    xorgproto,
    # Supplies the encodingsdir that configure probes for via fontutil.pc.
    font-util,
  ],
  runtime_deps = [
    glibc,
    # libfontenc reads gzipped encoding tables directly.
    zlib,
  ],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/libfontenc.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "libfontenc",
    } | Attrs,
} | BuildSpec
