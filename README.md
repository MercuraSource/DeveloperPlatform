# DeveloperPlatform

Eine disziplinierte **Entwickler-Umgebung** fuer die Claude Code CLI: du steuerst **lokal**,
die Regeln werden **hart erzwungen** — in Code um das Modell herum, nicht als Prompt-Prosa.
Die **Laufzeit** (wo gebaute Apps laufen) ist bewusst **offen** und wird erst spaeter entschieden.

## Prinzip: Steuerung vs. Erzwingung

- **Steuerung (weich):** `CLAUDE.md` + `rules/` leiten den Agenten.
- **Erzwingung (hart, agenten-unabhaengig):** liegt in Code und ist nicht wegzureden:
  1. **Lokal:** `.claude/settings.json` (`deny`) + PreToolUse-Hooks in `.claude/hooks/`
     blocken verbotene Aktionen vor der Ausfuehrung (Exit 2).
  2. **Server:** Branch-Protection auf `main` + Required Status Checks (CI) auf der
     self-hosted **Gitea (EU-VPS)** — kein Merge ohne gruene Checks und Freigabe.

Details: `docs/enforcement.md`.

## Topologie

```
  Lokal (dein Rechner)                    EU-VPS
  VS Code + Claude Code CLI   --push-->   Gitea + Branch-Protection + CI (act_runner)
  .claude deny + Hooks        <--PR/Diff  Approvals >= 1, Required Checks
                                                   |
                                            (nach Merge auf main)
                                                   v
                                          Laufzeit / Deploy  ==  OFFEN
```

Du editierst nie von Hand auf einem Server. Der Weg zur echten App laeuft immer ueber Git:
lokal -> Gitea (`git push` per SSH) -> nach Merge auf `main` traegt ein Deploy-Schritt den
Stand zur Laufzeit. Der Deploy-Schritt ist die offene Ebene.

## Entscheidungen (Stand)

- **Agent:** Claude Code CLI, lokal. LLM = Cloud (Claude/Codex) mit DPA + "no training".
- **Git-Host / Enforcement:** self-hosted **Gitea/Forgejo auf einem EU-VPS**, Branch-
  Protection + CI (act_runner). Dieses Repo zieht von GitHub auf Gitea um. Aufsetzen:
  `docs/vps-setup.md`.
- **Laufzeit:** OFFEN. Erster konkreter Fall: Nextcloud. Staging bevorzugt per Subdomain.

## Verzeichnis

```
DeveloperPlatform/
├─ README.md                 ← diese Datei
├─ CLAUDE.md                 ← Steuerungs-Entry (Claude Code laedt das automatisch)
├─ ROADMAP.md                ← Statusquelle / Tracker
├─ .claude/
│  ├─ settings.json          ← Enforcement Schicht 1: permissions deny/ask/allow + Hooks
│  └─ hooks/                 ← guard-bash.sh, guard-edit.sh (PreToolUse, Exit 2 = hart)
├─ .gitea/workflows/
│  └─ checks.yaml            ← Enforcement Schicht 3: CI (gitleaks + lint/test)
├─ git-hooks/                ← Schicht 0: pre-commit, pre-push, install.sh (Komfort)
├─ rules/
│  ├─ AGENT.md               ← Operating-Regeln des Agenten
│  └─ WORKFLOW.md            ← 6-Phasen-Arbeitsalgorithmus + Review-Gate
├─ docs/
│  ├─ vps-setup.md           ← EU-VPS + Gitea + Runner aufsetzen, Repo umziehen
│  ├─ setup.md               ← End-to-End: lokal ↔ Gitea ↔ Deploy + Test-Ebenen
│  ├─ enforcement.md         ← die Schichten im Detail + Branch-Protection
│  └─ hardening.md           ← Docker-Härtung (socket-proxy, daemon.json, ufw-docker)
├─ infra/gitea/              ← VPS-Stack: Gitea + act_runner + socket-proxy, daemon.json, bootstrap, .env
└─ gdpr/
   └─ DSGVO-Leitfaden.md     ← Compliance-Leitplanken (EU, DPA, keine PII in Prompts)
```

## Schnellstart

1. EU-VPS aufsetzen: Gitea + Runner, Repo umziehen -> `docs/vps-setup.md`.
2. Branch-Protection auf `main` in Gitea setzen -> `docs/enforcement.md`.
3. `lint-test` in `.gitea/workflows/checks.yaml` mit echten Befehlen fuellen.
4. Lokal: `bash git-hooks/install.sh` und `chmod +x .claude/hooks/*.sh`.
5. Claude Code im Repo starten — es liest `CLAUDE.md` + `rules/` automatisch.

Arbeitsloop und Nextcloud-Beispiel: `docs/setup.md`.
