# DeveloperPlatform

Eine disziplinierte **Entwickler-Umgebung** fuer die Claude Code CLI: du steuerst **lokal**,
die Regeln werden **hart erzwungen** — in Code um das Modell herum, nicht als Prompt-Prosa.
Die **Laufzeit** (wo gebaute Apps laufen) ist bewusst **offen** und wird erst spaeter entschieden.

## Prinzip: Steuerung vs. Erzwingung

- **Steuerung (weich):** `CLAUDE.md` + `rules/` leiten den Agenten.
- **Erzwingung (hart, agenten-unabhaengig):** liegt in Code und ist nicht wegzureden:
  1. **Lokal:** `.claude/settings.json` (`deny`) + PreToolUse-Hooks in `.claude/hooks/`
     blocken verbotene Aktionen vor der Ausfuehrung (Exit 2).
  2. **Server:** Branch-Protection auf `main` + Required Status Checks (CI) beim Git-Host —
     kein Merge ohne gruene Checks und menschliche Freigabe.

Details: `docs/enforcement.md`.

## Topologie

```
  Lokal (dein Rechner)                    Git-Host (GitHub jetzt / Gitea spaeter)
  VS Code + Claude Code CLI   --push-->   Repo + Branch-Protection + CI
  .claude deny + Hooks        <--PR/Diff  Approvals >= 1, Required Checks
                                                   |
                                            (nach Merge auf main)
                                                   v
                                          Laufzeit / Deploy  ==  OFFEN
```

Du editierst nie von Hand auf einem Server. Der Weg zur echten App laeuft immer ueber Git:
lokal -> Git-Host (`git push`) -> nach Merge traegt ein Deploy-Schritt den Stand zur
Laufzeit. Der Deploy-Schritt ist die offene Ebene.

## Entscheidungen (Stand)

- **Agent:** Claude Code CLI, lokal (kein VPS noetig). LLM = Cloud (Claude/Codex).
- **Git-Host:** Start auf **GitHub Pro** (privates Repo -> Branch-Protection wird erst ab
  Pro erzwungen). Umzug auf self-hosted **Gitea/Forgejo** (EU-VPS) ist dokumentiert:
  `docs/migration-to-gitea.md`.
- **Laufzeit:** OFFEN. Erster konkreter Fall: Nextcloud. Deploy-Muster spaeter.

## Verzeichnis

```
DeveloperPlatform/
├─ README.md                 ← diese Datei
├─ CLAUDE.md                 ← Steuerungs-Entry (Claude Code laedt das automatisch)
├─ ROADMAP.md                ← Statusquelle / Tracker
├─ .claude/
│  ├─ settings.json          ← Enforcement Schicht 1: permissions deny/ask/allow + Hooks
│  └─ hooks/                 ← guard-bash.sh, guard-edit.sh (PreToolUse, Exit 2 = hart)
├─ .github/workflows/
│  └─ checks.yml             ← Enforcement Schicht 3: CI (gitleaks + lint/test)
├─ git-hooks/                ← Schicht 0: pre-commit, pre-push, install.sh (Komfort)
├─ rules/
│  ├─ AGENT.md               ← Operating-Regeln des Agenten
│  └─ WORKFLOW.md            ← 6-Phasen-Arbeitsalgorithmus + Review-Gate
├─ docs/
│  ├─ setup.md               ← End-to-End: lokal ↔ Git-Host ↔ Deploy + Test-Ebenen
│  ├─ enforcement.md         ← die Schichten im Detail + Branch-Protection
│  └─ migration-to-gitea.md  ← Umzugspfad GitHub -> Gitea/EU-VPS
├─ infra/gitea/              ← Migrationsziel (Gitea + CI-Runner), erst beim Umzug noetig
└─ gdpr/
   └─ DSGVO-Leitfaden.md     ← Compliance-Leitplanken (EU, DPA, keine PII in Prompts)
```

## Schnellstart

1. Repo lokal klonen.
2. `bash git-hooks/install.sh` und `chmod +x .claude/hooks/*.sh`.
3. Branch-Protection am Git-Host setzen (`docs/enforcement.md`); GitHub: privates Repo
   braucht GitHub Pro.
4. `lint-test` in `.github/workflows/checks.yml` mit echten Befehlen fuellen.
5. Claude Code im Repo starten — es liest `CLAUDE.md` + `rules/` automatisch.

Arbeitsloop und Nextcloud-Beispiel: `docs/setup.md`.
