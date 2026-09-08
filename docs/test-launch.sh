#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
cleanup(){ for pid in $(ps -o pid= --ppid $$ 2>/dev/null); do kill "$pid" 2>/dev/null || true; done; }
trap cleanup EXIT INT TERM
export DISPLAY=:101
Xvfb "$DISPLAY" -screen 0 1280x800x24 -ac >/tmp/ngos-launch-xvfb.log 2>&1 & XVFB=$!
sleep 1
./ngoswm >/tmp/ngos-launch-wm.log 2>&1 & WM=$!
sleep 1
xdotool key super+Return
sleep 2
if xdotool search --class XTerm >/tmp/ngos-xterm-window.txt 2>/dev/null; then
  echo 'NGOS terminal launched successfully'
else
  echo 'NGOS terminal was not detected' >&2
  cat /tmp/ngos-launch-wm.log >&2 || true
  exit 1
fi
cleanup
trap - EXIT
