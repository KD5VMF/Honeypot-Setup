#!/usr/bin/env bash
set -euo pipefail

USER_NAME="${1:-}"
if [ -z "$USER_NAME" ]; then
  echo "Usage: $0 <new_webui_username>"
  exit 1
fi

TPOT_DIR="$HOME/tpotce"
NG1="$TPOT_DIR/data/nginx/conf/nginxpasswd"
NG2="$TPOT_DIR/data/nginx/conf/lswebpasswd"

if [ ! -f "$NG1" ] || [ ! -f "$NG2" ]; then
  echo "Could not find nginx password files:"
  echo "  $NG1"
  echo "  $NG2"
  echo "Make sure T-Pot has been installed and started at least once."
  exit 1
fi

command -v htpasswd >/dev/null 2>&1 || {
  echo "htpasswd not found. Install it:"
  echo "  sudo apt -y install apache2-utils"
  exit 1
}

echo "[*] Resetting WebUI credentials to user: $USER_NAME"
echo "You will be prompted for the password twice (same password recommended)."
echo

sudo htpasswd -B -c "$NG1" "$USER_NAME"
sudo htpasswd -B -c "$NG2" "$USER_NAME"

echo "[*] Restarting nginx container..."
sudo docker restart nginx >/dev/null 2>&1 || true

echo
echo "[OK] WebUI credentials reset."
echo "Login at: https://<tpot-ip>:64297"
