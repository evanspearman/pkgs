let { Attrs, BuildSpec, Local, OutputBin, OutputData, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let make = import "../make/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let glibc = import "../glibc/build.ncl" in

let version = "1.11.2" in
{
  name = "scdoc",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      # Upstream develops at git.sr.ht/~sircmpwn/scdoc, but sr.ht 403s the
      # sandbox fetcher. This is the author's own Codeberg mirror; its tree is
      # identical to the sr.ht archive for this tag (verified by diff -- the
      # archives differ only in their root directory name, which is why the
      # sha256 differs and strip_prefix is a bare "scdoc").
      # source_provenance is omitted rather than pointed at a mirror.
      url = "https://codeberg.org/ddevault/scdoc/archive/%{version}.tar.gz",
      sha256 = "1fcdf0f19dc21a6d6500c896af0828178e4faf087ba069759509181223e2e504",
      extract = true,
      strip_prefix = "scdoc",
    } | Source,
    base,
    make,
    pkgconf,
    toolchain,
  ],
  runtime_deps = [glibc],

  cmd = "./build.sh",

  outputs = {
    bin = { glob = "usr/bin/scdoc" } | OutputBin,
    # Consumers locate the binary through this .pc file's `scdoc` variable
    # rather than off PATH, so it is not optional.
    pkgconfigs = { glob = "usr/share/pkgconfig/*.pc" } | OutputData,
    man = { glob = "usr/share/man/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "scdoc",
    } | Attrs,

  tests = {
    smoke =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          ["/bin/bash", "-c", "printf 'test(1)\\n\\n# NAME\\n\\ntest\\n' | scdoc | grep -q '.TH'"],
        ],
      } | Test,
  },
} | BuildSpec
