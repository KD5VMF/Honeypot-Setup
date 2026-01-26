# Uninstall / Cleanup (best effort)

T-Pot is a complex multi-container system. The most reliable “uninstall” is to rebuild the host OS.

If you want a best-effort cleanup:

## Stop containers
```bash
cd ~/tpotce
sudo docker compose down || true
```

## Remove tpotce directory
```bash
rm -rf ~/tpotce
```

## Remove docker (optional)
```bash
sudo apt-get -y purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose-v2 docker.io
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/keyrings/docker.gpg
sudo apt-get update
sudo apt-get -y autoremove --purge
```

## Remove ufw rules (optional)
```bash
sudo ufw disable
sudo apt-get -y purge ufw
```
