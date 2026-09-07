#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
Xvfb :99 -screen 0 1280x800x24 -ac >/tmp/ngos-launch-xvfb.log 2>&1 & XVFB=$!
sleep 1
DISPLAY=:99 ./ngoswm >/tmp/ngos-launch-wm.log 2>&1 & WM=$!
sleep 1
DISPLAY=:99 xdotool key super+Return
sleep 2
if DISPLAY=:99 xdotool search --class XTerm >/tmp/ngos-xterm-window.txt 2>/dev/null; then
  echo 'NGOS terminal launched successfully'
else
  echo 'NGOS terminal was not detected' >&2
  cat /tmp/ngos-launch-wm.log >&2 || true
  kill "$WM" "$XVFB" 2>/dev/null || true
  exit 1
fi
kill $(cat /tmp/ngos-launch-wm.log 2>/dev/null >/dev/null || echo "$WM") 2>/dev/null || true
kill "$WM" "$XVFB" 2>/dev/null || true
