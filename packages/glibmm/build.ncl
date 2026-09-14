let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let glib = import "../glib/build.ncl" in
let libsigcpp = import "../libsigcpp/build.ncl" in
let gcc = import "../gcc/build.ncl" in
let glibc = import "../glibc/build.ncl" in

# The 2.66 series is what provides `glibmm-2.4` / `giomm-2.4`, the ABI gtkmm-3
# and waybar ask for. Later glibmm installs `glibmm-2.68`, which they cannot use.
let version = "2.66.10" in
{
  name = "glibmm",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://download.gnome.org/sources/glibmm/2.66/glibmm-%{version}.tar.xz",
      sha256 = "2b61780203aed98e701d3ea57c8f353e7c8ada9706a79be782f6c5153dd035c0",
      extract = true,
      strip_prefix = "glibmm-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
  ],
  runtime_deps = [glibc, gcc, glib, libsigcpp],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/lib{glibmm,giomm,glibmm_generate_extra_defs}-2.4.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    # The *config.h headers are arch-dependent, so they install under libdir.
    libconfig = { glob = "usr/lib/{glibmm,giomm}-2.4/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "LGPL-2.1-or-later",
      repology_project = "glibmm",
    } | Attrs,
} | BuildSpec
