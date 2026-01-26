#!/usr/bin/env bash
set -euo pipefail

echo "[*] Host:"
hostname
echo

echo "[*] T-Pot service:"
sudo systemctl status tpot --no-pager || true
echo

echo "[*] Containers:"
sudo docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' || true
echo

echo "[*] Listening (management ports):"
sudo ss -lntp | egrep '(:64294|:64295|:64297)' || true
echo

echo "[*] UFW:"
sudo ufw status verbose || true
