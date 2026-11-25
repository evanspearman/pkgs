let { Attrs, BuildSpec, Local, Needs, OutputBin, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let detbuild = import "../detbuild/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let rust = import "../rust/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let bindgen = import "../bindgen/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let lz4 = import "../lz4/build.ncl" in
let mesa = import "../mesa/build.ncl" in
let openssh = import "../openssh/build.ncl" in
let zstd = import "../zstd/build.ncl" in

let version = "0.11.3" in
{
  name = "waypipe",
  # Transparent proxy for Wayland clients: run on the box, display on the other
  # end of an ssh connection (here, Wawona on macOS). Built without the `video`
  # feature (ffmpeg + shaders); lz4, zstd and dmabuf (vulkan is dlopen'd, gbm is
  # the fallback path) are enabled.
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://gitlab.freedesktop.org/mstoeckl/waypipe/-/archive/v%{version}/waypipe-v%{version}.tar.gz",
      sha256 = "92482a459eb86bef2dae025ea2eb37f5560aea3d3744a097bed9d284b863a5a6",
      extract = true,
      strip_prefix = "waypipe-v%{version}",
    } | Source,
    base,
    # The lz4/zstd/gbm wrapper crates run the `bindgen` CLI from build.rs.
    bindgen,
    pkgconf,
    rust,
    toolchain,
    # Deterministic build-time entropy for the offline build (see build.sh).
    detbuild,
    # Headers and pkg-config files for the wrapper crates.
    lz4,
    mesa,
    zstd,
  ],

  runtime_deps = [
    glibc,
    lz4,
    # libgbm, the DMABUF fallback path.
    mesa,
    # `waypipe ssh` execs ssh to reach the other end.
    openssh,
    zstd,
  ],

  # cargo fetch (see build.sh)
  needs =
    {
      dns = {},
      internet = {},
    } | Needs,

  cmd = "./build.sh",
  build_args = { include version },

  outputs = {
    waypipe = { glob = "usr/bin/waypipe" } | OutputBin,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "GPL-3.0-or-later",
      repology_project = "waypipe",
      source_provenance = {
        category = 'Gitlab,
        host = "gitlab.freedesktop.org",
        owner = "mstoeckl",
        repo = "waypipe",
      },
    } | Attrs,

  tests = {
    smoke =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          ["/bin/bash", "-c", "waypipe --version | grep -q '%{version}'"],
          # Sessions the transport needs: both compressors compiled in.
          ["/bin/bash", "-c", "waypipe --help | grep -q lz4 && waypipe --help | grep -q zstd"],
        ],
      } | Test,
  },
} | BuildSpec
