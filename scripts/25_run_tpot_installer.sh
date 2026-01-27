cat > ~/Honeypot-Setup/scripts/25_run_tpot_installer.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

TPOT_DIR="${HOME}/tpotce"

if [[ ! -d "${TPOT_DIR}" ]]; then
  echo "[ERR] ${TPOT_DIR} not found. Run menu option B first."
  exit 1
fi

echo "[*] Launching official T-Pot installer (interactive)..."
echo "    IMPORTANT: T-Pot wants the installer started as a regular user."
echo "    It will ask for sudo when needed."
echo

cd "${TPOT_DIR}"

if [[ -x "./install.sh" ]]; then
  ./install.sh
elif [[ -x "./installer/install.sh" ]]; then
  ./installer/install.sh
elif [[ -x "./iso/installer/install.sh" ]]; then
  ./iso/installer/install.sh
else
  echo "[ERR] Could not find install.sh. Check the T-Pot repo layout."
  echo "      Try: ls -la ${TPOT_DIR}"
  exit 1
fi
EOF

chmod +x ~/Honeypot-Setup/scripts/25_run_tpot_installer.sh
