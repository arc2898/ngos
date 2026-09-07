#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
DESTDIR=${DESTDIR:-}
install -Dm644 "$ROOT/wallpaper.svg" "$DESTDIR/usr/share/backgrounds/ngos/wallpaper.svg"
install -Dm644 "$ROOT/ngos-logo.svg" "$DESTDIR/usr/share/pixmaps/ngos-logo.svg"
install -Dm644 "$ROOT/cursor.svg" "$DESTDIR/usr/share/icons/NGOS-Neon/cursors/left_ptr.svg"
install -Dm644 "$ROOT/cursors.theme" "$DESTDIR/usr/share/icons/NGOS-Neon/index.theme"
install -Dm644 "$ROOT/ngos-zshrc" "$DESTDIR/etc/skel/.zshrc"
printf '%s\n' 'Installed NGOS wallpaper, cursor metadata, logo, and Zsh defaults.'
