# VPS + Gitea Setup (EU-VPS)

Der EU-VPS traegt das **Enforcement-Rueckgrat**: self-hosted Gitea/Forgejo (Repo +
Branch-Protection) + act_runner (CI). Alles EU/self-hosted, keine Tier- oder Minutenlimits.
Spaeter kann derselbe VPS auch die Laufzeit (z. B. Nextcloud) hosten — das bleibt eine
separate Entscheidung.

## 1. VPS provisionieren

- **Groesse:** ein kleiner ARM-Server (~4-6 EUR/Monat) reicht fuer Gitea + Runner
  (+ spaeter ein kleines Nextcloud). x86 nur bei x86-only-Images; Gitea, act_runner
  und Nextcloud haben ARM-Images.
- **Region:** EU-Rechenzentrum (Datenresidenz).
- **AVV/DPA** mit dem Hosting-Provider abschliessen; **EU-Rechenzentrum** waehlen
  (DSGVO, `gdpr/DSGVO-Leitfaden.md`).

## 2. Haerten + Docker

`infra/gitea/` auf den Server kopieren, dann `bootstrap.sh` **aus diesem Verzeichnis** als
root ausfuehren (damit `daemon.json` gefunden wird): Firewall (SSH 22 + git-SSH 2222 +
80/443), SSH-Key-only, Auto-Updates, gehaerteter Docker-Daemon (`daemon.json`) und
`ufw-docker` (damit Docker die Firewall nicht umgeht). Optional vorab die Env
`DEPLOY_USER`/`DEPLOY_PUBKEY` setzen -> bootstrap legt einen non-root Deploy-User
(docker+sudo) mit SSH-Key an. Details + optionale Stufen: `docs/hardening.md`.

## 3. Gitea + CI-Runner starten

```bash
cp .env.example .env      # Werte fuellen, NIE committen
chmod 600 .env
docker compose --env-file .env up -d
```

Der Runner beruehrt bewusst NICHT den Host-Docker-Socket, sondern spricht ueber einen
read-only socket-proxy (siehe `docs/hardening.md`). Ersten CI-Lauf pruefen.

Danach in Gitea (Web-UI ueber SSH-Tunnel: `ssh -L 3000:localhost:3000 <vps>` -> localhost:3000):
- Ersten Nutzer anlegen (Registrierung ist deaktiviert).
- Actions ist aktiviert; **act_runner registrieren** (Token aus Settings -> Actions ->
  Runners in die `.env` -> `RUNNER_TOKEN`, dann `docker compose up -d` erneut).
- Runner-Labels/Capacity kommen aus `infra/gitea/runner-config.yaml` (`ubuntu-latest`
  -> Image); der Runner laedt sie ueber `CONFIG_FILE`. Ersten CI-Lauf pruefen.

## 4. Dieses Repo auf Gitea umziehen

Variante A (Gitea-Import): "Neue Migration" -> GitHub-URL + Token -> importiert Code + History.

Variante B (manuell):
```bash
git remote set-url origin ssh://git@<vps>:2222/<user>/DeveloperPlatform.git
git push --mirror
```

Danach `origin` zeigt auf Gitea; SSH-Key beim Gitea-Nutzer hinterlegen.

## 5. Erzwingung scharf schalten (PFLICHT)

- **Branch-Protection** auf `main` (Gitea -> Repo -> Settings -> Branches):
  PR-Pflicht, **Approvals >= 1**, Required Check **checks**, Force-Push aus.
- **CI**: `.gitea/workflows/checks.yaml` liegt im Repo; `lint-test` mit echten Befehlen
  fuellen. Als Required Check eintragen.
- Details: `docs/enforcement.md`.

## 6. Lokal (dein Rechner)

- `bash git-hooks/install.sh`, `chmod +x .claude/hooks/*.sh`.
- git ueber SSH auf Port 2222; Web-UI nur ueber SSH-Tunnel (nicht oeffentlich).

## DSGVO-Kurzcheck

- [ ] VPS in EU-Rechenzentrum, AVV mit Provider.
- [ ] Gitea-Web nicht offen im Netz (SSH-Tunnel) oder bewusst hinter Reverse-Proxy + Auth.
- [ ] `.env` gitignored; Secret-Scan aktiv (Hook + CI).
- [ ] `main` branch-protected, Approval + CI erzwungen.
