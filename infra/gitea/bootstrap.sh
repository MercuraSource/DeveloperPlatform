#!/usr/bin/env bash
# VPS-Bootstrap: Haertung + Docker (gehaertet). Als root auf frischem EU-VPS ausfuehren,
# aus dem Verzeichnis infra/gitea/ (damit daemon.json gefunden wird).
# Danach: .env fuellen, 'docker compose --env-file .env up -d'. Siehe docs/vps-setup.md.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

echo "==> System aktualisieren"
apt-get update && apt-get -y upgrade
apt-get -y install ufw fail2ban jq curl

echo "==> Docker installieren"
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi

echo "==> Docker-Daemon haerten (/etc/docker/daemon.json)"
mkdir -p /etc/docker
if [ -f "$HERE/daemon.json" ]; then
  cp "$HERE/daemon.json" /etc/docker/daemon.json
  echo "    daemon.json aus dem Repo uebernommen."
else
  echo "    WARN: daemon.json nicht gefunden - bitte manuell aus infra/gitea/ kopieren."
fi
systemctl restart docker || true

echo "==> Firewall (nur SSH + git-SSH + HTTP/S)"
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 2222/tcp      # git ueber SSH (Gitea)
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo "==> ufw-docker: Docker soll die Firewall NICHT umgehen"
# Docker schreibt eigene iptables-Regeln und umgeht UFW. ufw-docker korrigiert das.
if [ ! -x /usr/local/bin/ufw-docker ]; then
  curl -fsSL -o /usr/local/bin/ufw-docker \
    https://raw.githubusercontent.com/chaifeng/ufw-docker/master/ufw-docker
  chmod +x /usr/local/bin/ufw-docker
fi
/usr/local/bin/ufw-docker install
systemctl restart ufw || true

echo "==> Automatische Security-Updates"
apt-get -y install unattended-upgrades
dpkg-reconfigure -f noninteractive unattended-upgrades

echo "==> SSH haerten: Key-only, kein root-Passwort-Login"
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
systemctl restart ssh || systemctl restart sshd

echo "==> DevOps-Deploy-User (non-root, docker+sudo)"
DEPLOY_USER="${DEPLOY_USER:-deploy}"
if ! id "$DEPLOY_USER" >/dev/null 2>&1; then
  adduser --disabled-password --gecos "" "$DEPLOY_USER"
  usermod -aG docker,sudo "$DEPLOY_USER"
fi
if [ -n "${DEPLOY_PUBKEY:-}" ]; then
  install -d -m 700 -o "$DEPLOY_USER" -g "$DEPLOY_USER" "/home/$DEPLOY_USER/.ssh"
  printf '%s\n' "$DEPLOY_PUBKEY" > "/home/$DEPLOY_USER/.ssh/authorized_keys"
  chmod 600 "/home/$DEPLOY_USER/.ssh/authorized_keys"
  chown "$DEPLOY_USER:$DEPLOY_USER" "/home/$DEPLOY_USER/.ssh/authorized_keys"
  echo "    SSH-Key fuer $DEPLOY_USER gesetzt."
else
  echo "    HINWEIS: DEPLOY_PUBKEY nicht gesetzt - SSH-Key fuer $DEPLOY_USER manuell hinterlegen."
fi

echo "==> Fertig. Naechste Schritte:"
echo "   1) cp .env.example .env  und Werte fuellen"
echo "   2) docker compose --env-file .env up -d"
echo "   3) Gitea einrichten, act_runner registrieren, Branch-Protection setzen"
echo "      (docs/vps-setup.md + docs/enforcement.md)"
echo "   4) Optionale Haertung (userns-remap, rootless, Runner-Isolation): docs/hardening.md"
