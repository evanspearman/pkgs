let { Attrs, BuildSpec, Local, OutputBin, OutputData, OutputLib, Source, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let make = import "../make/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in

let freetype = import "../freetype/build.ncl" in
let glib = import "../glib/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let libjpeg-turbo = import "../libjpeg-turbo/build.ncl" in
let libwebp = import "../libwebp/build.ncl" in

let version = "1.18.2" in
{
  name = "chafa",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      # The signed autotools-dist tarball attached to the GitHub release — not
      # the `archive/refs/tags/` auto-archive, which is generated from the git
      # tree and so has no ./configure (that would need an autoreconf
      # bootstrap: autoconf, automake, libtool, gettext, gtk-doc).
      url = "https://github.com/hpjansson/chafa/releases/download/%{version}/chafa-%{version}.tar.xz",
      sha256 = "0b8d9ba9f347e8b6c0c71878217c9b0e478b4a42aa4babea0bf20840567239c2",
      extract = true,
      strip_prefix = "chafa-%{version}",
    } | Source,
    base,
    make,
    pkgconf,
    toolchain,
  ],
  runtime_deps = [
    # freetype is only needed by the `chafa` CLI (font-based glyph metrics);
    # configure hard-requires it unless you pass --without-tools.
    freetype,
    glib,
    glibc,
    libjpeg-turbo,
    libwebp,
  ],

  cmd = "./build.sh",
  build_args = {
    include version,
  },

  outputs = {
    bin = { glob = "usr/bin/chafa" } | OutputBin,
    libs = { glob = "usr/lib/libchafa.so*" } | OutputLib,

    includes = { glob = "usr/include/chafa/**" } | OutputData,
    # chafaconfig.h is arch-dependent, so it lives under libdir rather than includedir.
    configinclude = { glob = "usr/lib/chafa/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "LGPL-3.0-or-later",
      repology_project = "chafa",
      source_provenance = {
        category = 'GithubRepo,
        owner = "hpjansson",
        repo = "chafa",
      },
    } | Attrs,

  tests = {
    smoke =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          ["chafa", "--version"],
          ["chafa", "--help"],
        ],
      } | Test,
  },
} | BuildSpec
