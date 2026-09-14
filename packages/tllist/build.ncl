let { Attrs, BuildSpec, Local, OutputData, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let version = "1.1.0" in
{
  name = "tllist",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      # Signed release tarball rather than the Forgejo auto-archive: the
      # auto-archive is generated on request and unpacks to a bare `tllist/`,
      # while this is a stable artifact with a versioned root.
      url = "https://codeberg.org/dnkl/tllist/releases/download/%{version}/tllist-%{version}.tar.gz",
      sha256 = "a1f0ce0dc4fcb4ce59c37202a1d914c853a8bd2d7c5d57d623b15a8dd9778767",
      extract = true,
      strip_prefix = "tllist-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    # Header-only, but meson still probes a C compiler and its linker.
    toolchain,
  ],
  # A header-only typed linked list. Nothing links it, so there is nothing to
  # depend on at runtime -- consumers inline it at compile time.
  runtime_deps = [],

  cmd = "./build.sh",

  outputs = {
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "tllist",
    } | Attrs,
} | BuildSpec
