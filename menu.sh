#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="${ROOT_DIR}/scripts"

bold() { echo -e "\033[1m$*\033[0m"; }
hr() { printf "%0.s-" {1..72}; echo; }

while true; do
  clear || true
  bold "PotShield Setup (T-Pot CE helper) — Ubuntu 24.04 LTS"
  hr
  echo "A) Install Docker Engine + Compose (fixes docker-compose-plugin not found)"
  echo "B) Fetch T-Pot CE into ~/tpotce"
  echo "C) Run T-Pot installer (interactive)"
  echo "D) Switch profile (standard / mini / sensor / tarpit)"
  echo "E) Apply Safe Firewall (management ports LAN-only)"
  echo "F) Reset Web UI password (nginx basic-auth)"
  echo "G) Show common connection URLs/ports"
  echo "Q) Quit"
  hr
  read -rp "Choose: " ans

  case "${ans^^}" in
    A)
      "${SCRIPTS}/10_install_docker_compose.sh"
      read -rp "Done. Press Enter..." _
      ;;
    B)
      "${SCRIPTS}/20_fetch_tpotce.sh"
      read -rp "Done. Press Enter..." _
      ;;
    C)
      "${SCRIPTS}/25_run_tpot_installer.sh"
      read -rp "Done (installer may reboot). Press Enter..." _
      ;;
    D)
      "${SCRIPTS}/30_switch_profile.sh"
      read -rp "Done. Press Enter..." _
      ;;
    E)
      "${SCRIPTS}/40_firewall_ufw.sh"
      read -rp "Done. Press Enter..." _
      ;;
    F)
      "${SCRIPTS}/50_reset_webui_password.sh"
      read -rp "Done. Press Enter..." _
      ;;
    G)
      "${SCRIPTS}/90_show_ports.sh"
      read -rp "Press Enter..." _
      ;;
    Q)
      exit 0
      ;;
    *)
      echo "Invalid choice."
      sleep 1
      ;;
  esac
done
