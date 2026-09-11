let { Attrs, BuildSpec, Local, OutputBin, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let go = import "../go/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let chafa = import "../chafa/build.ncl" in
let glib = import "../glib/build.ncl" in
let glibc = import "../glibc/build.ncl" in

let version = "0.7.8" in
{
  name = "term.everything",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://github.com/mmulet/term.everything/archive/refs/tags/%{version}.tar.gz",
      sha256 = "1dff4339c60b1bc0782b955c9e486163241077c0c48b56b92d4afd444da4f61a",
      extract = true,
      strip_prefix = "term.everything-%{version}",
    } | Source,
    base,
    go,
    # cgo shells out to pkg-config to resolve `chafa` and `glib-2.0`.
    pkgconf,
    toolchain,
  ],
  # cgo links libchafa/libglib, so both ride along at runtime. The Wayland
  # compositor itself is implemented in pure Go, so there is no libwayland dep.
  runtime_deps = [
    chafa,
    glib,
    glibc,
  ],

  cmd = "./build.sh",
  build_args = {
    include version,
  },

  outputs = {
    bin = { glob = "usr/bin/term.everything" } | OutputBin,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "AGPL-3.0-only",
      repology_project = "term.everything",
      source_provenance = {
        category = 'GithubRepo,
        owner = "mmulet",
        repo = "term.everything",
      },
    } | Attrs,

  tests = {
    smoke =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          # Everything past argument parsing needs a real terminal and a GUI
          # app to host, so the smoke test stops at the flags that exit early.
          # Note `--version` reports 0.7.6 at the 0.7.8 tag: upstream's version
          # string is an untagged `const` in termeverything/ParseArgs.go that
          # was not bumped, and a const cannot be stamped via -ldflags -X.
          ["term.everything", "--version"],
          ["term.everything", "--help"],
        ],
      } | Test,
  },
} | BuildSpec
