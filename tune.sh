#!/bin/bash
# Razer Leviathan V2 X – Volume Fine-Tuning
# Usage:
#   bash tune.sh louder     – increase by ~7%
#   bash tune.sh lower      – decrease by ~7%
#   bash tune.sh show       – show current level
#   bash tune.sh set 80     – set to a specific percentage (0–100)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${BOLD}→${NC} $1"; }
fail() { echo -e "${RED}✗ Error:${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}!${NC} $1"; }

to_pct() { echo $(( $1 * 100 / 151 )); }
to_raw() { echo $(( $1 * 151 / 100 )); }

CARD_NUMBER=$(aplay -l 2>/dev/null \
  | grep -i "leviathan" \
  | awk '{print $2}' \
  | tr -d ':' \
  | head -1)

[ -z "$CARD_NUMBER" ] && fail "Device not found. Plug in your Razer Leviathan V2 X and try again."

CURRENT_RAW=$(amixer -c "$CARD_NUMBER" cget numid=4 2>/dev/null \
  | grep '^\s*: values=' \
  | grep -oP '\d+' \
  | head -1)

[ -z "$CURRENT_RAW" ] && fail "Could not read current volume."

CURRENT_PCT=$(to_pct "$CURRENT_RAW")

echo ""
echo -e "${BOLD}Razer Leviathan V2 X – Volume Tuning${NC}"
echo "──────────────────────────────────────"
echo ""

ACTION="${1:-show}"

case "$ACTION" in
  louder)
    NEW_RAW=$(( CURRENT_RAW + 11 ))
    [ "$NEW_RAW" -gt 151 ] && NEW_RAW=151
    ;;
  lower)
    NEW_RAW=$(( CURRENT_RAW - 11 ))
    [ "$NEW_RAW" -lt 0 ] && NEW_RAW=0
    ;;
  set)
    INPUT_PCT="${2:-}"
    if [ -z "$INPUT_PCT" ] || ! [[ "$INPUT_PCT" =~ ^[0-9]+$ ]] || [ "$INPUT_PCT" -gt 100 ]; then
      fail "Please provide a percentage between 0 and 100. Example: bash tune.sh set 80"
    fi
    NEW_RAW=$(to_raw "$INPUT_PCT")
    ;;
  show)
    echo -e "  Current internal volume level: ${BOLD}~${CURRENT_PCT}%${NC}"
    echo ""
    echo "  To change it:"
    echo "    bash tune.sh louder      – increase"
    echo "    bash tune.sh lower       – decrease"
    echo "    bash tune.sh set 80      – set to a specific percentage"
    echo ""
    exit 0
    ;;
  *)
    fail "Unknown option '$ACTION'. Use: louder, lower, show, or set <percentage>"
    ;;
esac

NEW_PCT=$(to_pct "$NEW_RAW")

info "Changing internal volume: ~${CURRENT_PCT}% → ~${NEW_PCT}%"
amixer -c "$CARD_NUMBER" cset numid=4 "$NEW_RAW" > /dev/null
ok "Done."
echo ""

info "Saving permanently (you may be asked for your password)..."
sudo alsactl store "$CARD_NUMBER"
ok "Saved. Will apply automatically on every boot and plug-in."
echo ""

if [ "$NEW_PCT" -ge 93 ]; then
  warn "This is very loud. If audio sounds distorted, run: bash tune.sh lower"
elif [ "$NEW_PCT" -le 26 ]; then
  warn "This is very quiet. If audio is too soft, run: bash tune.sh louder"
fi
