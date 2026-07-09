# Setup — lokal steuern, server-seitig erzwingen

Der komplette Ablauf: du faehrst Claude Code **lokal**, die harten Regeln liegen beim
**Git-Host** (GitHub jetzt, Gitea spaeter). Die **Laufzeit** (wo Apps laufen) ist offen.

## Topologie

```
  Dein Rechner (lokal)                         Git-Host (GitHub / spaeter Gitea)
  +-----------------------------+   git push   +-------------------------------+
  | VS Code + Claude Code CLI   |  (per SSH)   | Repo + Branch-Protection      |
  |  - anweisen / lesen         | -----------> |  - PR-Pflicht, Approvals >= 1 |
  |  - reviewen / freigeben     |              |  - Required Checks (CI)       |
  |  - .claude deny + Hooks      | <----------- |  - CI: gitleaks + lint/test   |
  +-----------------------------+   PR/Diff    +-------------------------------+
                                                          |
                                                   (nach Merge auf main)
                                                          v
                                            Laufzeit / Deploy  ==  OFFEN
                                            (Nextcloud / BaaS / PaaS - spaeter)
```

Du greifst nie von Hand auf einen laufenden Server zu. Der Weg von lokal zur echten App
laeuft immer ueber Git: **(1)** lokal -> Git-Host per `git push`, **(2)** nach Merge auf
`main` traegt ein Deploy-Schritt den Stand zur Laufzeit. Sprung 2 ist die offene Ebene.

## Voraussetzungen (lokal)

- Claude Code CLI installiert.
- `python3` (fuer die `.claude`-Hooks), `git`, optional `gitleaks` (lokaler Secret-Scan).
- Zugang zum Git-Host (GitHub-Login bzw. spaeter SSH-Key fuer Gitea).

## Einmalige Einrichtung

1. Repo lokal klonen.
2. Lokale git-hooks aktivieren: `bash git-hooks/install.sh`.
3. `.claude`-Hooks ausfuehrbar machen: `chmod +x .claude/hooks/*.sh`.
4. Branch-Protection am Git-Host setzen (siehe `docs/enforcement.md`).
   - GitHub: privates Repo braucht **GitHub Pro**, sonst wird nicht erzwungen.
5. CI aktivieren: `.github/workflows/checks.yml` liegt bereit; `lint-test` mit echten
   Befehlen fuellen; als Required Check eintragen.

## Der Arbeitsloop (jede Aufgabe)

1. `git switch -c feature/<name>` — nie auf `main` arbeiten.
2. Claude Code die Aufgabe geben. Es baut, du liest den Diff, gibst Aktionen frei
   (`.claude` deny/Hooks blocken Verbotenes).
3. Lokal gruen testen (gegen synthetische Daten).
4. `git push` des Feature-Branch -> PR am Git-Host.
5. CI laeuft; du reviewst; **Approve**; **Merge auf `main`**.
6. Deploy zur Laufzeit (offen — siehe unten).

Details des Algorithmus: `rules/WORKFLOW.md`.

## Beispiel Nextcloud (erste konkrete Laufzeit)

Du willst z. B. eine Custom-App, ein Theme oder Config aendern:

1. Das Element liegt als eigenes Repo (Nextcloud-Kern wird nicht editiert - nur
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
- **Staging** (Prod-Spiegel, KEINE echten Daten): Zusammenspiel, Migrationen.
- **Production**: nur Deploy + nicht-destruktiver Smoke-Test + Backup/Rollback. Nie
  Testsuite gegen echte Personendaten.

## Laufzeit ist offen

Ob Nextcloud-Deploy per CI/SSH, ein BaaS, eine PaaS oder etwas anderes — das entscheidest du,
wenn die Umgebung steht. Nichts an der Entwickler-Umgebung haengt an dieser Wahl.
