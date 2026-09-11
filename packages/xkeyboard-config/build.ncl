let { Attrs, BuildSpec, Local, OutputData, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let gettext = import "../gettext/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let perl = import "../perl/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let python = import "../python/build.ncl" in

let version = "2.48" in
{
  name = "xkeyboard-config",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      url = "https://xorg.freedesktop.org/archive/individual/data/xkeyboard-config/xkeyboard-config-%{version}.tar.xz",
      sha256 = "b77041324f0109f77161ee43743fe04baa485866af8460d31e476ad3f7648fd5",
      extract = true,
      strip_prefix = "xkeyboard-config-%{version}",
    } | Source,
    base,
    # msgfmt, for the translated layout descriptions.
    gettext,
    meson,
    ninja,
    # rules/xml2lst.pl converts the rules XML to the legacy .lst format.
    perl,
    pkgconf,
    # rules/generator builds the evdev/base rule files.
    python,
  ],
  # Keyboard description data only — rules, symbols, geometry, compat. Nothing
  # is compiled, so there is nothing to link against at runtime.
  runtime_deps = [],

  cmd = "./build.sh",

  outputs = {
    # 2.48 installs the dataset into a versioned directory and leaves
    # /usr/share/X11/xkb as a symlink to it. Both are needed: consumers such as
    # xkbcomp and Xwayland are configured against the legacy X11 path.
    xkbdata = { glob = "usr/share/xkeyboard-config-2/**" } | OutputData,
    xkbdata_compat_link = { glob = "usr/share/X11/xkb" } | OutputData,
    locale = { glob = "usr/share/locale/**" } | OutputData,
    pkgconfigs = { glob = "usr/share/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "xkeyboard-config",
    } | Attrs,
} | BuildSpec
