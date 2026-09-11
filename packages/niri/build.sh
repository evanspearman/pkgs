#!/bin/sh
set -e

export CC=gcc
export LD=gcc
# bindgen loads libclang at build time rather than shelling out to clang.
export LIBCLANG_PATH=/usr/lib

# --remap-path-prefix keeps the build directory out of the binary; without it
# panic messages and debug info embed /build and the output is not reproducible.
export RUSTFLAGS="-C linker=gcc --remap-path-prefix=$(pwd)=/builddir --remap-path-prefix=$HOME/.cargo=/cargo"

# Point cargo at the vendored crate tree unpacked next to the source, so the
# build never reaches for crates.io.
mkdir -p .cargo
cat > .cargo/config.toml <<'EOF'
[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "vendor"
EOF

# niri also takes smithay straight from a git revision. Those are vendored too,
# but cargo will not use the vendored copy unless each git URL+rev is redirected
# explicitly -- otherwise it tries to clone and dies under --offline. Derive the
# entries from Cargo.lock so a version bump cannot silently drop one.
grep -oE 'source = "git\+[^"]+"' Cargo.lock \
  | sed -e 's/^source = "//' -e 's/"$//' -e 's/#.*$//' \
  | sort -u \
  | while read -r src; do
      url=${src#git+}; url=${url%%\?*}
      rev=${src##*rev=}
      printf '\n[source."%s"]\ngit = "%s"\nrev = "%s"\nreplace-with = "vendored-sources"\n' \
        "$src" "$url" "$rev" >> .cargo/config.toml
    done

# Default features pull in systemd; xdp-gnome-screencast would pull in pipewire.
# dbus alone is what niri needs for its own IPC and portal handshake.
# -j4 is deliberate. niri's own Cargo.toml sets lto = "thin", so codegen across
# ~500 crates fans out to one job per core and is then followed by a single
# large LTO link; at full width that combination exhausts memory on a many-core
# builder. Upstream's debuginfo setting is left alone -- it is already the cheap
# "line-tables-only", and the peak is the link, not the debug info.
cargo build --release --offline --locked -j4 \
  --no-default-features \
  --features dbus

install -Dm755 target/release/niri "$OUTPUT_DIR/usr/bin/niri"
install -Dm755 resources/niri-session "$OUTPUT_DIR/usr/bin/niri-session"
install -Dm644 resources/niri.desktop "$OUTPUT_DIR/usr/share/wayland-sessions/niri.desktop"
install -Dm644 resources/niri-portals.conf "$OUTPUT_DIR/usr/share/xdg-desktop-portal/niri-portals.conf"

# The smoke test validates against this; it is also a useful starting config.
install -Dm644 resources/default-config.kdl "$OUTPUT_DIR/usr/share/niri-default-config.kdl"
