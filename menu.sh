#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$ROOT_DIR/scripts"

bold(){ printf "\033[1m%s\033[0m\n" "$*"; }
say(){ printf "%s\n" "$*"; }

need_cmd(){ command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1"; exit 1; }; }

pause(){ read -r -p "Press ENTER to continue..." _; }

banner(){
  clear || true
  bold "Riverbed Honeypot Kit (Ubuntu 24.04) - T-Pot CE helper"
  say "Root dir: $ROOT_DIR"
  say
}

while true; do
  banner
  cat <<'MENU'
Choose an option:
  1) Install prerequisites (Docker, tools)
  2) Install T-Pot CE (official installer)
  3) Switch T-Pot profile (standard/mini/sensor/tarpit)
  4) Reset WebUI username/password
  5) Apply firewall (UFW) - lock management ports, open honeypot ports
  6) Status / quick checks
  q) Quit
MENU
  say
  read -r -p "Selection: " sel
  case "${sel}" in
    1)
      "$SCRIPTS/10_prereqs.sh"
      pause
      ;;
    2)
      "$SCRIPTS/20_install_tpot.sh"
      pause
      ;;
    3)
      read -r -p "Profile (standard|mini|sensor|tarpit): " prof
      "$SCRIPTS/30_switch_profile.sh" "$prof"
      pause
      ;;
    4)
      read -r -p "New WebUI username (e.g. tpotweb): " u
      "$SCRIPTS/50_reset_webui_password.sh" "$u"
      pause
      ;;
    5)
      say "Firewall helper:"
      say "  - locks down 64295/64294/64297 to your admin CIDR"
      say "  - can open a 'common' honeypot port set OR parse compose ports"
      say
      read -r -p "Admin CIDR to allow for management (e.g. 192.168.0.0/24) [auto-detect]: " cidr
      read -r -p "Open common honeypot ports? (y/n) [y]: " yn
      yn="${yn:-y}"
      args=()
      if [ -n "${cidr:-}" ]; then args+=(--admin-cidr "$cidr"); fi
      if [[ "$yn" =~ ^[Yy]$ ]]; then args+=(--open-common); fi
      "$SCRIPTS/40_firewall_ufw.sh" "${args[@]}"
      pause
      ;;
    6)
      "$SCRIPTS/60_status.sh"
      pause
      ;;
    q|Q)
      exit 0
      ;;
    *)
      say "Invalid selection."
      sleep 1
      ;;
  esac
done
