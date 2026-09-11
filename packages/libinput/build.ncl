let { Attrs, BuildSpec, Local, OutputBin, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let python = import "../python/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let eudev = import "../eudev/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let libevdev = import "../libevdev/build.ncl" in
let mtdev = import "../mtdev/build.ncl" in

let version = "1.31.3" in
{
  name = "libinput",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://gitlab.freedesktop.org/libinput/libinput/-/archive/%{version}/libinput-%{version}.tar.gz",
      sha256 = "b6749bf6f1890f6631c0a70a027c35fec9d2e096a39f720548896e41474a9854",
      extract = true,
      strip_prefix = "libinput-%{version}",
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
    # Device discovery and property lookup.
    eudev,
    libevdev,
    mtdev,
  ],

  cmd = "./build.sh",

  outputs = {
    bins = { glob = "usr/bin/libinput" } | OutputBin,
    libs = { glob = "usr/lib/libinput.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
    udev_rules = { glob = "usr/lib/udev/**", allow_executable = true } | OutputData,
    # The libinput CLI dispatches to these helpers, and refuses to initialise a
    # device without the quirks database.
    libexec = { glob = "usr/libexec/libinput/**" } | OutputBin,
    quirks = { glob = "usr/share/libinput/**" } | OutputData,
    man = { glob = "usr/share/man/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "libinput",
    } | Attrs,
} | BuildSpec
