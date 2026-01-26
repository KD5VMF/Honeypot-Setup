#!/usr/bin/env bash
set -euo pipefail

TPOT_DIR="${HOME}/tpotce"

if [[ ! -d "${TPOT_DIR}" ]]; then
  echo "[ERR] ${TPOT_DIR} not found. Run menu option B first."
  exit 1
fi

echo "[*] Launching official T-Pot installer (interactive)..."
echo "    Follow prompts carefully (ports/credentials). Reboot may be required."
echo

cd "${TPOT_DIR}"

# The T-Pot repo provides an install script; path/name may change over time.
# We try common locations.
if [[ -x "./install.sh" ]]; then
  sudo ./install.sh
elif [[ -x "./installer/install.sh" ]]; then
  sudo ./installer/install.sh
elif [[ -x "./iso/installer/install.sh" ]]; then
  sudo ./iso/installer/install.sh
else
  echo "[ERR] Could not find install.sh. Check the T-Pot repo layout."
  echo "      Try: ls -la ${TPOT_DIR}"
  exit 1
fi
