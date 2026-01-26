#!/usr/bin/env bash
set -euo pipefail

TARGET="${HOME}/tpotce"

if [[ -d "${TARGET}/.git" ]]; then
  echo "[i] ~/tpotce already exists; updating..."
  git -C "${TARGET}" pull --ff-only
else
  echo "[*] Cloning telekom-security/tpotce into ~/tpotce..."
  git clone https://github.com/telekom-security/tpotce.git "${TARGET}"
fi

echo "[OK] T-Pot CE repo is at: ${TARGET}"
