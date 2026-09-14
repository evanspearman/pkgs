let { Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let cmake = import "../cmake/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let fmt = import "../fmt/build.ncl" in
let gcc = import "../gcc/build.ncl" in
let glibc = import "../glibc/build.ncl" in

let version = "1.16.0" in
{
  name = "spdlog",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://github.com/gabime/spdlog/archive/refs/tags/v%{version}.tar.gz",
      sha256 = "8741753e488a78dd0d0024c980e1fb5b5c85888447e309d9cb9d949bdb52aa3e",
      extract = true,
      strip_prefix = "spdlog-%{version}",
    } | Source,
    base,
    cmake,
    ninja,
    pkgconf,
    toolchain,
  ],
  # Built with SPDLOG_FMT_EXTERNAL, so it links the packaged fmt rather than the
  # copy it bundles. Consumers that also use fmt directly -- waybar does -- would
  # otherwise end up with two incompatible fmt versions in one binary.
  runtime_deps = [glibc, gcc, fmt],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/libspdlog.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
    cmake_data = { glob = "usr/lib/cmake/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "spdlog",
      source_provenance = { category = 'GithubRepo, owner = "gabime", repo = "spdlog" },
    } | Attrs,
} | BuildSpec
