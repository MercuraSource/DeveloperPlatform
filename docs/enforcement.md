# Enforcement — wie die Regeln HART werden

Steuerung (Prompt) leitet den Agenten, erzwingt aber nichts. Die Haerte liegt in Code
**um** das Modell herum und ist **unabhaengig vom Agenten/LLM**. Drei Schichten.

## Schicht 1 — Agenten-Ebene (lokal): Claude Code deny + Hooks

Datei `.claude/settings.json` + `.claude/hooks/`.

- **`permissions.deny`** — nicht ueberschreibbar. Blockt z. B. das Lesen/Schreiben von
  `.env`/Secrets und Aenderungen an `.claude/` selbst. `deny` schlaegt immer `ask`/`allow`.
- **`permissions.ask`** — fragt vor heiklen Aktionen nach (Push, `gh`, `curl`, `wget`, `WebFetch`).
- **PreToolUse-Hooks** — laufen *vor* der Ausfuehrung und stoppen mit **Exit-Code 2** hart:
  - `guard-bash.sh`: kein Push auf `main`/`master`, kein `--force`, kein `--no-verify`,
    kein Secret-Lesen ueber die Shell, kein gefaehrliches `rm -rf`.
  - `guard-edit.sh`: keine Aenderung an `.env`, `.git/`, `.claude/`.

> Wichtig: `deny`-Regeln und Exit-2-Hooks werden vom **Harness** durchgesetzt, nicht vom
> Modell — der Agent kann sie nicht wegreden. Voraussetzung fuer die Hooks: `python3` auf
> der Maschine (uebliche Dev-Voraussetzung). Fehlt es, fallen die Hooks offen aus; dann
> traegt Schicht 2+3 allein.

Aktivieren: Claude Code laedt `.claude/` automatisch aus dem Projekt-Root. Hooks ausfuehrbar
machen: `chmod +x .claude/hooks/*.sh`.

## Schicht 2 — Server-Ebene: Branch-Protection (die haerteste)

Das ist die **nicht umgehbare** Schicht — sie sitzt beim Git-Host, nicht auf deiner Maschine.

Auf GitHub (Repo -> Settings -> Branches -> Add rule fuer `main`):
- **Require a pull request before merging** (kein Direkt-Push).
- **Require approvals: >= 1** (das ist das Human-Review-Gate, WORKFLOW §4.5).
- **Require status checks to pass** -> `checks` (aus `.github/workflows/checks.yml`).
- **Do not allow bypassing** / **Include administrators** (auch du gehst durch das Gate).
- Force-Push + Loeschen von `main` verbieten.

> GitHub Free erzwingt Branch-Protection auf **privaten** Repos NICHT. Fuer ein privates
> Repo brauchst du **GitHub Pro** (~4 $/Monat), sonst ist diese Schicht wirkungslos.
> Self-hosted Gitea/Forgejo hat diese Einschraenkung nicht (`docs/migration-to-gitea.md`).

## Schicht 3 — CI-Gate: Required Status Checks

`.github/workflows/checks.yml` laeuft bei jedem PR auf `main`:
- **gitleaks** — blockt Secrets im Diff.
- **lint-test** — pro App mit echten Befehlen fuellen (Tests gegen ephemere Instanz +
  synthetische Fixtures).

Als **Required Status Check** in der Branch-Protection eintragen -> kein Merge ohne gruen.

## Schicht 0 — lokale git-hooks (Komfort, nicht Schutz)

`git-hooks/` (via `bash git-hooks/install.sh`): pre-commit (Secret-Scan) + pre-push
(main-Block). Fruehwarnung, aber mit `--no-verify` umgehbar -> **kein** echter Schutz.
Zaehlt nur zusammen mit Schicht 1-3.

## Merksatz

Schicht 2 (server-seitige Branch-Protection) ist die einzige *nicht umgehbare* Erzwingung.
Schicht 1 (Claude-Code deny/Hooks) faengt Fehler frueh und lokal ab. Schicht 3 (CI) macht
Qualitaet/Secrets zur Merge-Bedingung. Schicht 0 (git-hooks) ist Komfort. Alle zusammen
ergeben harte, agenten-unabhaengige Regeln.
