#!/usr/bin/env bash
set -euo pipefail

TPOT_DIR="${HOME}/tpotce"
COMPOSE="${TPOT_DIR}/docker-compose.yml"

if [[ ! -d "${TPOT_DIR}" ]]; then
  echo "[ERR] ${TPOT_DIR} not found. Run menu option B first."
  exit 1
fi

echo "Choose profile:"
echo "  1) standard"
echo "  2) mini"
echo "  3) sensor"
echo "  4) tarpit"
read -rp "Selection [1-4]: " sel

case "$sel" in
  1) prof="standard" ;;
  2) prof="mini" ;;
  3) prof="sensor" ;;
  4) prof="tarpit" ;;
  *) echo "[ERR] invalid selection"; exit 1 ;;
esac

# Locate compose templates (these paths may differ by version)
TEMPLATE=""
for p in \
  "${TPOT_DIR}/compose/${prof}.yml" \
  "${TPOT_DIR}/compose/${prof}.yaml" \
  "${TPOT_DIR}/docker/${prof}.yml" \
  "${TPOT_DIR}/docker/${prof}.yaml" \
  "${TPOT_DIR}/docker-compose.${prof}.yml" \
  "${TPOT_DIR}/docker-compose.${prof}.yaml"
do
  if [[ -f "$p" ]]; then TEMPLATE="$p"; break; fi
done

if [[ -z "${TEMPLATE}" ]]; then
  echo "[ERR] Could not find a compose template for profile '${prof}'."
  echo "      Search for templates in: ${TPOT_DIR}"
  echo "      Example: find ${TPOT_DIR} -maxdepth 3 -type f -iname '*${prof}*y*ml'"
  exit 1
fi

echo "[*] Using template: ${TEMPLATE}"
cp -f "${TEMPLATE}" "${COMPOSE}"
echo "[*] Restarting stack..."
cd "${TPOT_DIR}"

# Works with compose plugin (docker compose). If that fails, try docker-compose.
if docker compose version >/dev/null 2>&1; then
  sudo docker compose up -d
elif command -v docker-compose >/dev/null 2>&1; then
  sudo docker-compose up -d
else
  echo "[ERR] Neither 'docker compose' nor 'docker-compose' available."
  exit 1
fi

echo "[OK] Profile switched to: ${prof}"
