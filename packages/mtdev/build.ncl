let { Attrs, BuildSpec, Local, OutputBin, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let make = import "../make/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let glibc = import "../glibc/build.ncl" in

let version = "1.1.7" in
{
  name = "mtdev",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://bitmath.org/code/mtdev/mtdev-%{version}.tar.bz2",
      sha256 = "a107adad2101fecac54ac7f9f0e0a0dd155d954193da55c2340c97f2ff1d814e",
      extract = true,
      strip_prefix = "mtdev-%{version}",
    } | Source,
    base,
    make,
    pkgconf,
    toolchain,
  ],
  runtime_deps = [glibc],

  cmd = "./build.sh",

  outputs = {
    bin = { glob = "usr/bin/mtdev-test" } | OutputBin,
    libs = { glob = "usr/lib/libmtdev.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "mtdev",
    } | Attrs,
} | BuildSpec
