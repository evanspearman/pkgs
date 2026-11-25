let { standaloneTest, subsetOf, Attrs, BuildSpec, Local, Needs, OutputBin, OutputData, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let cmake = import "../cmake/build.ncl" in
let detbuild = import "../detbuild/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let rust = import "../rust/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let ca-certificates = import "../ca-certificates/build.ncl" in
let gcc = import "../gcc/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let libglvnd = import "../libglvnd/build.ncl" in
let libx11 = import "../libx11/build.ncl" in
let libxcursor = import "../libxcursor/build.ncl" in
let libxi = import "../libxi/build.ncl" in
let libxkbcommon = import "../libxkbcommon/build.ncl" in
let libxrandr = import "../libxrandr/build.ncl" in
let mesa = import "../mesa/build.ncl" in
let wayland = import "../wayland/build.ncl" in

let version = "0.23.1" in
# storytold/craft-i18n at the commit named by craft-i18n.rev in the source tree (build.sh
# fails if the two ever disagree). Embedded for the translated UI.
let i18n_rev = "e02939ef009218e81c44e8ec001fbb7603461de4" in
{
  name = "photocraft",

  # Built from source with upstream's official feature set (--features heif). The tree pins
  # four storytold git dependencies (craft-libs, egui, winit, winprint.rs) by revision in
  # Cargo.lock, so the build fetches them from github.com as well as crates.io.
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://github.com/storytold/photocraft/archive/refs/tags/v%{version}.tar.gz",
      sha256 = "66786e5b1e88bff0a1f04ab5073be50faa7e65b3cdebcbd679e1837ff52a82c6",
      extract = true,
      strip_prefix = "photocraft-%{version}",
    } | Source,
    {
      url = "https://github.com/storytold/craft-i18n/archive/%{i18n_rev}.tar.gz",
      sha256 = "0bd1481c0de61d0e31dd2dd9f955135e573f8ebdbb04a87f4567125674b350bd",
    } | Source,
    base,
    cmake,
    detbuild,
    pkgconf,
    rust,
    toolchain,
  ],

  # winit and wgpu load these with dlopen, so the linker never records them.
  runtime_deps = [
    glibc,
    subsetOf gcc ["libgcc"],
    # craft-update (rustls-platform-verifier / rustls-native-certs) reads /etc/ssl/certs;
    # see AGENTS.md "Trust store".
    ca-certificates,
    libx11,
    libxcursor,
    libxi,
    libxkbcommon,
    libxrandr,
    wayland,
    # EGL/GL for wgpu's GL backend and the software fallback. There is no Vulkan loader
    # package in this repo yet, so the Vulkan backend is not available.
    libglvnd,
    mesa,
  ],

  cmd = "./build.sh",
  build_args = {
    include version,
    include i18n_rev,
  },

  needs =
    {
      dns = {},
      internet = {},
    } | Needs,

  outputs = {
    photocraft = { glob = "usr/bin/photocraft" } | OutputBin,
    photocraft-cli = { glob = "usr/bin/photocraft-cli" } | OutputBin,
    data = { glob = "usr/share/**" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT OR Apache-2.0",
      source_provenance = {
        category = 'GithubRepo,
        owner = "storytold",
        repo = "photocraft",
      },
      build_cost_multiple = 4,
    } | Attrs,

  tests = {
    smoketest = standaloneTest "/usr/bin/photocraft-cli --version",
  },
} | BuildSpec
