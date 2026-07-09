# ROADMAP / Tracker

Die eine Statusquelle (siehe `rules/AGENT.md` -> Tracker-Disziplin). Same-PR-Sync:
Status im selben PR wie die Aenderung nachziehen. Trust-but-verify: echten Stand gegen
`main` pruefen, nicht der Checkbox glauben.

## Entwickler-Umgebung

- [x] Steuerung: Claude Code CLI, lokal.
- [x] Enforcement Schicht 1: `.claude/settings.json` + Hooks.
- [x] Enforcement Schicht 0: lokale git-hooks.
- [x] Enforcement Schicht 3: CI (`.gitea/workflows/checks.yaml`).
- [ ] EU-VPS provisioniert + gehaertet (`infra/gitea/bootstrap.sh`).
- [ ] Gitea + act_runner laufen; dieses Repo auf Gitea umgezogen (`docs/vps-setup.md`).
- [ ] Enforcement Schicht 2: Branch-Protection auf `main` in Gitea gesetzt.
- [ ] `lint-test` im CI mit echten Befehlen gefuellt.

## Entscheidungen (Stand)

- [x] **Agent:** Claude Code CLI, lokal. LLM = Cloud (Claude/Codex).
- [x] **Git-Host / Enforcement:** self-hosted Gitea/Forgejo auf **EU-VPS**.
      Dieses Repo zieht von GitHub auf Gitea um.
- [ ] **Laufzeit** (wo laufen gebaute Apps): OFFEN. Erster konkreter Fall: Nextcloud.
- [ ] **Deploy-Schritt** (main -> laufende App): OFFEN. Staging bevorzugt per Subdomain.

## Apps

_Noch keine. Jede App bekommt hier eine Zeile: Name · Status · Datenklassen · Laufzeit._
