let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let cmake = import "../cmake/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let gcc = import "../gcc/build.ncl" in
let glibc = import "../glibc/build.ncl" in

let version = "12.1.0" in
{
  name = "fmt",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://github.com/fmtlib/fmt/archive/refs/tags/%{version}.tar.gz",
      sha256 = "ea7de4299689e12b6dddd392f9896f08fb0777ac7168897a244a6d6085043fea",
      extract = true,
      strip_prefix = "fmt-%{version}",
    } | Source,
    base,
    cmake,
    ninja,
    pkgconf,
    toolchain,
  ],
  runtime_deps = [glibc, gcc],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/libfmt.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
    cmake_data = { glob = "usr/lib/cmake/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "fmt",
      source_provenance = { category = 'GithubRepo, owner = "fmtlib", repo = "fmt" },
    } | Attrs,
} | BuildSpec
