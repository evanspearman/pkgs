let { Attrs, BuildSpec, Local, OutputBin, OutputData, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let llvm = import "../llvm/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let rust = import "../rust/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let bash = import "../bash/build.ncl" in
let cairo = import "../cairo/build.ncl" in
let dbus = import "../dbus/build.ncl" in
let eudev = import "../eudev/build.ncl" in
let glib = import "../glib/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let liberation-fonts = import "../liberation-fonts/build.ncl" in
let libdisplay-info = import "../libdisplay-info/build.ncl" in
let libinput = import "../libinput/build.ncl" in
let libxkbcommon = import "../libxkbcommon/build.ncl" in
let mesa = import "../mesa/build.ncl" in
let pango = import "../pango/build.ncl" in
let seatd = import "../seatd/build.ncl" in
let wayland = import "../wayland/build.ncl" in

let version = "26.04" in
{
  name = "niri",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      # niri moved from the maintainer's personal account to the niri-wm org
      # during the 26.04 cycle; niri-wm/niri is the canonical repo now.
      url = "https://github.com/niri-wm/niri/archive/refs/tags/v%{version}.tar.gz",
      sha256 = "134c602d8e0d53413a52d6cd58f9ce7e79a07d03288ee0a51ba1abd5db1b1ad9",
      extract = true,
      strip_prefix = "niri-%{version}",
    } | Source,
    {
      # Upstream publishes the full crate graph as a release asset, so the build
      # is fully offline -- no `needs = { dns, internet }` and no dependence on
      # crates.io being reachable or unchanged. Extracts to ./vendor.
      url = "https://github.com/niri-wm/niri/releases/download/v%{version}/niri-%{version}-vendored-dependencies.tar.xz",
      sha256 = "407c525cd78710e72455c48741756857ca47dc32910a42f82cd40992a34beed6",
      extract = true,
    } | Source,
    base,
    # Supplies libclang, which bindgen needs for the C bindings.
    llvm,
    pkgconf,
    rust,
    toolchain,
  ],
  runtime_deps = [
    glibc,
    # niri-session is a /bin/sh script, so its interpreter must ship with it.
    bash,
    cairo,
    dbus,
    # libudev, for input device discovery.
    eudev,
    glib,
    # pango finds no fonts at all without one installed, so niri renders no text
    # (hotkey overlay, config-error notifications, tab titles).
    liberation-fonts,
    libdisplay-info,
    libinput,
    libxkbcommon,
    # libEGL / libgbm / GLES2 -- the renderer. Resolves to llvmpipe here.
    mesa,
    pango,
    # libseat, for session/seat management.
    seatd,
    wayland,
  ],

  cmd = "./build.sh",
  build_args = {
    include version,
  },

  outputs = {
    niri = { glob = "usr/bin/niri" } | OutputBin,
    niri-session = { glob = "usr/bin/niri-session" } | OutputBin,
    session_desktop = { glob = "usr/share/wayland-sessions/*.desktop" } | OutputData,
    portals_conf = { glob = "usr/share/xdg-desktop-portal/*.conf" } | OutputData,
    # Upstream's default-config.kdl, shipped as a starting point and as the
    # subject of the `niri validate` smoke test below.
    default_config = { glob = "usr/share/niri-default-config.kdl" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "GPL-3.0-only",
      repology_project = "niri",
      source_provenance = {
        category = 'GithubRepo,
        owner = "niri-wm",
        repo = "niri",
      },
    } | Attrs,

  tests = {
    smoke =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          # Anything further needs a seat or a parent compositor.
          ["niri", "--version"],
          ["niri", "validate", "--config", "/usr/share/niri-default-config.kdl"],
          # niri panics with BadKeymap if the xkb dataset is absent, and renders
          # no text if no font is. Neither shows up in --version or validate, so
          # both were missing from the runtime closure while these checks passed
          # on a machine that happened to have them installed. Assert the files
          # are actually reachable in a clean sandbox.
          ["/bin/bash", "-c", "test -f /usr/share/X11/xkb/rules/evdev"],
          ["/bin/bash", "-c", "ls /usr/share/fonts/liberation/*.ttf >/dev/null"],
        ],
      } | Test,
  },
} | BuildSpec
