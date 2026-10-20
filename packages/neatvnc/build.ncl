let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let aml = import "../aml/build.ncl" in
let glibc = import "../glibc/build.ncl" in
# Headers only: neatvnc takes libdrm's fourcc definitions at compile time and
# links it only for h264, which this build disables.
let libdrm = import "../libdrm/build.ncl" in
let libjpeg-turbo = import "../libjpeg-turbo/build.ncl" in
let pixman = import "../pixman/build.ncl" in
let zlib = import "../zlib/build.ncl" in

# wayvnc 0.10 pins neatvnc >=1.0.0 <2.0.0.
let version = "1.0.3" in
{
  name = "neatvnc",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://github.com/any1/neatvnc/archive/refs/tags/v%{version}.tar.gz",
      sha256 = "7a54d1b950f8898ea4be0f9b0e0d3ab4065812a8f6517707a8e02a384fe9af4a",
      extract = true,
      strip_prefix = "neatvnc-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
    libdrm,
  ],
  runtime_deps = [
    glibc,
    aml,
    # The RFB server's framebuffer and damage tracking are pixman regions.
    pixman,
    # zlib backs the ZRLE encoding; libturbojpeg backs Tight.
    zlib,
    libjpeg-turbo,
  ],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/libneatvnc.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "ISC",
      repology_project = "neatvnc",
      source_provenance = {
        category = 'GithubRepo,
        owner = "any1",
        repo = "neatvnc",
      },
    } | Attrs,
} | BuildSpec
