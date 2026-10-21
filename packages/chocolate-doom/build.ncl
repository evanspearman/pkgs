let { Attrs, BuildSpec, Local, OutputBin, OutputData, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let cmake = import "../cmake/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let glibc = import "../glibc/build.ncl" in
let libpng = import "../libpng/build.ncl" in
let sdl2 = import "../sdl2/build.ncl" in

# A faithful Doom source port: the original software renderer, so it runs
# fine with no GPU. It needs game data; freedoom provides an open one.
let version = "3.1.1" in
{
  name = "chocolate-doom",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://github.com/chocolate-doom/chocolate-doom/archive/refs/tags/chocolate-doom-%{version}.tar.gz",
      sha256 = "1edcc41254bdc194beb0d33e267fae306556c4d24110a1d3d3f865717f25da23",
      extract = true,
      strip_prefix = "chocolate-doom-chocolate-doom-%{version}",
    } | Source,
    base,
    cmake,
    ninja,
    pkgconf,
    toolchain,
  ],
  runtime_deps = [
    glibc,
    # PNG screenshots.
    libpng,
    sdl2,
  ],

  cmd = "./build.sh",

  outputs = {
    chocolate-doom = { glob = "usr/bin/chocolate-doom" } | OutputBin,
    chocolate-setup = { glob = "usr/bin/chocolate-{,doom-}setup" } | OutputBin,
    icons = { glob = "usr/share/icons/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "GPL-2.0-or-later",
      repology_project = "chocolate-doom",
      source_provenance = {
        category = 'GithubRepo,
        owner = "chocolate-doom",
        repo = "chocolate-doom",
      },
    } | Attrs,

  tests = {
    smoke =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          ["chocolate-doom", "-version"],
        ],
      } | Test,
  },
} | BuildSpec
