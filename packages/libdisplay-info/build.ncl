let { Attrs, BuildSpec, Local, OutputBin, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let hwdata = import "../hwdata/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let python = import "../python/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let glibc = import "../glibc/build.ncl" in

# Pinned below 0.4: niri (and other smithay consumers) require
# `libdisplay-info < 0.4.0`, whose ABI changed at that boundary.
let version = "0.3.0" in
{
  name = "libdisplay-info",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://gitlab.freedesktop.org/emersion/libdisplay-info/-/releases/%{version}/downloads/libdisplay-info-%{version}.tar.xz",
      sha256 = "6ae77cd937f9cf7d1321d35c116062c4911e8447010a6a713ac4286f7a9d5987",
      extract = true,
      strip_prefix = "libdisplay-info-%{version}",
    } | Source,
    base,
    # The PNP vendor table is generated at build time from hwdata's pnp.ids.
    hwdata,
    meson,
    ninja,
    pkgconf,
    python,
    toolchain,
  ],
  runtime_deps = [glibc],

  cmd = "./build.sh",

  outputs = {
    bins = { glob = "usr/bin/di-*" } | OutputBin,
    libs = { glob = "usr/lib/libdisplay-info.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "libdisplay-info",
    } | Attrs,
} | BuildSpec
