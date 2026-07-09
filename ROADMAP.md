# ROADMAP / Tracker

Die eine Statusquelle (siehe `rules/AGENT.md` -> Tracker-Disziplin). Same-PR-Sync:
Status im selben PR wie die Aenderung nachziehen. Trust-but-verify: echten Stand gegen
`main` pruefen, nicht der Checkbox glauben.

## Entwickler-Umgebung

- [x] Steuerung: Claude Code CLI, lokal.
- [x] Enforcement Schicht 1: `.claude/settings.json` + Hooks.
- [x] Enforcement Schicht 0: lokale git-hooks.
- [x] Enforcement Schicht 3: CI (`.github/workflows/checks.yml`).
- [ ] Enforcement Schicht 2: Branch-Protection auf `main` am Git-Host gesetzt.
      (GitHub: privates Repo braucht GitHub Pro.)
- [ ] `lint-test` im CI mit echten Befehlen gefuellt.
- [ ] Git-Host-Secrets/Token eingerichtet.

## Offene Entscheidungen

- [ ] **Laufzeit** (wo laufen gebaute Apps): OFFEN. Erster konkreter Fall: Nextcloud.
- [ ] **Deploy-Schritt** (main -> laufende App): OFFEN.
- [ ] **Git-Host langfristig**: Start GitHub Pro; Umzug auf Gitea/EU-VPS dokumentiert
      (`docs/migration-to-gitea.md`), sobald ein VPS ohnehin laeuft.

## Apps

_Noch keine. Jede App bekommt hier eine Zeile: Name · Status · Datenklassen · Laufzeit._
