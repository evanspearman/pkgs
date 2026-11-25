#!/bin/bash
set -euo pipefail

export CC=gcc
export LD=gcc
export RUSTFLAGS="-C linker=gcc -C codegen-units=1 -C symbol-mangling-version=v0 --remap-path-prefix=$(pwd)=/builddir --remap-path-prefix=$HOME/.cargo=/cargo"
export CARGO_INCREMENTAL=0

# Network access happens here only, without the entropy shim.
cargo fetch --locked

# No `video` (ffmpeg, shader compilation). dmabuf, lz4, zstd and the gbm fallback
# stay; the lz4/zstd/gbm wrapper crates generate bindings with the bindgen CLI.
LD_PRELOAD=/usr/lib/minimal/libdetbuild.so \
  cargo build --frozen --release --no-default-features \
    --features dmabuf,lz4,zstd,gbmfallback --bin waypipe

install -Dm755 target/release/waypipe "$OUTPUT_DIR/usr/bin/waypipe"
