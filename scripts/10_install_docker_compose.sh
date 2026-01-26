#!/usr/bin/env bash
set -euo pipefail

echo "[*] Installing Docker Engine + Compose plugin (Ubuntu 24.04 LTS)..."

sudo apt-get update
sudo apt-get -y install ca-certificates curl gnupg

# Remove common conflicting packages if present (safe on fresh box)
sudo apt-get -y remove docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc 2>/dev/null || true

sudo install -m 0755 -d /etc/apt/keyrings

if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
fi

# Add Docker repo (uses VERSION_CODENAME, expected "noble")
CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME}")"
ARCH="$(dpkg --print-architecture)"

echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update

# Prefer Docker's compose plugin; also install buildx
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Allow current user to run docker without sudo (optional convenience)
if ! id -nG "$USER" | grep -qw docker; then
  sudo usermod -aG docker "$USER"
  echo "[i] Added $USER to docker group. Log out/in for it to take effect."
fi

echo
echo "[*] Verify:"
docker --version || true
docker compose version || true
echo
echo "[OK] Docker + Compose installed."
