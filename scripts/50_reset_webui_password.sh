#!/usr/bin/env bash
set -euo pipefail

TPOT_DIR="${HOME}/tpotce"
CONF_DIR="${TPOT_DIR}/data/nginx/conf"

# Default username used by many setups
DEFAULT_USER="tpotweb"

USER_ARG="${1:-}"

WEB_USER="${USER_ARG:-$DEFAULT_USER}"

if [[ ! -d "${CONF_DIR}" ]]; then
  echo "[ERR] nginx conf dir not found: ${CONF_DIR}"
  echo "      Is T-Pot installed and running?"
  exit 1
fi

if ! command -v htpasswd >/dev/null 2>&1; then
  echo "[*] Installing apache2-utils (for htpasswd)..."
  sudo apt-get update -y
  sudo apt-get install -y apache2-utils
fi

echo "[*] Resetting Web UI password for user: ${WEB_USER}"
echo "    You will be prompted for a new password."

# These are commonly mounted into the nginx container
FILES=()
[[ -f "${CONF_DIR}/nginxpasswd" ]] && FILES+=("${CONF_DIR}/nginxpasswd")
[[ -f "${CONF_DIR}/lswebpasswd" ]] && FILES+=("${CONF_DIR}/lswebpasswd")

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "[ERR] Could not find nginxpasswd/lswebpasswd in ${CONF_DIR}"
  echo "      Inspect mounts with: sudo docker inspect nginx | grep -A2 Mounts"
  exit 1
fi

for f in "${FILES[@]}"; do
  echo "[*] Updating: ${f}"
  sudo htpasswd -B -c "${f}" "${WEB_USER}"
done

echo
echo "[OK] Password updated. If the UI still doesn't accept it, restart nginx container:"
echo "    sudo docker restart nginx  (container name may vary; check 'docker ps')"
