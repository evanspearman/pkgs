let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let python = import "../python/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let atkmm = import "../atkmm/build.ncl" in
let cairomm = import "../cairomm/build.ncl" in
let gcc = import "../gcc/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let glibmm = import "../glibmm/build.ncl" in
let gtk3 = import "../gtk3/build.ncl" in
let pangomm = import "../pangomm/build.ncl" in

# The 3.24 series, providing `gtkmm-3.0`. gtkmm 4.x is a separate ABI against
# GTK 4 and glibmm-2.68; waybar asks for gtkmm-3.0 specifically.
let version = "3.24.11" in
{
  name = "gtkmm",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://download.gnome.org/sources/gtkmm/3.24/gtkmm-%{version}.tar.xz",
      sha256 = "19e383c82d5dd89db275e00b82864e90414d4c3fb3d100b2f996bcc2338a4cc7",
      extract = true,
      strip_prefix = "gtkmm-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    python,
    toolchain,
  ],
  runtime_deps = [glibc, gcc, atkmm, cairomm, glibmm, gtk3, pangomm],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/lib{gtkmm,gdkmm}-3.0.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    libconfig = { glob = "usr/lib/{gtkmm,gdkmm}-3.0/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "LGPL-2.1-or-later",
      repology_project = "gtkmm",
    } | Attrs,
} | BuildSpec
