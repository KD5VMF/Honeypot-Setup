#!/usr/bin/env bash
set -euo pipefail

echo "Common T-Pot connection points (often used):"
echo "  Landing Page: https://<HONEYPOT_IP>:64297"
echo "  Admin UI    : https://<HONEYPOT_IP>:64294"
echo "  SSH         : ssh -p 64295 <user>@<HONEYPOT_IP>"
echo
echo "Confirm what's actually listening on THIS box:"
sudo ss -lntp | egrep '(:64294|:64295|:64297|:22|:80|:443)' || true
