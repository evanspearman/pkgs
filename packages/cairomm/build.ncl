let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let cairo = import "../cairo/build.ncl" in
let libsigcpp = import "../libsigcpp/build.ncl" in
let gcc = import "../gcc/build.ncl" in
let glibc = import "../glibc/build.ncl" in

# The 1.14 series, which provides `cairomm-1.0`. cairomm 1.16+ installs
# `cairomm-1.16` against libsigc++ 3, which gtkmm-3 cannot link.
let version = "1.14.6" in
{
  name = "cairomm",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://www.cairographics.org/releases/cairomm-%{version}.tar.xz",
      sha256 = "7e0d5c7f29175d573a03ab5c45aef63f48dd91a5caf335a404cd763e4b7cea4a",
      extract = true,
      strip_prefix = "cairomm-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
  ],
  runtime_deps = [glibc, gcc, cairo, libsigcpp],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/libcairomm-1.0.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    # The generated *config.h is arch-dependent, so it installs under libdir.
    libconfig = { glob = "usr/lib/cairomm-*/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "LGPL-2.1-or-later",
      repology_project = "cairomm",
    } | Attrs,
} | BuildSpec
