# Setup Guide (end-to-end)

This is the “full walk-through” version.

## 1) Build the new box
1. Install **Ubuntu Server 24.04 LTS**
2. Create user: **sysop** (admin)
3. Enable OpenSSH server during install (or install later)

## 2) Get this repo onto the box
### Preferred (git)
```bash
sudo apt update
sudo apt -y install git
cd /home/sysop
git clone https://github.com/YOUR_GITHUB_USER/riverbed-honeypot-kit.git
cd riverbed-honeypot-kit
```

### If you have no git
Copy the zip to `/home/sysop`, then:
```bash
cd /home/sysop
unzip riverbed-honeypot-kit.zip
cd riverbed-honeypot-kit
```

## 3) Run the menu
```bash
./menu.sh
```

Recommended order:
1) Prereqs
2) Install T-Pot (choose profile during install; if you mis-pick you can switch later)
3) After reboot: Switch profile if needed
4) Reset WebUI password (so you know it)
5) Apply firewall rules (lock down management ports!)

## 4) Connect after install
T-Pot typically moves SSH to:
```bash
ssh -p 64295 sysop@<tpot-ip>
```

Web UI:
- `https://<tpot-ip>:64297`

## 5) Options
### Switch profiles
```bash
scripts/30_switch_profile.sh mini
```

### Reset WebUI credentials
```bash
scripts/50_reset_webui_password.sh tpotweb
```

### Firewall
- Restrict management to LAN / your IP:
```bash
scripts/40_firewall_ufw.sh --admin-cidr 192.168.0.0/24 --open-common
```

## 6) Verify
```bash
scripts/60_status.sh
```
