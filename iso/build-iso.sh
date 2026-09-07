#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
OUT=${OUTDIR:-$ROOT/out}
ARCH=${ARCH:-x86_64}
IMAGE=${IMAGE:-$OUT/ngos-${ARCH}.iso}
MAX=$((150*1024*1024))
command -v xbps-install >/dev/null || { echo 'ERROR: run on Void Linux with xbps-install' >&2; exit 1; }
command -v void-mklive >/dev/null || { echo 'ERROR: install void-mklive first' >&2; exit 1; }
command -v xorriso >/dev/null || { echo 'ERROR: install xorriso first' >&2; exit 1; }
mkdir -p "$OUT"
make -C "$ROOT" clean all
# Keep the base deliberately narrow. Add packages only when the size budget allows it.
PKGS='base-system xorg-minimal xinit xterm xsetroot openbox picom dbus elogind zsh git feh'
void-mklive -a "$ARCH" -p "$PKGS" -o "$IMAGE" -I "$ROOT/ngoswm" || {
  echo 'mklive invocation differs on this Void release; see docs/build.md' >&2; exit 1;
}
if [ "$(wc -c < "$IMAGE")" -ge "$MAX" ]; then
  echo "ERROR: $IMAGE is $(wc -c < "$IMAGE") bytes, over the 150 MiB limit" >&2; exit 1
fi
echo "Built $IMAGE ($(wc -c < "$IMAGE") bytes)"
