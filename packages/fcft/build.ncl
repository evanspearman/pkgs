let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let fontconfig = import "../fontconfig/build.ncl" in
let freetype = import "../freetype/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let harfbuzz = import "../harfbuzz/build.ncl" in
let pixman = import "../pixman/build.ncl" in
let tllist = import "../tllist/build.ncl" in
let utf8proc = import "../utf8proc/build.ncl" in

# Pinned to the 3.x series: fuzzel and foot both require `>=3.3.1, <4.0.0`.
let version = "3.3.3" in
{
  name = "fcft",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://codeberg.org/dnkl/fcft/releases/download/%{version}/fcft-%{version}.tar.gz",
      sha256 = "bb298772d625e7d917373d541456f34f1957a9e22b16f17f64158b2c3816563c",
      extract = true,
      strip_prefix = "fcft-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
    # Header-only, so it is a build-time dep only.
    tllist,
  ],
  runtime_deps = [
    glibc,
    fontconfig,
    freetype,
    # Grapheme clustering and shaping, via -Dtext-shaping=enabled.
    harfbuzz,
    utf8proc,
    pixman,
  ],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/libfcft.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "fcft",
    } | Attrs,
} | BuildSpec
