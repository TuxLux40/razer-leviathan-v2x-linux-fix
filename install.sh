#!/bin/bash
# Razer Leviathan V2 X driver-style fix: installs a udev rule + WirePlumber rule.
# Usage: ./install.sh [uninstall]
set -e
cd "$(dirname "$0")"
FILES="etc/udev/rules.d/90-razer-leviathan-v2x.rules etc/wireplumber/wireplumber.conf.d/51-leviathan-v2x-soft-mixer.conf"
[ "$EUID" -ne 0 ] && exec sudo "$0" "$@"
if [ "$1" = uninstall ]; then
  for f in $FILES; do rm -fv "/$f"; done
else
  command -v amixer >/dev/null || { echo "amixer missing (install alsa-utils)"; exit 1; }
  for f in $FILES; do install -Dm644 "$f" "/$f"; echo "installed /$f"; done
fi
udevadm control --reload
udevadm trigger --subsystem-match=sound --action=change 2>/dev/null || true
echo "Done. Restart audio: systemctl --user restart wireplumber"
