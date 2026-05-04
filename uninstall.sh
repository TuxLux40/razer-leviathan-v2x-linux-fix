#!/bin/bash
# Razer Leviathan V2 X – Linux Volume Fix
# Uninstaller – restores the device to its original (quiet) factory state

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${BOLD}→${NC} $1"; }
fail() { echo -e "${RED}✗ Error:${NC} $1"; exit 1; }

echo ""
echo -e "${BOLD}Razer Leviathan V2 X – Volume Fix Uninstaller${NC}"
echo "────────────────────────────────────────────────"
echo ""

info "Looking for your Razer Leviathan V2 X..."

CARD_NUMBER=$(aplay -l 2>/dev/null \
  | grep -i "leviathan" \
  | awk '{print $2}' \
  | tr -d ':' \
  | head -1)

if [ -z "$CARD_NUMBER" ]; then
  fail "Device not found. Plug in your Razer Leviathan V2 X and try again."
fi

ok "Found device"
echo ""

info "Restoring original factory volume (about 29%)..."
amixer -c "$CARD_NUMBER" cset numid=4 44 > /dev/null
ok "Volume restored to factory default."
echo ""

info "Saving restored state..."
echo ""
echo -e "  ${YELLOW}You will be asked for your password.${NC}"
echo ""
sudo alsactl store "$CARD_NUMBER"
ok "Done. The device is back to its original (quiet) state."
echo ""
