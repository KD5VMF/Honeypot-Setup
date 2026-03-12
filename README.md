# T-PotShield Setup (T-Pot CE on Ubuntu 24.04 LTS)

T-PotShield is a **copy/paste friendly installer + menu** that helps you deploy **T-Pot CE** (Telekom Security’s multi-honeypot platform) on a fresh **Ubuntu Server 24.04 LTS** box.

It also includes the *two most important “gotchas”* people hit in real installs:

1) **Docker Compose plugin not found** on a fresh Ubuntu install (fixed by adding Docker’s official repo), and  
2) **DMZ / “all ports forwarded” routers** accidentally exposing T-Pot’s **management** ports to the public internet (fixed by a safe UFW ruleset).

> ⚠️ **Safety warning**
> A honeypot is meant to be attacked. Put this system in a **DMZ / isolated VLAN / separate host**, keep backups off it, and keep management ports restricted to your LAN or VPN.

---

## What you get

### Web GUI
After install, T-Pot typically exposes:

- **Landing Page / Web UI:** `https://<HONEYPOT_IP>:64297`
- **Admin UI:** `https://<HONEYPOT_IP>:64294`
- **SSH:** usually moved to `:64295` (varies by installer choices)

If your ports differ, confirm on the box:
```bash
sudo ss -lntp | egrep '(:64294|:64295|:64297|:22)'
```

---

## Hardware sizing (pick the right profile)

T-Pot can run on many systems, but **RAM + disk** matter most.

### Recommended (smooth experience)
- 8–16 GB RAM (more is better)
- 4+ CPU threads
- 128 GB+ disk (logs grow!)
- Stable internet

### “Small PC / Mini PC / old box”
Use **mini** or **sensor** profile if you’re tight on resources:
- 4–8 GB RAM
- smaller disk (still try for 64–128 GB)

### “I want maximum noise / most honeypots”
Use **standard** profile (requires more RAM + disk).

---

## Network choices: DMZ vs Port Forwarding

### Best practice (recommended)
- **DMZ OFF**
- Use **Port Forwarding** only for ports you want attackers to hit (e.g. 80/443/22/23/etc.)
- Keep **management ports** (64294/64295/64297) **NOT forwarded**

### DMZ (works, but blunt)
Consumer-router “DMZ host” means:
> “Forward **all unsolicited inbound WAN traffic** to this internal IP.”

If you set DMZ host = your honeypot, you will get lots of attack traffic — but you MUST
**block management ports from the internet** on the honeypot (UFW rules in this repo do that).

---

## One-command start (fresh Ubuntu 24.04)

SSH into your new Ubuntu Server and run:

```bash
sudo apt update
sudo apt -y install git
cd ~
git clone https://github.com/kd5vmf/T-PotShield-Setup.git
cd T-PotShield-Setup
chmod +x menu.sh scripts/*.sh
./menu.sh
```

---

## Menu options

### A) Install Docker + Compose (fixes “Unable to locate docker-compose-plugin”)
- Adds Docker’s official apt repo
- Installs Docker Engine + Compose plugin
- Verifies `docker compose version`

### B) Fetch T-Pot CE
- Clones `telekom-security/tpotce` into `~/tpotce`

### C) Run T-Pot installer
- Runs the official interactive installer
- You’ll be prompted for credentials/ports
- A reboot is usually required

### D) Switch profile
- standard / mini / sensor / tarpit
- Copies the matching compose template into place, then restarts

### E) Apply Safe Firewall for Management Ports (LAN-only)
- Allows 64294/64295/64297 **only from your LAN CIDR**
- Keeps default incoming = deny, outgoing = allow
- Designed to protect you even if your router DMZ forwards everything

### F) Reset Web UI password (nginx basic-auth)
- Rewrites the htpasswd files used by the reverse proxy

---

## After install: how to connect

### SSH
Try:
```bash
ssh -p 64295 sysop@<HONEYPOT_IP>
```

If that fails, check the listening port:
```bash
sudo ss -lntp | grep sshd
```

### Web
Open:
- `https://<HONEYPOT_IP>:64297`  (Landing Page)
- `https://<HONEYPOT_IP>:64294`  (Admin UI)

---

## Troubleshooting

### “E: Unable to locate package docker-compose-plugin”
Run menu option **A**, or directly:
```bash
scripts/10_install_docker_compose.sh
```

### I enabled router DMZ — how do I keep admin ports safe?
Run menu option **E** and use your LAN range:
```bash
scripts/40_firewall_ufw.sh --admin-cidr 192.168.0.0/24
```

Then verify:
```bash
sudo ufw status verbose
```

---

## Uninstall (simple)
This repo does not fully remove T-Pot. To wipe the box clean, the easiest approach is a reinstall.
If you want a “best effort” cleanup, see `docs/UNINSTALL.md`.

---

## Disclaimer
This project helps you deploy and harden a honeypot system. Use at your own risk.
Do not deploy a honeypot on a network with sensitive devices unless you understand the risks.

