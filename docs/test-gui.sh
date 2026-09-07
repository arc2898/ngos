#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p out
Xvfb :99 -screen 0 1280x800x24 -ac >/tmp/ngos-xvfb.log 2>&1 & XVFB=$!
sleep 1
DISPLAY=:99 ./ngoswm >/tmp/ngos-wm.log 2>&1 & WM=$!
sleep 1
DISPLAY=:99 xterm -geometry 70x18+160+160 >/tmp/ngos-xterm.log 2>&1 & TERM_PID=$!
sleep 1
DISPLAY=:99 xdotool mousemove 640 735
sleep 1
python3 docs/capture_gui.py
test -s out/ngos-desktop.png
kill "$TERM_PID" "$WM" "$XVFB" 2>/dev/null || true
printf 'NGOS GUI smoke test passed\n'
