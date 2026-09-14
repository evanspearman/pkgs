let { Attrs, BuildSpec, Local, OutputBin, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let python = import "../python/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let glib = import "../glib/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let libjpeg-turbo = import "../libjpeg-turbo/build.ncl" in
let libpng = import "../libpng/build.ncl" in

let version = "2.42.12" in
{
  name = "gdk-pixbuf",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://download.gnome.org/sources/gdk-pixbuf/2.42/gdk-pixbuf-%{version}.tar.xz",
      sha256 = "b9505b3445b9a7e48ced34760c3bcb73e966df3ac94c95a148cb669ab748e3c7",
      extract = true,
      strip_prefix = "gdk-pixbuf-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    python,
    toolchain,
  ],
  runtime_deps = [
    glibc,
    glib,
    libjpeg-turbo,
    libpng,
  ],

  cmd = "./build.sh",

  outputs = {
    bins = { glob = "usr/bin/gdk-pixbuf-*" } | OutputBin,
    libs = { glob = "usr/lib/libgdk_pixbuf-2.0.so*" } | OutputLib,
    loaders = { glob = "usr/lib/gdk-pixbuf-2.0/**" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "LGPL-2.1-or-later",
      repology_project = "gdk-pixbuf",
    } | Attrs,
} | BuildSpec
