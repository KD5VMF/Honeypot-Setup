#!/usr/bin/env bash
set -euo pipefail

echo "[*] Installing prerequisites for T-Pot CE on Ubuntu 24.04..."
echo "    - docker.io + compose plugin"
echo "    - git, curl, ufw, apache2-utils (htpasswd)"
echo

sudo apt update
sudo apt -y install \
  ca-certificates curl gnupg lsb-release \
  git ufw apache2-utils \
  docker.io docker-compose-plugin

# enable docker service
sudo systemctl enable --now docker

# add current user to docker group (optional convenience)
if id -nG "$USER" | grep -qw docker; then
  echo "[*] User '$USER' already in docker group."
else
  echo "[*] Adding '$USER' to docker group (log out/in to take effect)."
  sudo usermod -aG docker "$USER" || true
fi

echo
echo "[OK] Prereqs installed."
echo "Tip: If 'docker ps' says permission denied, log out/in or use sudo."
