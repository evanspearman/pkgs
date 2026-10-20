let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let glibc = import "../glibc/build.ncl" in

# The main loop library under neatvnc and wayvnc; both pin aml >=1.0.0 <2.0.0.
let version = "1.0.0" in
{
  name = "aml",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://github.com/any1/aml/archive/refs/tags/v%{version}.tar.gz",
      sha256 = "b2b8f743213af39f40e8bc611147d69e2ea9e010b9b19cb65246582338f28d96",
      extract = true,
      strip_prefix = "aml-%{version}",
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
    libs = { glob = "usr/lib/libaml*.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "ISC",
      repology_project = "aml",
      source_provenance = {
        category = 'GithubRepo,
        owner = "any1",
        repo = "aml",
      },
    } | Attrs,
} | BuildSpec
