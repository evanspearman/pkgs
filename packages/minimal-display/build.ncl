let { Attrs, BuildSpec, Local, OutputBin, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in

let bash = import "../bash/build.ncl" in
let cage = import "../cage/build.ncl" in
let coreutils = import "../coreutils/build.ncl" in
let gawk = import "../gawk/build.ncl" in
let wayvnc = import "../wayvnc/build.ncl" in
let wlr-randr = import "../wlr-randr/build.ncl" in

# The box side of `min display`: a headless Wayland desktop served over VNC.
# The desktop itself (niri by default, or any compositor or app named after
# `--`) is the user's choice and so is not a dependency here.
{
  name = "minimal-display",
  build_deps = [
    { file = "build.sh" } | Local,
    { file = "minimal-display-host" } | Local,
    base,
  ],
  runtime_deps = [
    bash,
    # id, mkdir, seq, sleep, cat, mv, rm.
    coreutils,
    # Picks the output name out of wlr-randr's listing.
    gawk,
    cage,
    wayvnc,
    wlr-randr,
  ],

  cmd = "./build.sh",

  outputs = {
    bin = { glob = "usr/bin/minimal-display-host" } | OutputBin,
  },

  attrs =
    {
      # Internal package: the script is maintained in this repo.
      license_spdx = "Apache-2.0",
    } | Attrs,

  tests = {
    # Brings the whole stack up in a clean sandbox with no seat, no GPU and no
    # input devices -- the conditions inside a box -- and checks that cage
    # starts headless, that wlr-randr can resize its output, and that wayvnc
    # comes up listening. `sleep` stands in for the desktop: cage does not
    # care whether its child is a Wayland client.
    stack_starts =
      {
        class = 'Standalone,
        test_deps = [base],
        cmds = [
          [
            "/bin/bash",
            "-c",
            m%"
              set -e
              out=$(mktemp)
              minimal-display-host --size 800x600 -- sleep 60 >"$out" &
              host=$!
              for _ in $(seq 300); do grep -qx ready "$out" && break; kill -0 $host; sleep 0.1; done
              grep -qx ready "$out"
              test -S "$XDG_RUNTIME_DIR/minimal-display/vnc.sock" \
                || test -S "/tmp/runtime-$(id -u)/minimal-display/vnc.sock"
              kill -TERM $host
              wait $host || test $? -eq 143
            "%,
          ],
        ],
      } | Test,
  },
} | BuildSpec
