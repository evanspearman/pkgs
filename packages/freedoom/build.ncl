let { Attrs, BuildSpec, Local, OutputData, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let unzip = import "../unzip/build.ncl" in

# Open game data for Doom engines: Phase 1 (freedoom1.wad, Doom-compatible)
# and Phase 2 (freedoom2.wad, Doom II-compatible).
#
# Packaged from the release zip, not built from source: the release is game
# data (WADs), not a program, and building it needs deutex and Python's
# imaging library, which are not packaged. The zip's sha256 matches upstream's
# published freedoom-0.13.0-CHECKSUM.
let version = "0.13.0" in
{
  name = "freedoom",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://github.com/freedoom/freedoom/releases/download/v%{version}/freedoom-%{version}.zip",
      sha256 = "3f9b264f3e3ce503b4fb7f6bdcb1f419d93c7b546f4df3e874dd878db9688f59",
    } | Source,
    base,
    unzip,
  ],
  runtime_deps = [],

  cmd = "./build.sh",
  build_args = { include version },

  outputs = {
    wads = { glob = "usr/share/games/doom/*.wad" } | OutputData,
    docs = { glob = "usr/share/doc/freedoom/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "BSD-3-Clause",
      repology_project = "freedoom",
      source_provenance = {
        category = 'GithubRepo,
        owner = "freedoom",
        repo = "freedoom",
      },
    } | Attrs,
} | BuildSpec
