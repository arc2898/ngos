#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p out docs/screenshots
Xvfb :99 -screen 0 1280x800x24 -ac >/tmp/ngos-stable-xvfb.log 2>&1 & XVFB=$!
sleep 1
DISPLAY=:99 openbox --sm-disable >/tmp/ngos-stable-openbox.log 2>&1 & OB=$!
sleep 1
DISPLAY=:99 ./ngoswm >/tmp/ngos-stable-ngoswm.log 2>&1 & WM=$!
sleep 1
DISPLAY=:99 xterm -title 'NGOS Terminal' -geometry 70x18+160+160 >/tmp/ngos-stable-xterm.log 2>&1 & TERM_PID=$!
sleep 2
DISPLAY=:99 python3 docs/capture_gui.py
cp out/ngos-desktop.png docs/screenshots/ngos-stable-terminal.png
DISPLAY=:99 xdotool search --name 'NGOS Terminal' >/tmp/ngos-stable-window.txt
kill "$TERM_PID" "$WM" "$OB" "$XVFB" 2>/dev/null || true
printf '%s\n' 'NGOS stable desktop smoke test passed'
