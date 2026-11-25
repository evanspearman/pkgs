#!/bin/bash
set -euo pipefail

export CC=gcc
export CXX=g++
export LD=gcc
# Reproducibility: codegen-units=1 and v0 mangling, plus source and cargo-home paths remapped
# out of the binary (same recipe as oha / waypipe). The C code cargo builds (aws-lc-sys)
# gets the same prefix maps through CFLAGS.
export RUSTFLAGS="-C linker=gcc -C codegen-units=1 -C symbol-mangling-version=v0 --remap-path-prefix=$(pwd)=/builddir --remap-path-prefix=$HOME/.cargo=/cargo"
export CFLAGS="-O2 -ffile-prefix-map=$(pwd)=/builddir -ffile-prefix-map=$HOME/.cargo=/cargo -gno-record-gcc-switches"
export CXXFLAGS="$CFLAGS"
export CARGO_INCREMENTAL=0

# Interface translations (storytold/craft-i18n at the commit in craft-i18n.rev). Unset, the
# UI is English only; a bad path is a build error with CRAFT_I18N_REQUIRED=1.
test "$(cat craft-i18n.rev)" = "$MINIMAL_ARG_I18N_REV"
mkdir -p craft-i18n
tar -xzf "$MINIMAL_ARG_I18N_REV.tar.gz" -C craft-i18n --strip-components=1
export CRAFT_I18N_DIR="$(pwd)/craft-i18n"
export CRAFT_I18N_REQUIRED=1

# All network access happens here, with real entropy: crates and the storytold git
# dependencies (craft-libs, egui, winit, winprint.rs) are fetched against Cargo.lock.
cargo fetch --locked

# Deterministic build-time entropy (packages/detbuild) for the offline build only.
# --features heif matches upstream's official packaging (packaging/linux/package.sh).
LD_PRELOAD=/usr/lib/minimal/libdetbuild.so \
  cargo build --frozen --release -p photocraft -p photocraft-cli --features heif --bins

LD_PRELOAD=/usr/lib/minimal/libdetbuild.so \
  cargo build --frozen --release -p photocraft-cli --features heif --example man-and-completions

install -Dm755 target/release/photocraft "$OUTPUT_DIR/usr/bin/photocraft"
install -Dm755 target/release/photocraft-cli "$OUTPUT_DIR/usr/bin/photocraft-cli"

APP_ID=ai.storyteller.photocraft
install -Dm644 "packaging/linux/$APP_ID.desktop" "$OUTPUT_DIR/usr/share/applications/$APP_ID.desktop"
install -Dm644 "packaging/linux/$APP_ID.mime.xml" "$OUTPUT_DIR/usr/share/mime/packages/$APP_ID.xml"
mkdir -p "$OUTPUT_DIR/usr/share/icons"
cp -R assets/app-icon/hicolor "$OUTPUT_DIR/usr/share/icons/"

# photocraft-cli man pages and shell completions, from its clap definition.
target/release/examples/man-and-completions cli-docs
install -Dm644 -t "$OUTPUT_DIR/usr/share/man/man1" cli-docs/*.1
install -Dm644 cli-docs/photocraft-cli.bash "$OUTPUT_DIR/usr/share/bash-completion/completions/photocraft-cli"
install -Dm644 cli-docs/_photocraft-cli "$OUTPUT_DIR/usr/share/zsh/site-functions/_photocraft-cli"
install -Dm644 cli-docs/photocraft-cli.fish "$OUTPUT_DIR/usr/share/fish/vendor_completions.d/photocraft-cli.fish"

install -Dm644 LICENSE-APACHE "$OUTPUT_DIR/usr/share/licenses/photocraft/LICENSE-APACHE"
install -Dm644 LICENSE-MIT "$OUTPUT_DIR/usr/share/licenses/photocraft/LICENSE-MIT"
install -Dm644 NOTICE "$OUTPUT_DIR/usr/share/licenses/photocraft/NOTICE"

# Record what the binaries link, so runtime_deps can be checked against it.
for b in photocraft photocraft-cli; do
  echo "== $b NEEDED"
  readelf -d "$OUTPUT_DIR/usr/bin/$b" | sed -n 's/.*Shared library: \[\(.*\)\]/\1/p'
done
