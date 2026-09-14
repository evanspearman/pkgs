let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let cairomm = import "../cairomm/build.ncl" in
let glibmm = import "../glibmm/build.ncl" in
let pango = import "../pango/build.ncl" in
let gcc = import "../gcc/build.ncl" in
let glibc = import "../glibc/build.ncl" in

# The 2.46 series, which provides `pangomm-1.4` against glibmm-2.4.
let version = "2.46.5" in
{
  name = "pangomm",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://download.gnome.org/sources/pangomm/2.46/pangomm-%{version}.tar.xz",
      sha256 = "38ca0b050b065de4e3da0c182df657437757063bbf0c4b6c9567ddba019b1d68",
      extract = true,
      strip_prefix = "pangomm-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
  ],
  runtime_deps = [glibc, gcc, cairomm, glibmm, pango],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/libpangomm-1.4.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    # The generated *config.h is arch-dependent, so it installs under libdir.
    libconfig = { glob = "usr/lib/pangomm-*/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "LGPL-2.1-or-later",
      repology_project = "pangomm",
    } | Attrs,
} | BuildSpec
