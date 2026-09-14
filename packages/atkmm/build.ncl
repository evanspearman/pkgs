let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let atk = import "../atk/build.ncl" in
let glibmm = import "../glibmm/build.ncl" in
let gcc = import "../gcc/build.ncl" in
let glibc = import "../glibc/build.ncl" in

# The 2.28 series, which provides `atkmm-1.6` against glibmm-2.4.
let version = "2.28.5" in
{
  name = "atkmm",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://download.gnome.org/sources/atkmm/2.28/atkmm-%{version}.tar.xz",
      sha256 = "ae449192a582a2582a95e0602b15d792bbd639e836339b81ef916aa87540ac5c",
      extract = true,
      strip_prefix = "atkmm-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
  ],
  runtime_deps = [glibc, gcc, atk, glibmm],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/libatkmm-1.6.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    # The generated *config.h is arch-dependent, so it installs under libdir.
    libconfig = { glob = "usr/lib/atkmm-*/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "LGPL-2.1-or-later",
      repology_project = "atkmm",
    } | Attrs,
} | BuildSpec
