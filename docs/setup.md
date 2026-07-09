# Setup — lokal steuern, server-seitig erzwingen

Der komplette Ablauf: du faehrst Claude Code **lokal**, die harten Regeln liegen auf der
self-hosted **Gitea (EU-VPS)**. Die **Laufzeit** (wo Apps laufen) ist offen.

VPS + Gitea aufsetzen und Repo umziehen: `docs/vps-setup.md`.

## Topologie

```
  Lokal (dein Rechner)                    EU-VPS
  VS Code + Claude Code CLI   --push-->   Gitea + Branch-Protection + CI (act_runner)
   - anweisen / lesen         (per SSH)    - PR-Pflicht, Approvals >= 1
   - reviewen / freigeben     <--PR/Diff   - Required Checks (CI)
   - .claude deny + Hooks                  - gitleaks + lint/test
                                                   |
                                            (nach Merge auf main)
                                                   v
                                          Laufzeit / Deploy  ==  OFFEN
```

Du greifst nie von Hand auf einen laufenden Server zu. Der Weg von lokal zur echten App
laeuft immer ueber Git: **(1)** lokal -> Gitea per `git push` (SSH), **(2)** nach Merge auf
`main` traegt ein Deploy-Schritt den Stand zur Laufzeit. Sprung 2 ist die offene Ebene.

## Voraussetzungen (lokal)

- Claude Code CLI installiert.
- `python3` (fuer die `.claude`-Hooks), `git`, optional `gitleaks` (lokaler Secret-Scan).
- SSH-Key beim Gitea-Nutzer hinterlegt; `origin` zeigt auf die Gitea (Port 2222).

## Einmalige Einrichtung

1. VPS + Gitea aufsetzen, Repo umziehen -> `docs/vps-setup.md`.
2. Repo lokal klonen (von Gitea).
3. Lokale git-hooks aktivieren: `bash git-hooks/install.sh`.
4. `.claude`-Hooks ausfuehrbar machen: `chmod +x .claude/hooks/*.sh`.
5. Branch-Protection in Gitea setzen (`docs/enforcement.md`).
6. CI: `.gitea/workflows/checks.yaml` liegt bereit; `lint-test` mit echten Befehlen
   fuellen; als Required Check eintragen.

## Der Arbeitsloop (jede Aufgabe)

1. `git switch -c feature/<name>` — nie auf `main` arbeiten.
2. Claude Code die Aufgabe geben. Es baut, du liest den Diff, gibst Aktionen frei
   (`.claude` deny/Hooks blocken Verbotenes).
3. Lokal gruen testen (gegen synthetische Daten).
4. `git push` des Feature-Branch -> PR in Gitea.
5. CI laeuft; du reviewst; **Approve**; **Merge auf `main`**.
6. Deploy zur Laufzeit (offen — siehe unten).

Details des Algorithmus: `rules/WORKFLOW.md`.

## Beispiel Nextcloud (erste konkrete Laufzeit)

Du willst z. B. eine Custom-App, ein Theme oder Config aendern:

1. Das Element liegt als eigenes Repo in Gitea (Nextcloud-Kern wird nicht editiert - nur
   `custom_apps/`, Themes, Config).
2. Lokal ein Nextcloud im Docker mit der App gemountet -> Claude Code editiert, du testest
   im Browser auf `localhost`. Nicht gegen Produktion.
3. Feature-Branch -> PR -> CI/Review/Merge (Loop oben).
4. Deploy-Schritt bringt `main` auf die echte Nextcloud (Muster: CI-Job per SSH/rsync +
   `occ upgrade`/Neustart, oder Webhook-Pull, oder Container-Redeploy). **Diese Wahl ist
   noch offen.**

Sonderfall: existieren Anpassungen nur auf dem Server (von Hand), zuerst in Git holen
(Schritt 0). Ab dann Server-Stand = Git-Stand; Hand-Edits am Server sind tabu.

## Testen (welche Ebene beweist was)

- **Lokal** (synthetisch): "funktioniert es ueberhaupt".
- **CI** (ephemer, Fake-Daten): Korrektheit / keine Regression -> Merge-Gate.
- **Staging** (Prod-Spiegel, KEINE echten Daten, bevorzugt per Subdomain): Zusammenspiel,
  Migrationen.
- **Production**: nur Deploy + nicht-destruktiver Smoke-Test + Backup/Rollback. Nie
  Testsuite gegen echte Personendaten.

## Laufzeit ist offen

Ob Nextcloud-Deploy per CI/SSH, ein BaaS, eine PaaS oder etwas anderes — das entscheidest du,
wenn die Umgebung steht. Nichts an der Entwickler-Umgebung haengt an dieser Wahl.
