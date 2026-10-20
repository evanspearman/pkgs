let { subsetOf, Attrs, BuildSpec, Local, OutputData, OutputLib, Source, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in
let meson = import "../meson/build.ncl" in
let ninja = import "../ninja/build.ncl" in
let pkgconf = import "../pkgconf/build.ncl" in
let toolchain = import "../toolchain/build.ncl" in
# The protocol XML that wlroots generates its bindings from (>=1.47).
let wayland-protocols = import "../wayland-protocols/build.ncl" in
# pnp.ids, compiled into the DRM backend's EDID vendor table.
let hwdata = import "../hwdata/build.ncl" in

let eudev = import "../eudev/build.ncl" in
let glibc = import "../glibc/build.ncl" in
let libdisplay-info = import "../libdisplay-info/build.ncl" in
let libdrm = import "../libdrm/build.ncl" in
let libxkbcommon = import "../libxkbcommon/build.ncl" in
let pixman = import "../pixman/build.ncl" in
let seatd = import "../seatd/build.ncl" in
let wayland = import "../wayland/build.ncl" in

# 0.20 is what cage 0.3 builds against (it asks pkg-config for wlroots-0.20).
let version = "0.20.2" in
{
  name = "wlroots",
  build_deps = [
    { file = "build.sh" } | Local,
    {
      # A release asset uploaded by the maintainers, not GitLab's generated
      # archive of the tag, whose bytes (and so sha256) are not stable.
      url = "https://gitlab.freedesktop.org/wlroots/wlroots/-/releases/%{version}/downloads/wlroots-%{version}.tar.gz",
      sha256 = "80c567d2ed4efb2cfa6b077f22c7a710d9c78ba4e185a75e8694001114af0733",
      extract = true,
      strip_prefix = "wlroots-%{version}",
    } | Source,
    base,
    meson,
    ninja,
    pkgconf,
    toolchain,
    wayland-protocols,
    hwdata,
  ],
  runtime_deps = [
    glibc,
    libdrm,
    # The DRM backend and session support (see build.sh): libudev and libseat
    # for the session, libdisplay-info for EDID parsing. A headless compositor
    # links them but never opens a seat or a device.
    eudev,
    libdisplay-info,
    subsetOf seatd ["libs"],
    libxkbcommon,
    # The pixman renderer, the only renderer this headless build has.
    pixman,
    # libwayland-server for the compositor, libwayland-client for the nested
    # (wayland) backend; wayland-scanner at build time.
    wayland,
  ],

  cmd = "./build.sh",

  outputs = {
    libs = { glob = "usr/lib/libwlroots*.so*" } | OutputLib,
    includes = { glob = "usr/include/**" } | OutputData,
    pkgconfigs = { glob = "usr/lib/pkgconfig/*.pc" } | OutputData,
  },

  attrs =
    {
      upstream_version = version,
      license_spdx = "MIT",
      repology_project = "wlroots",
    } | Attrs,
} | BuildSpec
