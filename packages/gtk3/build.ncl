let { Attrs, BuildSpec, Local, OutputBin, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let python = import "../python/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
let wayland-protocols = import "../wayland-protocols/build.ncl" in

let at-spi2-core = import "../at-spi2-core/build.ncl" in
let atk = import "../atk/build.ncl" in
let cairo = import "../cairo/build.ncl" in
let fribidi = import "../fribidi/build.ncl" in
let gdk-pixbuf = import "../gdk-pixbuf/build.ncl" in
let glib = import "../glib/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let libepoxy = import "../libepoxy/build.ncl" in
let libxkbcommon = import "../libxkbcommon/build.ncl" in
let pango = import "../pango/build.ncl" in
let wayland = import "../wayland/build.ncl" in

# The 3.24 series. gtkmm-3.0, gtk-layer-shell and waybar are all GTK 3
# consumers; GTK 4 is a parallel install, not an upgrade path for them.
let version = "3.24.43" in
{
  name = "gtk3",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://download.gnome.org/sources/gtk+/3.24/gtk+-%{version}.tar.xz",
      sha256 = "7e04f0648515034b806b74ae5d774d87cffb1a2a96c468cb5be476d51bf2f3c7",
      extract = true,
      strip_prefix = "gtk+-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    python,
    toolchain,
    # Supplies the XML the Wayland backend generates its protocol bindings from.
    wayland-protocols,
  ],
  runtime_deps = [
    glibc,
    at-spi2-core,
    atk,
    cairo,
    fribidi,
    gdk-pixbuf,
    glib,
    # GL dispatch for the GskGL / GdkGLContext paths.
    libepoxy,
    libxkbcommon,
    pango,
    wayland,
  ],

  cmd = "./build.sh",

  outputs = {
    bins = { glob = "usr/bin/gtk*" } | OutputBin,
    libs = { glob = "usr/lib/lib{gtk,gdk}-3.so*" } | OutputLib,
    modules = { glob = "usr/lib/gtk-3.0/**" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
    # Icons, the default theme and the settings schema, all read at runtime.
    sharedata = { glob = "usr/share/{gtk-3.0,themes,icons,glib-2.0}/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "LGPL-2.1-or-later",
      repology_project = "gtk3",
    } | Attrs,
} | BuildSpec
