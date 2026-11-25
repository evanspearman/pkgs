let { Attrs, BuildSpec, Local, OutputBin, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let glibc = import "../glibc/build.ncl" in

let version = "0.1.3" in
{
  name = "libxcvt",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://xorg.freedesktop.org/archive/individual/lib/libxcvt-%{version}.tar.xz",
      sha256 = "a929998a8767de7dfa36d6da4751cdbeef34ed630714f2f4a767b351f2442e01",
      extract = true,
      strip_prefix = "libxcvt-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
  ],
  runtime_deps = [glibc],

  cmd = "./build.sh",

  outputs = {
    cvt = { glob = "usr/bin/cvt" } | OutputBin,
    libs = { glob = "usr/lib/libxcvt.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "libxcvt",
    } | Attrs,
} | BuildSpec
