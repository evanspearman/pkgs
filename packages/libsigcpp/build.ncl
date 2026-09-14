let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let gcc = import "../gcc/build.ncl" in
let glibc = import "../glibc/build.ncl" in

# The 2.x series, deliberately. gtkmm-3.0 and glibmm-2.4 both link
# `sigc++-2.0`; libsigc++ 3.x installs a parallel `sigc++-3.0` they cannot use.
let version = "2.12.1" in
{
  name = "libsigcpp",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://download.gnome.org/sources/libsigc++/2.12/libsigc++-%{version}.tar.xz",
      sha256 = "a9dbee323351d109b7aee074a9cb89ca3e7bcf8ad8edef1851f4cf359bd50843",
      extract = true,
      strip_prefix = "libsigc++-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
  ],
  runtime_deps = [glibc, gcc],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/libsigc-2.0.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    # sigc++config.h is arch-dependent and lands under libdir.
    libconfig = { glob = "usr/lib/sigc++-2.0/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "LGPL-3.0-or-later",
      repology_project = "libsigc++",
    } | Attrs,
} | BuildSpec
