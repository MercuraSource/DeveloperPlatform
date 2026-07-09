# Umzugspfad — GitHub -> self-hosted Gitea/Forgejo (EU-VPS)

Start ist GitHub (Pro, privates Repo). Sobald ein EU-VPS ohnehin laeuft (fuer Nextcloud &
Co.), lohnt der Umzug auf self-hosted Gitea/Forgejo: volle EU-Residenz des Repos, keine
Tier-Grenzen, kein CI-Minutenlimit, kostenlos oben drauf. Der Umzug ist kein Neubau —
Git ist verteilt, das ist kein Lock-in.

## Warum wechseln (und wann)

- **Nur dieses Repo, kein Server noetig:** GitHub Pro (~4 $/Monat) ist billiger + null Ops.
- **VPS laeuft sowieso (Apps/Nextcloud):** Gitea + CI-Runner kosten dort ~nichts extra,
  und GitHub Free erzwingt Branch-Protection auf privaten Repos gar nicht. Dann gewinnt
  self-hosted bei Kosten UND DSGVO.

## Bereitstellen (auf dem EU-VPS)

Vorlagen liegen unter `infra/gitea/`:
- `bootstrap.sh` — VPS-Haertung (Firewall, SSH-Key-only, Auto-Updates, Docker).
- `docker-compose.yml` — Gitea + act_runner (CI). Kein Caddy noetig; Gitea-Web nur ueber
  SSH-Tunnel auf `localhost` erreichbar (oder bewusst per Reverse-Proxy oeffentlich).
- `.env.example` — nach `.env` kopieren, Werte fuellen (NIE committen).
- `gitea-checks.yaml` — Gitea-Actions-Aequivalent von `.github/workflows/checks.yml`,
  ablegen als `.gitea/workflows/checks.yaml` im Repo.

Schritte: `bootstrap.sh` als root -> `infra/gitea/` auf den Server -> `.env` fuellen ->
`docker compose up -d` -> Gitea einrichten -> act_runner registrieren.

## Repo umziehen

Variante A (Gitea-Import, am einfachsten): in Gitea "Neue Migration" -> GitHub-URL + Token
-> importiert Code, History, Issues, PRs.

Variante B (manuell): 
```
git remote set-url origin ssh://git@<vps>:2222/<user>/<repo>.git
git push --mirror
```

## Was neu einzurichten ist (nicht automatisch)

- **Branch-Protection** in Gitea neu setzen (gleiche Regeln wie GitHub: PR-Pflicht,
  Approvals >= 1, Required Check `checks`, Force-Push aus).
- **CI-Workflow**: `.github/workflows/checks.yml` -> `.gitea/workflows/checks.yaml`
  (Syntax an GitHub Actions angelehnt; meist kleine Anpassungen). Vorlage:
  `infra/gitea/gitea-checks.yaml`.
- **Secrets** neu eintragen (Gitea Repo/Org Secrets).
- Lokal: `git remote` zeigt jetzt auf Gitea; SSH-Key hinterlegen.

## Aufwand

Ein bis zwei Stunden, kein Neubau. Code + History wandern verlustfrei; die Arbeit ist
Branch-Protection + CI + Secrets neu verdrahten.

## Was NICHT umziehen muss

`.claude/` (Enforcement + Hooks), `rules/`, `git-hooks/`, `gdpr/`, Doku — alles
host-agnostisch. Nur die Server-Enforcement-Config (Branch-Protection, CI-Ort, Secrets)
ist host-spezifisch.
