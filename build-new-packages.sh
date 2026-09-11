#!/bin/sh
# Rebuild every package added or modified for term.everything / Xwayland / niri,
# from inside a Minimal session.
#
#   sh build-new-packages.sh          # build everything
#   sh build-new-packages.sh --install # ...and install the end-user packages
#
# Scratch helper, not part of the package set -- delete it when you no longer
# need it.
#
# Two things this works around, both from the troubleshooting FAQ:
#
#  * `min package patched-build` resolves each dependency from the LOCAL cache
#    and fails with "resolving dep '<name>' by name: not found" if it is absent.
#    Pre-existing upstream packages have to be fetched first, which is what the
#    `min add` below does. Packages built here populate the cache themselves, so
#    they do not need adding -- only ordering.
#
#  * Build order therefore matters. The sequence below is a topological sort of
#    the inter-dependencies between these packages; do not reorder it casually.
#
# Note: `min add` writes the package list into minimal.toml's [session] block.
# That is a tracked file, so expect a diff there afterwards.
#
# Cached builds return almost immediately, so re-running this is cheap and it is
# safe to resume after a failure.

set -e

log() { printf '\n=== %s\n' "$1"; }

# --------------------------------------------------------------------------
# Step 1: fetch the pre-existing upstream packages these builds depend on.
# --------------------------------------------------------------------------
log "fetching prerequisites (one min add, 45 packages)"
min add \
  base bash bison dbus eudev expat flex fontconfig freetype gcc gettext glib \
  glibc go hwdata libdrm liberation-fonts libffi libjpeg-turbo libpng libwebp \
  libx11 libxcb libxdamage libxext libxfixes libxml2 libxrandr libxshmfence \
  llvm m4 make meson nettle ninja pango perl pixman pkgconf python rust \
  toolchain xorgproto xtrans zlib

# --------------------------------------------------------------------------
# Step 2: build, in dependency order.
# --------------------------------------------------------------------------
build() { log "building $1"; min package patched-build "$1"; }

# Level 0 -- nothing here depends on anything else in this set.
for p in chafa wayland wayland-protocols libxcvt font-util libxkbfile \
         libxxf86vm xkeyboard-config mtdev libevdev seatd libdisplay-info \
         cairo; do
  build "$p"
done

# Level 1.
build term.everything   # <- chafa
build libfontenc        # <- font-util
build xkbcomp           # <- libxkbfile
build libinput          # <- libevdev, mtdev
build libxkbcommon      # <- xkeyboard-config
build mesa              # <- libxxf86vm, wayland, wayland-protocols

# Level 2.
build libxfont2         # <- libfontenc
build libepoxy          # <- mesa

# Level 3.
build xwayland          # <- libepoxy, libxcvt, libxfont2, mesa, wayland,
                        #    wayland-protocols, xkbcomp, xkeyboard-config,
                        #    font-util

# Level 4.
build niri              # <- cairo, libdisplay-info, libinput, libxkbcommon,
                        #    mesa, seatd, wayland

# --------------------------------------------------------------------------
# Step 3 (optional): install the packages you actually run.
# --------------------------------------------------------------------------
if [ "${1:-}" = "--install" ]; then
  log "installing term.everything, niri, xwayland"
  min add term.everything niri xwayland

  log "verifying the runtime data niri needs"
  # These two were the fresh-machine failure: without the xkb dataset niri
  # panics with BadKeymap, and without a font it renders no text at all.
  if [ -f /usr/share/X11/xkb/rules/evdev ]; then
    echo "  ok: xkb dataset present"
  else
    echo "  MISSING: /usr/share/X11/xkb/rules/evdev -- niri will panic (BadKeymap)."
    echo "           The session is holding a stale libxkbcommon; restart it."
  fi
  if [ "$(fc-list 2>/dev/null | wc -l)" -gt 0 ]; then
    echo "  ok: $(fc-list | wc -l) fonts visible"
  else
    echo "  MISSING: no fonts visible to fontconfig -- niri will render no text."
  fi
fi

log "done"
