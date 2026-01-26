#!/usr/bin/env bash
set -euo pipefail

ADMIN_CIDR=""
OPEN_COMMON="false"

while [ $# -gt 0 ]; do
  case "$1" in
    --admin-cidr) ADMIN_CIDR="$2"; shift 2;;
    --open-common) OPEN_COMMON="true"; shift 1;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

detect_cidr(){
  # Try to detect the primary LAN IPv4 and assume /24 if private.
  ip -4 route get 1.1.1.1 2>/dev/null | awk '/src/ {print $NF; exit}' || true
}

if [ -z "${ADMIN_CIDR}" ]; then
  ipaddr="$(detect_cidr)"
  if [ -n "$ipaddr" ]; then
    # naive /24 for common home LANs
    ADMIN_CIDR="$(echo "$ipaddr" | awk -F. '{print $1"."$2"."$3".0/24"}')"
  else
    ADMIN_CIDR="192.168.0.0/24"
  fi
fi

TPOT_DIR="$HOME/tpotce"
COMPOSE="$TPOT_DIR/docker-compose.yml"

echo "[*] Applying UFW rules for T-Pot"
echo "    Admin CIDR allowed to management ports: $ADMIN_CIDR"
echo

sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH management (T-Pot moves SSH to 64295)
sudo ufw allow from "$ADMIN_CIDR" to any port 64295 proto tcp
# Web UI mgmt ports
sudo ufw allow from "$ADMIN_CIDR" to any port 64294 proto tcp
sudo ufw allow from "$ADMIN_CIDR" to any port 64297 proto tcp

# Optional: open common honeypot ports (safe-ish baseline)
if [ "$OPEN_COMMON" = "true" ]; then
  echo "[*] Opening common honeypot ports (baseline)..."
  # Common attacker targets
  for p in 21 22 23 25 53 80 110 111 135 139 143 443 445 465 587 993 995 1433 1521 2049 2375 3306 3389 5432 5900 6379 8080 8443; do
    sudo ufw allow "$p"/tcp || true
  done
  # UDP targets
  for p in 53 123 161 389 500 1900 623; do
    sudo ufw allow "$p"/udp || true
  done
fi

# If T-Pot is installed, open all host-mapped ports from docker-compose (best accuracy).
if [ -f "$COMPOSE" ]; then
  echo "[*] Parsing docker-compose.yml for published ports to open (host side)..."
  # Extract patterns like: "0.0.0.0:2222->22/tcp" or ":2222->22"
  # This is best-effort; you can always edit UFW after.
  ports="$(sudo docker compose -f "$COMPOSE" ps --services >/dev/null 2>&1 && true)"
  # Parse file for published ports lines: - "22:22" or - "0.0.0.0:22:22"
  # Keep only host ports.
  host_ports="$(grep -RhoE '([0-9]{1,5}):[0-9]{1,5}(/(tcp|udp))?' "$COMPOSE" | awk -F: '{print $1}' | sort -n | uniq || true)"
  for hp in $host_ports; do
    # Skip management ports; already restricted by CIDR
    if [ "$hp" = "64294" ] || [ "$hp" = "64295" ] || [ "$hp" = "64297" ]; then
      continue
    fi
    # Open TCP by default; many compose lines omit protocol.
    sudo ufw allow "$hp"/tcp || true
  done
fi

sudo ufw --force enable
sudo ufw status verbose

echo
echo "[OK] Firewall applied."
echo "Management ports are restricted to: $ADMIN_CIDR"
echo "If you need remote management from a single IP, use /32 (e.g., 1.2.3.4/32)."
