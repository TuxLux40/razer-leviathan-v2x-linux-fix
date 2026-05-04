#!/bin/bash
# Razer Leviathan V2 X – Linux Volume Fix
# Installer script

set -e

DEVICE_NAME="Razer Leviathan V2 X"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${BOLD}→${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
fail() { echo -e "${RED}✗ Error:${NC} $1"; exit 1; }

# Convert raw device value (0–151) to a human-readable percentage
to_pct() { echo $(( $1 * 100 / 151 )); }

echo ""
echo -e "${BOLD}Razer Leviathan V2 X – Linux Volume Fix${NC}"
echo "────────────────────────────────────────"
echo ""

# ── 1. Check that the device is plugged in ───────────────────────────────────
info "Looking for your $DEVICE_NAME..."

CARD_NUMBER=$(aplay -l 2>/dev/null \
  | grep -i "leviathan" \
  | awk '{print $2}' \
  | tr -d ':' \
  | head -1)

if [ -z "$CARD_NUMBER" ]; then
  fail "Device not found. Make sure your $DEVICE_NAME is plugged in via USB-C and try again."
fi

ok "Found $DEVICE_NAME"
echo ""

# ── 2. Read the current hidden volume value ───────────────────────────────────
info "Checking current internal volume setting..."

CURRENT=$(amixer -c "$CARD_NUMBER" cget numid=4 2>/dev/null \
  | grep '^\s*: values=' \
  | grep -oP '\d+' \
  | head -1)

if [ -z "$CURRENT" ]; then
  fail "Could not read the internal volume control. Your device might not need this fix."
fi

CURRENT_PCT=$(to_pct "$CURRENT")
ok "Current internal volume: about ${CURRENT_PCT}%"

if [ "$CURRENT_PCT" -ge 60 ]; then
  warn "The internal volume is already at ${CURRENT_PCT}% — the fix may already be installed."
  warn "Run uninstall.sh first if you want to start fresh."
  echo ""
fi

# ── 3. Apply the fix ─────────────────────────────────────────────────────────
# 100 out of 151 (about 66%) is a safe default: loud enough at full system
# volume, with enough headroom that the device won't distort on loud audio.
TARGET_RAW=100
TARGET_PCT=$(to_pct "$TARGET_RAW")

info "Applying fix (raising internal volume from ~${CURRENT_PCT}% to ~${TARGET_PCT}%)..."
amixer -c "$CARD_NUMBER" cset numid=4 "$TARGET_RAW" > /dev/null
ok "Done."
echo ""

# ── 4. Save the setting permanently ──────────────────────────────────────────
info "Saving the setting so it survives reboots and unplugging..."
echo ""
echo -e "  ${YELLOW}You will be asked for your password — this is required to save the${NC}"
echo -e "  ${YELLOW}setting to a system file. Nothing else will be changed.${NC}"
echo ""

sudo alsactl store "$CARD_NUMBER"
ok "Setting saved permanently."
echo ""

# ── 5. Done ───────────────────────────────────────────────────────────────────
echo -e "${GREEN}${BOLD}All done!${NC}"
echo ""
echo "  Your $DEVICE_NAME will now play at full volume on Linux."
echo "  The fix is permanent — it applies automatically every time"
echo "  you plug the device in or restart your computer."
echo ""
echo "  If the volume still feels off, run:"
echo ""
echo -e "  ${BOLD}Too loud / crackling:${NC}  bash tune.sh lower"
echo -e "  ${BOLD}Still too quiet:${NC}        bash tune.sh louder"
echo ""
echo "  To remove this fix entirely: bash uninstall.sh"
echo ""
