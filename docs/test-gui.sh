#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p out
for tool in Xvfb xterm xdotool; do
  command -v "$tool" >/dev/null || { echo "missing test dependency: $tool" >&2; exit 2; }
done
cleanup(){ for pid in $(ps -o pid= --ppid $$ 2>/dev/null); do kill "$pid" 2>/dev/null || true; done; }
trap cleanup EXIT INT TERM
export DISPLAY=:100
Xvfb "$DISPLAY" -screen 0 1280x800x24 -ac >/tmp/ngos-xvfb.log 2>&1 & XVFB=$!
sleep 1
./ngoswm >/tmp/ngos-wm.log 2>&1 & WM=$!
sleep 1
 xterm -geometry 70x18+160+160 >/tmp/ngos-xterm.log 2>&1 & TERM_PID=$!
sleep 1
xdotool mousemove 640 735
sleep 1
python3 docs/capture_gui.py
test -s out/ngos-desktop.png
cleanup
trap - EXIT
printf 'NGOS GUI smoke test passed\n'
