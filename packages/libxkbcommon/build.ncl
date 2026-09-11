let { Attrs, BuildSpec, Local, OutputBin, OutputData, OutputLib, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let bison = import "../bison/build.ncl" in
let m4 = import "../m4/build.ncl" in

let libxcb = import "../libxcb/build.ncl" in
let libxml2 = import "../libxml2/build.ncl" in
let xorgproto = import "../xorgproto/build.ncl" in
let xkeyboard-config = import "../xkeyboard-config/build.ncl" in
let glibc = import "../glibc/build.ncl" in

let version = "1.13.2" in
{
  name = "libxkbcommon",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "gs://minimal-staging-archives/xkbcommon/libxkbcommon/xkbcommon-%{version}.tar.gz",
      sha256 = "acc4d5f7c3cbba5f9f8d08d8bdbeede84ecede46792f47929aa9321873385528",
      extract = true,
      strip_prefix = "libxkbcommon-xkbcommon-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
    bison,
    m4,
    libxcb,
    libxml2,
    xorgproto,
  ],
  runtime_deps = [
    libxcb,
    libxml2,
    glibc,
    # libxkbcommon's default include path is /usr/share/X11/xkb, which this
    # package supplies. Without it every keymap lookup fails with
    # "Failed to add any default include path", which callers generally treat as
    # fatal -- niri panics outright. Any consumer that compiles a keymap needs
    # it, so it belongs here rather than being re-declared per consumer.
    xkeyboard-config,
  ],

  cmd = "./build.sh",

  outputs = {
    # libxkbregistry is built here too but the old glob only matched
    # libxkbcommon*, so it was silently never shipped. xkbcli-list links it, and
    # so does anything enumerating available layouts.
    libs = { glob = "usr/lib/libxkb{common,registry}*.so*" } | OutputLib,
    # The build already produced xkbcli but never exported it. It is the only
    # way to exercise keymap compilation from a test, which is what catches a
    # missing xkeyboard-config.
    xkbcli = { glob = "usr/bin/xkbcli" } | OutputBin,
    # xkbcli is only a dispatcher; the subcommands are separate binaries it
    # execs out of libexec, so it is useless without them.
    xkbcli_subcommands = { glob = "usr/libexec/xkbcommon/**" } | OutputBin,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      source_provenance = {
        category = 'GithubRepo,
        owner = "xkbcommon",
        repo = "libxkbcommon",
      },
    } | Attrs,

  tests = {
    # Runs in a clean sandbox holding only the declared runtime deps, so this
    # fails if xkeyboard-config ever stops being pulled in -- the exact
    # regression that made niri panic with BadKeymap on a fresh machine.
    compile_keymap =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          ["/bin/bash", "-c", "xkbcli compile-keymap --layout us | grep -q xkb_keymap"],
        ],
      } | Test,
  },
} | BuildSpec
