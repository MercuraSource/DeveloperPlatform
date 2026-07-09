# DeveloperPlatform — Betriebsregeln für Claude Code

Du arbeitest **lokal** in diesem Repo über die Claude Code CLI. Diese Datei wird
automatisch geladen und **steuert** dich. Die **Erzwingung** liegt zusätzlich in Code
(siehe unten) — du kannst die Regeln nicht wegreden.

Verbindliche Quellen, in dieser Reihenfolge:

1. `rules/AGENT.md` — Rolle, harte Regeln, Klassifikation vor jeder Aufgabe.
2. `rules/WORKFLOW.md` — der 6-Phasen-Arbeitsalgorithmus inkl. Human-Review-Gate.
3. `gdpr/DSGVO-Leitfaden.md` — Compliance-Leitplanken (EU-Residenz, DPA, keine echten
   personenbezogenen Daten in Prompts/Fixtures).

## Nicht verhandelbar

- **Kein Direkt-Push oder Merge auf `main`.** Arbeite auf einem Feature-Branch und öffne
  einen PR. Merge/Prod erst nach menschlicher Freigabe (`rules/WORKFLOW.md` §4.5).
- **Keine Secrets ins Repo.** `.env` ist gitignored; nie lesen, nie committen.
- **Keine echten personenbezogenen Daten** in Prompts, Tests oder Fixtures — nur
  synthetische Daten.
- **Bei Unklarheit oder fehlender Regel: STOPPEN und fragen** — nicht raten.
- **`.claude/` ändert nur ein Mensch**, nie der Agent (das ist deine eigene Enforcement-Config).
- **Erst lokal grün, dann Push.** Kein `--no-verify`, kein `--force`.

## Wie die Erzwingung wirklich greift (zwei Schichten)

- **Steuerung (weich):** diese Datei + `rules/`. Leitet dich, ist aber nicht bindend.
- **Erzwingung (hart):** liegt in Code um dich herum und ist unabhängig vom Modell:
  1. Lokal: `.claude/settings.json` (`deny`/`ask`) + PreToolUse-Hooks in `.claude/hooks/`
     blocken verbotene Aktionen *vor* der Ausführung.
  2. Server: Branch-Protection auf `main` + Required Status Checks (CI) auf der
     **self-hosted Gitea (EU-VPS)** — kein Merge ohne grüne Checks und Freigabe.

Details: `docs/enforcement.md`. VPS/Gitea aufsetzen: `docs/vps-setup.md`.
Gesamtablauf lokal ↔ Gitea ↔ Deploy: `docs/setup.md`.

## Laufzeit ist offen

Wo eine gebaute App später läuft (Nextcloud, BaaS, PaaS o. a.) ist **bewusst noch nicht
entschieden**. Triff hier keine Annahme; das ist eine spätere, separate Entscheidung.
