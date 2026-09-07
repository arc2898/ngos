#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p out docs/screenshots
Xvfb :99 -screen 0 1280x800x24 -ac >/tmp/ngos-terminal-xvfb.log 2>&1 & XVFB=$!
sleep 1
DISPLAY=:99 ./ngoswm >/tmp/ngos-terminal-wm.log 2>&1 & WM=$!
sleep 1
DISPLAY=:99 xdotool key super+Return
sleep 2
DISPLAY=:99 xdotool mousemove 640 735
python3 docs/capture_gui.py
cp out/ngos-desktop.png docs/screenshots/ngos-terminal-open.png
kill "$WM" "$XVFB" 2>/dev/null || true
printf '%s\n' 'Captured NGOS terminal-open screenshot'
