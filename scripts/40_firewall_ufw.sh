#!/usr/bin/env bash
set -euo pipefail

ADMIN_CIDR=""
OPEN_COMMON="no"

usage() {
  cat <<'EOF'
Usage:
  scripts/40_firewall_ufw.sh --admin-cidr 192.168.0.0/24 [--open-common]

What it does:
  - Default deny incoming, allow outgoing
  - Allows T-Pot management ports (64294/64295/64297) ONLY from --admin-cidr
  - Optionally opens common honeypot ports to the world (--open-common)

Notes:
  - If your router DMZ forwards all ports to the honeypot, this protects management ports.
  - If you use port forwarding instead of DMZ, you may not need --open-common here.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --admin-cidr)
      ADMIN_CIDR="${2:-}"; shift 2;;
    --open-common)
      OPEN_COMMON="yes"; shift;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "[ERR] unknown argument: $1"; usage; exit 1;;
  esac
done

if [[ -z "${ADMIN_CIDR}" ]]; then
  read -rp "Enter admin CIDR to ALLOW for management (example 192.168.0.0/24): " ADMIN_CIDR
fi

echo "[*] Installing ufw (if needed)..."
sudo apt-get update -y
sudo apt-get install -y ufw

echo "[*] Setting defaults..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "[*] Allow management ports ONLY from ${ADMIN_CIDR}..."
for p in 64294 64295 64297; do
  sudo ufw allow from "${ADMIN_CIDR}" to any port "${p}" proto tcp
done

# Optional: allow SSH on 22 from admin CIDR (helps if SSH wasn't moved)
sudo ufw allow from "${ADMIN_CIDR}" to any port 22 proto tcp

if [[ "${OPEN_COMMON}" == "yes" ]]; then
  echo "[*] Opening common honeypot ports to the world..."
  # Keep this conservative; users can add more as needed.
  for p in 80 443 21 22 23 25 53 110 143 445 3389 5900; do
    sudo ufw allow "${p}"/tcp || true
  done
  sudo ufw allow 53/udp || true
fi

echo
echo "[*] Enabling firewall..."
sudo ufw --force enable

echo
sudo ufw status verbose
echo
echo "[OK] Firewall applied."
