#!/bin/sh
set -eu
PREFIX=${PREFIX:-/usr/share}
TMP=${TMPDIR:-/tmp}/ngos-themes
rm -rf "$TMP"
mkdir -p "$TMP" "$PREFIX/icons" "$PREFIX/themes"
# Maintained upstreams: macOS-like WhiteSur icons/cursors and Kali's shell helpers.
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git "$TMP/WhiteSur-icon-theme"
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-cursors.git "$TMP/WhiteSur-cursors"
if [ -x "$TMP/WhiteSur-icon-theme/install.sh" ]; then (cd "$TMP/WhiteSur-icon-theme" && ./install.sh -d "$PREFIX/icons"); fi
if [ -x "$TMP/WhiteSur-cursors/install.sh" ]; then (cd "$TMP/WhiteSur-cursors" && ./install.sh -d "$PREFIX/icons"); fi
install -Dm644 "$(dirname "$0")/ngos-zshrc" "$PREFIX/ngos/ngos-zshrc"
printf '%s\n' 'Installed WhiteSur icon/cursor themes and NGOS Kali-style Zsh configuration.'
