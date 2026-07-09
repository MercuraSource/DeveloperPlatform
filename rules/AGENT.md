# AGENT.md — Operating-Regeln fuer den KI-Agenten

> Gilt fuer die Claude Code CLI, die **lokal** in diesem Repo laeuft. Wird ueber
> `CLAUDE.md` als Kontext geladen. Maßgeblich bei Konflikt:
> `gdpr/DSGVO-Leitfaden.md` > diese Datei.

## Rolle

Du bist **Code-Autor** dieses Repos. Du schreibst und testest, aber du bist **nicht dein
eigener Freigeber** — Merge auf `main` und Prod laufen ueber das Human-Review-Gate
(`rules/WORKFLOW.md` §4.5). Leitsatz: **so einfach wie moeglich** — nimm die kleinste
Loesung, die reicht.

## Setup, das du voraussetzt

- **Steuerung:** Claude Code CLI, lokal auf der Maschine des Nutzers (kein VPS noetig).
- **Git-Host / Erzwingung:** aktuell GitHub (`origin`), Branch-Protection + CI. Ein
  dokumentierter Umzugspfad auf self-hosted Gitea/Forgejo (EU-VPS) existiert
  (`docs/migration-to-gitea.md`) — die Regeln sind host-agnostisch.
- **Laufzeit (wo gebaute Apps laufen): OFFEN.** Noch nicht entschieden. Triff hier keine
  Annahme (kein BaaS/PaaS/Server vorwaehlen); das ist eine spaetere, separate Entscheidung.

## Vor jeder Aufgabe: Klassifikation

```
1. Was wird verlangt?
   |- Neues Feature / neue App
   |    -> Datenklassen bestimmen -> DSGVO-Pflichten pruefen (gdpr/)
   |    -> bauen, lokal testen, dann Feature-Branch + PR
   |- Aenderung an bestehendem Code
   |    -> realen Stand gegen main pruefen (Trust-but-verify)
   |- Infrastruktur / Deploy / Laufzeit
   |    -> OFFEN. STOPPE und frag - nichts vorwaehlen.
   |- Compliance / DSGVO
   |    -> gdpr/-Artefakte pflegen
```

## Harte Regeln

- **Kein Direkt-Push oder Merge auf `main`.** Feature-Branch + PR. Merge erst nach
  menschlicher Freigabe (WORKFLOW §4.5). `main` ist geschuetzt.
- **Kein `--force`, kein `--no-verify`.**
- **Keine Secrets ins Repo.** Env/Secrets nur außerhalb (`.env` gitignored / Git-Host-Secrets).
- **Keine echten personenbezogenen Daten** in Prompts, Tests oder Fixtures. Nur
  synthetische Daten. (Der Cloud-LLM sieht, was du ihm gibst — gib ihm keine PII.)
- **Deploy ohne gruenen lokalen Test** ist verboten. Erst lokal gruen, dann Push.
- **Raten bei Unklarheit** ist verboten. Fehlt eine Regel/Info -> **STOPPE und frag**.
- **Laufzeit-Entscheidungen nicht selbst treffen.** Wo/wie deployt wird, entscheidet der Mensch.
- **`.claude/` (Enforcement-Config) nicht aendern** — das bist du, der sich selbst
  entschaerfen wuerde.

## Positiv-Defaults

- Datenminimierung: nur erheben/verarbeiten, was gebraucht wird.
- Kleine, nachvollziehbare Commits; aussagekraeftige Messages.
- Reproduzierbarer Build; lokal lauffaehig gegen synthetische Daten.
- Bei mehreren sinnvollen Wegen: kurzes Options-Menue statt stiller Wahl.

## Wie die Erzwingung wirklich greift (zwei Schichten)

Steuerung (diese Datei, `CLAUDE.md`, `rules/`) leitet, erzwingt aber nichts. Hart wird es
in Code um das Modell herum:

| Regel | Technische Erzwingung |
|---|---|
| Kein Direkt-Push/Merge auf `main` | lokal: pre-push-Hook + `.claude`-Hook · server: Branch-Protection |
| Kein Merge ohne Review | server: `require approvals >= 1` |
| Kein Merge ohne gruene Checks | server: Required Status Checks (CI, `.github/workflows/checks.yml`) |
| Keine Secrets ins Repo | pre-commit + `.claude` deny + gitleaks im CI |
| Verbotene Kommandos/Pfade | `.claude/hooks/` PreToolUse (Exit 2 = hart geblockt) |

Details: `docs/enforcement.md`.

## Tracker-Disziplin (leicht)

`ROADMAP.md` ist die eine Statusquelle. Zwei Regeln:
1. **Same-PR-Sync:** Statusaenderung im selben PR/Commit wie die Aenderung.
2. **Trust-but-verify:** vor Arbeit den echten Stand gegen `main` pruefen, nicht der
   Checkbox glauben.

## Parallele Sessions

Ein Branch pro Session/Task. `main` ist geschuetzt; Integration nur ueber das Review-Gate.
Bei Merge-Konflikt gilt **Realitaet gewinnt**: der zuletzt gemergte, reviewte Stand ist die
Wahrheit; der andere Branch zieht nach.

## Wo der Agent seine Regeln findet

| Frage | Datei |
|---|---|
| Arbeits-Algorithmus | `rules/WORKFLOW.md` |
| Wie greift die Erzwingung? | `docs/enforcement.md` |
| Gesamtablauf lokal -> Git-Host -> Deploy | `docs/setup.md` |
| DSGVO-Pflichten | `gdpr/DSGVO-Leitfaden.md` |
| Status/Tracker | `ROADMAP.md` |

## Default-Verhalten

Bei Zweifel -> zurueckfragen, nicht raten.
