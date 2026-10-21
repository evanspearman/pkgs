let { Attrs, BuildSpec, Local, OutputBin, Test, .. } = import "minimal.ncl" in
let base = import "../base/build.ncl" in

let bash = import "../bash/build.ncl" in
let cage = import "../cage/build.ncl" in
let coreutils = import "../coreutils/build.ncl" in
let dbus = import "../dbus/build.ncl" in
let gawk = import "../gawk/build.ncl" in
let util-linux = import "../util-linux/build.ncl" in
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
    # dbus-run-session: the desktop's session bus.
    dbus,
    # Picks the output name out of wlr-randr's listing.
    gawk,
    # setsid: the desktop runs in a process group the host can stop whole.
    util-linux,
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
    # comes up listening, and that closing its stdin stops all of it.
    # `sleep` stands in for the desktop: cage does not care whether its child
    # is a Wayland client.
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
              dir=$(mktemp -d)
              mkfifo "$dir/in"
              # stdin is a pipe held open here, as `min session display`
              # holds its exec channel; closing it is how min stops the host.
              minimal-display-host --size 800x600 -- sleep 60 <"$dir/in" >"$dir/out" &
              host=$!
              exec 3>"$dir/in"
              for _ in $(seq 300); do grep -qx ready "$dir/out" && break; kill -0 $host; sleep 0.1; done
              grep -qx ready "$dir/out"
              state=${XDG_RUNTIME_DIR:-/tmp/runtime-$(id -u)}/minimal-display
              test -S "$state/vnc.sock"
              cmd=$(cat "$state/cmd.pid")
              exec 3>&-
              wait $host || test $? -eq 143
              # Everything stopped with it: cage waits on its child forever,
              # so the host must stop CMD itself.
              if kill -0 "$cmd" 2>/dev/null; then echo "CMD outlived the host" >&2; exit 1; fi
              test ! -e "$state/vnc.sock"
            "%,
          ],
        ],
      } | Test,
  },
} | BuildSpec
