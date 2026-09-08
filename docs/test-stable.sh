#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p out docs/screenshots
for tool in Xvfb openbox xterm xdotool; do
  command -v "$tool" >/dev/null || { echo "missing test dependency: $tool" >&2; exit 2; }
done
cleanup(){ for pid in $(ps -o pid= --ppid $$ 2>/dev/null); do kill "$pid" 2>/dev/null || true; done; }
trap cleanup EXIT INT TERM
export DISPLAY=:102
Xvfb "$DISPLAY" -screen 0 1280x800x24 -ac >/tmp/ngos-stable-xvfb.log 2>&1 & XVFB=$!
sleep 1
openbox --sm-disable >/tmp/ngos-stable-openbox.log 2>&1 & OB=$!
sleep 1
./ngoswm >/tmp/ngos-stable-ngoswm.log 2>&1 & WM=$!
sleep 1
xterm -title 'NGOS Terminal' -geometry 70x18+160+160 >/tmp/ngos-stable-xterm.log 2>&1 & TERM_PID=$!
sleep 2
python3 docs/capture_gui.py
cp out/ngos-desktop.png docs/screenshots/ngos-stable-terminal.png
xdotool search --class XTerm >/tmp/ngos-stable-window.txt
cleanup
trap - EXIT
printf '%s\n' 'NGOS stable desktop smoke test passed'
