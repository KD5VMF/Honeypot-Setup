#!/usr/bin/env bash
set -euo pipefail

echo "[*] Installing T-Pot CE using the official installer..."
echo "This step will:"
echo "  - clone telekom-security/tpotce into ~/tpotce (if missing)"
echo "  - run ./install.sh (interactive)"
echo "After installer finishes it will ask you to reboot and SSH back on tcp/64295."
echo

# ensure git exists
command -v git >/dev/null 2>&1 || { echo "git not found. Run scripts/10_prereqs.sh first."; exit 1; }

cd ~
if [ ! -d "$HOME/tpotce" ]; then
  git clone https://github.com/telekom-security/tpotce "$HOME/tpotce"
else
  echo "[*] ~/tpotce already exists; updating..."
  cd "$HOME/tpotce"
  git pull --ff-only || true
fi

cd "$HOME/tpotce"

echo
echo "[*] Launching official installer..."
echo "    Follow the prompts."
echo
./install.sh

echo
echo "[DONE] Installer finished. If it asked you to reboot, do it now:"
echo "  sudo reboot"
