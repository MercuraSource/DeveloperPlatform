# WORKFLOW.md — Der Arbeits-Algorithmus

Discovery -> Stop-&-Ask -> Build -> Gate, in **6 Phasen**. Host-agnostisch (GitHub jetzt,
Gitea spaeter). Laufzeit bleibt offen.

---

## Phase 0 — Discovery / Triangulation

Bevor etwas gebaut wird, drei Quellen abgleichen:
- **Soll** — Anforderung des Nutzers.
- **Ist** — was existiert schon im Repo / gegen `main`.
- **Status** — `ROADMAP.md`.

Bei Widerspruch zwischen Tracker und Realitaet -> **Realitaet gewinnt**, Tracker nachziehen.

## Phase 1 — Stop-&-Ask (das wichtigste Erbe)

Wenn eine **Regel fehlt/unklar** ist oder du auf eine **Weggabelung** stoesst: **STOPPE
SOFORT** und klaere mit dem Nutzer — iterativ, nicht ratend. Besonders hier:
- Wo soll das laufen? (Laufzeit ist OFFEN — nie selbst waehlen.)
- Werden personenbezogene Daten verarbeitet? Welche Klassen? -> DSGVO-Pflichten ziehen.
- Mehrere sinnvolle Wege -> kurzes Menue statt stiller Wahl.

## Phase 2 — Plan (klein halten)

Kurzer Plan: was gebaut wird, Datenklassen, DSGVO-relevante Punkte, Build-/Test-Rezept.
Ein Absatz reicht, solange die Weggabelungen geklaert sind.

## Phase 3 — Build

- Datenminimierung: nur anlegen, was gebraucht wird.
- Secrets in `.env` (gitignored) / Git-Host-Secrets, nie im Code.
- Nur synthetische Testdaten — keine echten personenbezogenen Daten.

## Phase 4 — Gate (lokal zuerst)

**Vor** jedem Push: lokal gruen.
- App startet lokal gegen eine lokale/ephemere Instanz mit synthetischen Daten.
- Ein negativer Zugriffstest (fremder Nutzer sieht fremde Daten NICHT).
- DSGVO-Kurzcheck (unten).

Erst wenn lokal gruen -> Push **auf einen Feature-Branch** (nie direkt `main`). Ein Push
loest hoechstens ein **Staging-Deploy** aus (Prod-nahe Config, KEINE echten personenbezogenen
Daten). **Prod-Deploy erfolgt nie durch Push**, sondern erst nach Phase 4.5.

### Test-Ebenen (Merksatz)

Lokal (synthetisch) -> CI (Korrektheit, ephemer) -> Staging (Prod-Spiegel, Fake-Daten) ->
Production (nur Deploy + nicht-destruktiver Smoke-Test + Backup/Rollback). Gegen echte
Produktionsdaten wird nie getestet. (Staging + Deploy = Teil der offenen Laufzeit-Ebene.)

## Phase 4.5 — Human Review Gate (Pflicht)

Der Agent baut auf einem Feature-Branch und oeffnet einen **PR** — er merged **nicht selbst**.
Freigabe erteilt ein Mensch (oder ein *separater* Review-Agent).

**Risk-based:**
- Auto-merge erlaubt (ohne Review): reine Doku/Kommentare/UI-Copy ohne Code-/Config-/
  Schema-Aenderung.
- Pflicht-Review: alles was Autorisierung, Datenklassen/Schema/Migrationen, Auth,
  Secrets/Env, Retention/Loeschung oder externe Datenfluesse beruehrt.
- **Default bei Unklarheit -> Review-Pflicht.**

**Review-Fokus:** Sieht ein fremder Nutzer fremde Daten? Verlassen personenbezogene Daten
die EU? Secrets im Diff? Stimmen Datenklassen mit dem Loeschkonzept?

Technisch erzwungen ueber Branch-Protection: kein Merge ohne Approval + gruene Checks
(`docs/enforcement.md`). Erst nach Freigabe: **Merge auf `main`**, dann Deploy.

## Phase 5 — Finalize

- `ROADMAP.md` aktualisieren (Status).
- DSGVO-Artefakte pflegen, falls beruehrt.
- Falls eine Laufzeit existiert: Backup + Restore einmal verifiziert.

---

## Autonomous Repair Loop (bei Fehlern)

Fehler lesen -> Ursache benennen -> gezielt fixen -> erneut testen. Nach 2-3 erfolglosen
Runden **STOPPEN und den Nutzer einbeziehen** — nicht endlos im Kreis.

---

## DSGVO-Kurzcheck (Phase 4, jede App)

- [ ] Personenbezogene Daten nur in der EU (Laufzeit), AVV vorhanden?
- [ ] Nur noetige Daten (Datenminimierung)?
- [ ] Betroffenenrechte technisch machbar (Export + Loeschung eines Nutzers)?
- [ ] Retention/Loeschfrist definiert?
- [ ] Keine echten personenbezogenen Daten in Prompts/Tests/CI?
- [ ] Keine Drittanbieter-Tracker/-Fonts/-CDN ohne Einwilligung?

Details: `gdpr/DSGVO-Leitfaden.md`.
