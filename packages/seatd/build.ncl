let { Attrs, BuildSpec, Local, OutputBin, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let glibc = import "../glibc/build.ncl" in

let version = "0.9.3" in
{
  name = "seatd",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      # Canonical development is at git.sr.ht/~kennylevinsen/seatd, but sr.ht
      # 403s the sandbox fetcher. This GitHub mirror's tag archive is
      # byte-identical to the sr.ht one -- same sha256, verified -- so it is the
      # same artifact by a reachable route. source_provenance is omitted rather
      # than pointed at the mirror.
      url = "https://github.com/kennylevinsen/seatd/archive/refs/tags/%{version}.tar.gz",
      sha256 = "302564d54d8e28191fadfd734f2675ecb0c9e0615a58011b89ef15dfa4dbaa96",
      extract = true,
      strip_prefix = "seatd-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
  ],
  runtime_deps = [glibc],

  cmd = "./build.sh",

  outputs = {
    seatd = { glob = "usr/bin/seatd" } | OutputBin,
    seatd-launch = { glob = "usr/bin/seatd-launch" } | OutputBin,
    libs = { glob = "usr/lib/libseat.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "seatd",
    } | Attrs,
} | BuildSpec
