#!/usr/bin/env bash
# VPS-Bootstrap: Haertung + Docker. Als root auf einem frischen EU-VPS ausfuehren.
# Danach: infra/gitea/ auf den Server kopieren, .env fuellen, 'docker compose up -d'.
# Nur relevant fuer den Gitea-Umzug (docs/migration-to-gitea.md).
set -euo pipefail

echo "==> System aktualisieren"
apt-get update && apt-get -y upgrade

echo "==> Docker installieren"
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi

echo "==> Firewall (SSH + git-SSH + HTTP/S)"
apt-get -y install ufw fail2ban jq
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 2222/tcp     # git ueber SSH (Gitea)
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo "==> Automatische Security-Updates"
apt-get -y install unattended-upgrades
dpkg-reconfigure -f noninteractive unattended-upgrades

echo "==> SSH haerten: Key-only, kein root-Passwort-Login"
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
systemctl restart ssh || systemctl restart sshd

echo "==> Fertig. Naechste Schritte:"
echo "   1) infra/gitea/ auf den Server kopieren (scp/rsync)"
echo "   2) cp .env.example .env  und Werte fuellen"
echo "   3) docker compose --env-file .env up -d"
echo "   4) Gitea einrichten, act_runner registrieren, Branch-Protection setzen"
echo "      (docs/enforcement.md + docs/migration-to-gitea.md)"
