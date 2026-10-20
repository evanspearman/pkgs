let { Attrs, BuildSpec, Local, OutputData, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
# wayland-scanner generates the <wayland-protocols/*-enum.h> headers; without
# it meson silently skips them, and wlroots 0.20 includes them.
let wayland = import "../wayland/build.ncl" in

let version = "1.49" in
{
  name = "wayland-protocols",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/%{version}/downloads/wayland-protocols-%{version}.tar.xz",
      sha256 = "ec4c8f74942d6dff7ace8b4ce4764f0ef9ff618a935d974ea77edee2ad240b14",
      extract = true,
      strip_prefix = "wayland-protocols-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    wayland,
  ],
  # Pure data: XML protocol definitions, generated enum headers, and a .pc file
  # whose `pkgdatadir` variable is how consumers locate them. Nothing is linked,
  # so there is no runtime dependency (not even libwayland).
  runtime_deps = [],

  cmd = "./build.sh",

  outputs = {
    protocols = { glob = "usr/share/wayland-protocols/**" } | OutputData,
    includes = { glob = "usr/include/wayland-protocols/**" } | OutputData,
    pkgconfigs = { glob = "usr/share/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "wayland-protocols",
    } | Attrs,
} | BuildSpec
