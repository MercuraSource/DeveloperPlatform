# Enforcement — wie die Regeln HART werden

Steuerung (Prompt) leitet den Agenten, erzwingt aber nichts. Die Haerte liegt in Code
**um** das Modell herum und ist **unabhaengig vom Agenten/LLM**. Drei Schichten (plus eine
Komfort-Schicht).

## Schicht 1 — Agenten-Ebene (lokal): Claude Code deny + Hooks

Datei `.claude/settings.json` + `.claude/hooks/`.

- **`permissions.deny`** — nicht ueberschreibbar. Blockt z. B. das Lesen/Schreiben von
  `.env`/Secrets und Aenderungen an `.claude/` selbst. `deny` schlaegt immer `ask`/`allow`.
- **`permissions.ask`** — fragt vor heiklen Aktionen nach (Push, `gh`, `curl`, `wget`, `WebFetch`).
- **PreToolUse-Hooks** — laufen *vor* der Ausfuehrung und stoppen mit **Exit-Code 2** hart:
  - `guard-bash.sh`: kein Push auf `main`/`master`, kein `--force`, kein `--no-verify`,
    kein Secret-Lesen ueber die Shell, kein gefaehrliches `rm -rf`.
  - `guard-edit.sh`: keine Aenderung an `.env`, `.git/`, `.claude/`.

> `deny`-Regeln und Exit-2-Hooks werden vom **Harness** durchgesetzt, nicht vom Modell —
> der Agent kann sie nicht wegreden. Voraussetzung fuer die Hooks: `python3` auf der Maschine.

Aktivieren: Claude Code laedt `.claude/` automatisch. Hooks ausfuehrbar machen:
`chmod +x .claude/hooks/*.sh`.

## Schicht 2 — Server-Ebene: Gitea-Branch-Protection (die haerteste)

Die **nicht umgehbare** Schicht — sie sitzt auf der self-hosted Gitea (EU-VPS), nicht
auf deiner Maschine.

In Gitea (Repo -> Settings -> Branches -> Branch-Protection fuer `main`):
- **Enable Branch Protection** + Push direkt blockieren (nur Merge ueber PR).
- **Require approvals: >= 1** (das ist das Human-Review-Gate, WORKFLOW §4.5).
- **Require status checks** -> `checks` (aus `.gitea/workflows/checks.yaml`).
- **Block force pushes** + Loeschen von `main` verbieten.
- Optional: signierte Commits verlangen.

> Anders als GitHub Free hat self-hosted Gitea hier **keine** Tier-Einschraenkung — die
> Branch-Protection ist auch fuer private Repos voll erzwungen.

## Schicht 3 — CI-Gate: Required Status Checks

`.gitea/workflows/checks.yaml` laeuft beim PR auf `main` (auf dem registrierten act_runner):
- **gitleaks** — blockt Secrets im Diff.
- **lint-test** — pro App mit echten Befehlen fuellen (Tests gegen ephemere Instanz +
  synthetische Fixtures).

Als **Required Status Check** in der Branch-Protection eintragen -> kein Merge ohne gruen.

## Schicht 0 — lokale git-hooks (Komfort, nicht Schutz)

`git-hooks/` (via `bash git-hooks/install.sh`): pre-commit (Secret-Scan) + pre-push
(main-Block). Fruehwarnung, aber mit `--no-verify` umgehbar -> **kein** echter Schutz.
Zaehlt nur zusammen mit Schicht 1-3.

## Merksatz

Schicht 2 (Gitea-Branch-Protection) ist die einzige *nicht umgehbare* Erzwingung.
Schicht 1 (Claude-Code deny/Hooks) faengt Fehler frueh und lokal ab. Schicht 3 (CI) macht
Qualitaet/Secrets zur Merge-Bedingung. Schicht 0 (git-hooks) ist Komfort. Alle zusammen
ergeben harte, agenten-unabhaengige Regeln.
