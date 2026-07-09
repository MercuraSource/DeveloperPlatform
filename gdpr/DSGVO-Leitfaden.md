# DSGVO-Leitfaden — Compliance-Leitplanken

Die Compliance-Achse der Umgebung. Ziel: DSGVO-Konformitaet **by design**. Zwei Teile —
was jetzt (Entwickler-Umgebung) gilt, und was spaeter (Laufzeit) dazukommt.

> **Kein Rechtsrat.** Technisch-organisatorische Arbeitshilfe. Fuer verbindliche
> Beurteilung (Rechtsgrundlagen, Datenschutzerklaerung, ggf. DSFA) eine:n
> Datenschutzbeauftragte:n / Jurist:in einbeziehen.

## Teil A — gilt jetzt (Entwickler-Umgebung)

Auch ohne Laufzeit verarbeitet die Umgebung Daten (Code, Prompts, CI). Leitplanken:

1. **Cloud-LLM = Auftragsverarbeiter.** Prompt + Code verlassen die Maschine Richtung
   Anthropic/OpenAI. Noetig: **DPA/AVV** mit dem Anbieter + „no training on your data"
   (auf Business-/API-Ebene verfuegbar).
2. **Keine echten personenbezogenen Daten in Prompts/Tests/CI.** Nur synthetische Daten.
   Der Agent (und damit der Anbieter) bekommt nie echte PII zu sehen. (Auch technisch:
   `.claude` deny + Hooks blocken Secret-Zugriff.)
3. **Secrets nie ins Repo.** `.env` gitignored; pre-commit + gitleaks im CI (siehe
   `docs/enforcement.md`).
4. **Quellcode-Host.** GitHub (US) haelt Quellcode + CI-Logs — keine Live-Personendaten.
   Fuer volle EU-Residenz des Repos: Umzug auf Gitea/EU-VPS (`docs/migration-to-gitea.md`).
5. **TLS/Transport.** Zugriff auf Git-Host + spaetere Server nur verschluesselt (HTTPS/SSH).

## Teil B — kommt mit der Laufzeit (spaeter, pro App)

Sobald eine App echte personenbezogene Daten verarbeitet, gelten zusaetzlich die
klassischen Pflichten. Diese Artefakte werden dann angelegt (noch nicht Teil dieses Repos,
weil die Laufzeit offen ist):

1. **Datenresidenz + AVV/DPA** — Server bei EU-Provider (Hetzner, Netcup, IONOS, Scaleway);
   AVV mit Hosting + jedem weiteren Auftragsverarbeiter (E-Mail, Backup, Monitoring), moeglichst EU.
2. **ROPA** (Art. 30) — Verzeichnis von Verarbeitungstaetigkeiten, pro App.
3. **Rechtsgrundlage + Datenminimierung** (Art. 5, 6) — je Datenklasse eine Rechtsgrundlage;
   nur erheben, was gebraucht wird.
4. **Betroffenenrechte** (Art. 15-22) — Export + Loeschung einer Person technisch machbar;
   Nutzer-ID als Anker frueh mitdenken.
5. **Retention + Loeschkonzept** — Aufbewahrungsfrist je Datenklasse; Backups mit begrenzter
   Rotation (z. B. 30 Tage) dokumentieren.
6. **Consent + Cookies** (DE: TDDDG/TTDSG) — nur notwendige Cookies ohne Einwilligung;
   bevorzugt keine Tracker -> kein Banner. Datenschutzerklaerung + Impressum.
7. **TOMs** (Art. 32) — TLS ueberall, verschluesselte Backups + getesteter Restore,
   Zugriffskontrolle/least privilege, Updates, datensparsames Logging (IPs kuerzen).

## Haeufige Fallstricke

| Fallstrick | Abhilfe |
|---|---|
| Echte PII in Prompts/Fixtures/CI | strikt synthetische Testdaten |
| Third-Party-CDN / Google Fonts (Drittland, IP-Transfer) | Fonts/Assets selbst hosten |
| E-Mail-Versand ueber US-Anbieter | EU-SMTP/Transaktionsmail + AVV |
| Telemetrie / „phone home" einer Laufzeit-Komponente | pro Komponente abschalten |
| Verbose Logs mit PII/IPs | Log-Level runter, IPs kuerzen, kurze Retention |
| Loeschung vergisst Storage/Backups | alle Speicherorte durchgehen, nicht nur die Haupt-Tabelle |

## Kurz-Checkliste (siehe auch WORKFLOW §DSGVO-Kurzcheck)

Jetzt:
- [ ] DPA mit LLM-Anbieter + „no training"
- [ ] Keine echten personenbezogenen Daten in Prompts/Tests/CI
- [ ] Secrets nur außerhalb des Repos (Hook + gitleaks aktiv)

Mit Laufzeit:
- [ ] EU-Server + AVV; ROPA; Rechtsgrundlage je Datenklasse
- [ ] Export + Loeschung eines Nutzers getestet; Retention definiert
- [ ] Nur notwendige Cookies; Datenschutzerklaerung + Impressum; TOMs
