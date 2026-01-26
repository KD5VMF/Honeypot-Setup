# Riverbed Honeypot Kit (Ubuntu Server 24.04 LTS)

This repo is a **drop-in kit** to set up **T-Pot CE** on a fresh Ubuntu Server 24.04 LTS machine with:
- fast, repeatable setup
- an **easy menu** to install / switch profiles
- a **WebUI password reset** tool
- a **safe default firewall** (locks down management ports; exposes only honeypot ports you choose)

> **Safety / best practice**
> - Put your honeypot in a **DMZ / isolated VLAN / VM**.
> - Do **not** store sensitive data on it.
> - Restrict management ports (**64295/64294/64297**) to *your* IP/CIDR only.
> - Assume compromise is possible and monitor from another machine.

---

## Quick start (fresh Ubuntu Server 24.04)

### 0) Prep the box
- Install Ubuntu Server 24.04 LTS
- During install, create your normal admin user (you said you use: **sysop**)
- Enable SSH server during install (recommended)

After boot:
```bash
sudo apt update
sudo apt -y install git
cd ~
git clone https://github.com/YOUR_GITHUB_USER/riverbed-honeypot-kit.git
cd riverbed-honeypot-kit
./menu.sh
```

If you don't have git on the box, you can SCP this folder over, or download the zip and unzip into **/home/sysop**.

---

## What this kit does

### Option A: Install T-Pot CE (recommended)
- Installs prerequisites
- Clones `telekom-security/tpotce`
- Runs the official installer (interactive)
- After reboot, helps you:
  - switch to **standard / mini / sensor / tarpit**
  - reset WebUI credentials
  - apply a firewall configuration

### Option B: Switch profile (after install)
Copies the desired compose file into `~/tpotce/docker-compose.yml` and restarts T-Pot.

### Option C: Reset WebUI password
Resets nginx basic-auth files:
- `~/tpotce/data/nginx/conf/nginxpasswd`
- `~/tpotce/data/nginx/conf/lswebpasswd`

---

## T-Pot profiles (high level)
- **standard**: full “hive” style stack (heavier, best dashboards)
- **mini**: lighter, fewer components
- **sensor**: minimal, meant for shipping logs elsewhere
- **tarpit**: time-wasting tarpit services

(Exact services/ports depend on the T-Pot release and compose template.)

---

## Management ports you must protect
T-Pot commonly uses:
- SSH moved to **64295**
- Web UI reverse proxy **64297**
- Admin UI **64294**

This kit’s firewall helper is designed to **restrict** those to your admin CIDR.

---

## Usage

### Run the menu
```bash
./menu.sh
```

### Or run scripts directly
```bash
scripts/10_prereqs.sh
scripts/20_install_tpot.sh
scripts/30_switch_profile.sh standard
scripts/40_firewall_ufw.sh --admin-cidr 192.168.0.0/24 --open-common
scripts/50_reset_webui_password.sh tpotweb
```

---

## After install: verify
```bash
sudo systemctl status tpot --no-pager
sudo docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
sudo ss -lntp | egrep '(:64294|:64297|:64295)'
```

---

## Where to edit T-Pot settings
T-Pot uses:
- `~/tpotce/.env`
- `~/tpotce/docker-compose.yml`

This kit never hides those; it just automates safe/boring steps.

---

## Disclaimer
This repository provides **defensive** tooling to deploy and manage a honeypot.
You are responsible for ensuring you have permission to run it on your networks and that you comply with laws and policies.
