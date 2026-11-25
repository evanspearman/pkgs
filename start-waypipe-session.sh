#!/bin/bash
# Starts everything the session side of GUI-over-waypipe needs, then prints what to run on the Mac.
#
#   ./start-waypipe-session.sh          start (idempotent: restarts sshd if already running)
#   ./start-waypipe-session.sh stop     stop sshd
#
# Session side only. `min net forward ...` and the waypipe command run on the HOST / your Mac.
set -euo pipefail

PORT="${WAYPIPE_SSH_PORT:-2222}"
STATE="${WAYPIPE_STATE_DIR:-/tmp/waypipe-sshd}"
XDG_DIR="${WAYPIPE_XDG_RUNTIME_DIR:-/tmp/xdg-$(id -un)}"
# Public key allowed to log in. Override with WAYPIPE_AUTHORIZED_KEY (the key text).
AUTHORIZED_KEY="${WAYPIPE_AUTHORIZED_KEY:-ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9Kvcqpg/R2jdQ/yO4w/fsF/ANMY2UuyY3vDhaDiJo2 evan@Evans-MacBook-Pro.local}"
BOX="${WAYPIPE_BOX_NAME:-wayland-pkgs}"   # name `min net forward` takes; see the error `min net expose` prints

stop_sshd() {
  if [ -f "$STATE/sshd.pid" ] && kill -0 "$(cat "$STATE/sshd.pid")" 2>/dev/null; then
    kill "$(cat "$STATE/sshd.pid")"
    sleep 1
  fi
}

if [ "${1:-}" = "stop" ]; then
  stop_sshd
  echo "sshd stopped"
  exit 0
fi

# 1. Packages (a no-op when already installed).
for p in waypipe openssh niri chocolate-doom freedoom socat; do
  min add --session "$p" 2>&1 | tail -1
done

# 2. State: host key, authorized key, sshd config. The host key persists across restarts
#    so the Mac's known_hosts entry stays valid for as long as $STATE lives.
umask 077
mkdir -p "$STATE" "$XDG_DIR"
chmod 700 "$STATE" "$XDG_DIR"
[ -f "$STATE/hostkey" ] || ssh-keygen -q -t ed25519 -N '' -f "$STATE/hostkey"
printf '%s\n' "$AUTHORIZED_KEY" > "$STATE/authorized_keys"
chmod 600 "$STATE/authorized_keys"

# No PAM and no shadow file here, and sshd is not root, so password login cannot work:
# key auth only. AllowStreamLocalForwarding and XDG_RUNTIME_DIR are what `waypipe ssh` needs.
cat > "$STATE/sshd_config" <<EOF
Port $PORT
ListenAddress 0.0.0.0
HostKey $STATE/hostkey
AuthorizedKeysFile $STATE/authorized_keys
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
StrictModes no
PidFile $STATE/sshd.pid
AllowStreamLocalForwarding yes
SetEnv XDG_RUNTIME_DIR=$XDG_DIR
EOF

# 3. (Re)start sshd.
stop_sshd
/usr/sbin/sshd -t -f "$STATE/sshd_config"
nohup /usr/sbin/sshd -D -e -f "$STATE/sshd_config" > "$STATE/sshd.log" 2>&1 &
sleep 1
kill -0 "$(cat "$STATE/sshd.pid")" 2>/dev/null || { echo "sshd failed to start; see $STATE/sshd.log" >&2; exit 1; }

FP=$(ssh-keygen -lf "$STATE/hostkey.pub" | awk '{print $2}')
USER_NAME=$(id -un)
cat <<EOF

Session side is up: sshd listening on :$PORT as user '$USER_NAME' (key auth only).
  host key  $FP
  log       $STATE/sshd.log   (watch it: tail -f $STATE/sshd.log)
  stop      $0 stop

On the HOST:
  min net forward $BOX $PORT:$PORT

On your Mac (Wawona running; adjust to your shell, fish uses 'set -x'):
  export XDG_RUNTIME_DIR="/tmp/wawona-\$(id -u)"
  export WAYLAND_DISPLAY="wayland-0"
  ssh-keygen -R '[127.0.0.1]:$PORT'; ssh-keygen -R '[localhost]:$PORT'   # only if the host key changed
  "/Applications/Nix Apps/Wawona.app/Contents/Resources/bin/waypipe" --no-gpu ssh -p $PORT $USER_NAME@localhost \\
      env SDL_AUDIODRIVER=dummy chocolate-doom -window -iwad /usr/share/games/doom/freedoom1.wad
  # or nested niri:  ... $USER_NAME@localhost env LIBGL_ALWAYS_SOFTWARE=1 niri
EOF
