#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-}"
if [ -z "$PROFILE" ]; then
  echo "Usage: $0 standard|mini|sensor|tarpit"
  exit 1
fi

TPOT_DIR="$HOME/tpotce"
COMPOSE_DIR="$TPOT_DIR/compose"
ACTIVE="$TPOT_DIR/docker-compose.yml"

if [ ! -d "$TPOT_DIR" ]; then
  echo "Missing $TPOT_DIR. Install T-Pot first."
  exit 1
fi
if [ ! -d "$COMPOSE_DIR" ]; then
  echo "Missing $COMPOSE_DIR. Your T-Pot layout is unexpected."
  echo "List of $TPOT_DIR:"
  ls -la "$TPOT_DIR"
  exit 1
fi

case "$PROFILE" in
  standard|mini|sensor|tarpit) ;;
  *) echo "Invalid profile: $PROFILE"; exit 1;;
esac

SRC="$COMPOSE_DIR/$PROFILE.yml"
if [ ! -f "$SRC" ]; then
  echo "Compose template not found: $SRC"
  echo "Available templates:"
  ls -1 "$COMPOSE_DIR"
  exit 1
fi

echo "[*] Switching T-Pot profile to: $PROFILE"
sudo systemctl stop tpot || true

echo "[*] Bringing down current stack (remove orphans/volumes for clean switch)..."
sudo docker compose -f "$ACTIVE" down -v --remove-orphans || true

echo "[*] Backing up current compose..."
cp -a "$ACTIVE" "$TPOT_DIR/docker-compose.prev.bak.$(date +%F_%H%M%S)" || true

echo "[*] Activating new compose: $SRC -> $ACTIVE"
cp -a "$SRC" "$ACTIVE"

echo "[*] Sanity check: ensure no LLM services remain referenced..."
if grep -qE 'beelzebub|galah' "$ACTIVE"; then
  echo "[WARN] New compose still references LLM services. Are you sure you chose the right profile?"
fi

echo "[*] Starting T-Pot..."
sudo systemctl start tpot

echo
echo "[OK] Switched profile. Give it ~1-2 minutes on first start to pull images."
echo "Check:"
echo "  sudo systemctl status tpot --no-pager"
echo "  sudo docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
