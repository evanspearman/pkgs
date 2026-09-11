#!/bin/sh
set -e

export GOROOT=/usr/go

# The Wayland protocol bindings are code-generated from the XML in
# ./wayland/generate/resources; upstream's Makefile does this before building.
# The generator is a plain `go run` of an in-tree package, so no network.
go generate ./wayland

# cgo bits (chafa/glib bindings, termios raw mode) go through gcc.
export CGO_ENABLED=1
export CC=gcc

case $(uname -m) in
  x86_64)  MARCH="-march=x86-64-v3" ;;
  aarch64) MARCH="-march=armv8-a" ;;
  *)       MARCH="" ;;
esac
export CGO_CFLAGS="$MARCH -O2 -pipe -gno-record-gcc-switches -ffile-prefix-map=$(pwd)=/builddir"
export CGO_LDFLAGS="-Wl,--build-id=none"

mkdir -p "$OUTPUT_DIR/usr/bin"

# Upstream's Makefile emits a binary called
# "term.everything❗mmulet.com-dont_forget_to_chmod_+x_this_file", which is a
# name for a release-page download rather than for $PATH. We install the plain
# command name instead.
go build -trimpath -ldflags "-buildid= -w -s" \
  -o "$OUTPUT_DIR/usr/bin/term.everything" .
