# DSGVO App Factory

Ein schlankes **Entwicklungs-Betriebssystem** für einfache, **DSGVO-konforme**
Apps auf **selbst-gehosteten Open-Source-BaaS** (Supabase · PocketBase · Appwrite —
je nach App die einfachste passende Lösung), ausgeliefert über **selbst-gehostete
PaaS** (Coolify oder Dokploy) per **Git-Push-Deploy**.

Das Erbe aus dem Vorgänger-Projekt („Mercura SaaS-Factory OS") sind **nur die
Entwicklungsregeln, die funktioniert haben** — die Methodik, wie ein KI-Agent
diszipliniert entwickelt. Die schwere Enterprise-Infrastruktur (eigene PKI,
hand-gebaute RLS, AWS-CDK, self-hosted CI-Runner) ist **bewusst ersetzt** durch
BaaS-Bordmittel + PaaS-native Deploys.

> **Leitprinzip:** *So einfach wie möglich.* Jede App nimmt die kleinste
> BaaS-Lösung, die reicht. Jede Regel, die keinen Wert stiftet, fällt weg.

---

## Wo anfangen

1. **[PLAN.md](PLAN.md)** — der Plan + das Mapping (was aus Mercura bleibt/ersetzt/neu),
   die Ziel-Architektur, die offenen Entscheidungen. **Zuerst lesen.**
2. **[rules/AGENT.md](rules/AGENT.md)** — Operating-Manual für den KI-Agenten
   (Pendant zu Mercuras `CLAUDE.md`, stack-neutral).
3. **[rules/WORKFLOW.md](rules/WORKFLOW.md)** — der bewährte Arbeits-Algorithmus
   (Discovery → Stop-&-Ask → Build → Gate), auf „einfach" eingedampft.
4. **[stack/baas-decision-guide.md](stack/baas-decision-guide.md)** — pro App die
   passende BaaS wählen.
5. **[stack/paas-deploy.md](stack/paas-deploy.md)** — Git-Push-Deploy mit Coolify/Dokploy.
6. **[gdpr/DSGVO-Leitfaden.md](gdpr/DSGVO-Leitfaden.md)** — die DSGVO-Achse
   (Residenz, AVV, ROPA, Betroffenenrechte, Retention, Consent, TOMs).

## Verzeichnis

```
dsgvo-app-factory/
├─ README.md                        ← diese Datei
├─ PLAN.md                          ← Plan + Mercura→Neu-Mapping + Architektur
├─ rules/
│  ├─ AGENT.md                      ← KI-Agent-Operating-Manual (stack-neutral)
│  └─ WORKFLOW.md                   ← Arbeits-Algorithmus (vereinfacht)
├─ stack/
│  ├─ baas-decision-guide.md        ← Supabase vs PocketBase vs Appwrite
│  ├─ paas-deploy.md                ← Coolify / Dokploy Git-Push-Deploy
│  └─ app-registry.example.yaml     ← leichte Registry (ersetzt architecture-manifest)
└─ gdpr/
   ├─ DSGVO-Leitfaden.md            ← die DSGVO-Achse
   ├─ ROPA-Vorlage.md               ← Verzeichnis von Verarbeitungstätigkeiten
   └─ betroffenenrechte-runbook.md  ← Auskunft/Export/Löschung je BaaS
```

## Der KI-Startknopf (Master-Prompt)

Als erste Nachricht in einer neuen Agenten-Session:

> **AKTIVIERE: DSGVO App Factory.**
> Du bist ein disziplinierter Full-Stack-Agent, gesteuert durch `rules/AGENT.md`
> und `rules/WORKFLOW.md`. Der Stack ist selbst-gehostet: BaaS (Supabase/PocketBase/
> Appwrite je App) + PaaS (Coolify/Dokploy, Git-Push-Deploy). DSGVO ist Pflicht,
> nicht Kür (`gdpr/DSGVO-Leitfaden.md`).
> **Vorgehen:** (1) Discovery/Triangulation gegen `stack/app-registry.example.yaml`.
> (2) Bei Unklarheit/fehlender Regel: **STOPPE und frag** — nicht raten.
> (3) Wähle die einfachste BaaS laut `stack/baas-decision-guide.md`.
> (4) Baue, teste lokal, dann Push auf einen **Feature-Branch** (Staging). **Prod nur nach
> menschlichem Review-Gate + Merge auf `main`** (`rules/WORKFLOW.md` §4.5). (5) DSGVO-Check vor „fertig".
> **STARTE:** Analysiere das Projekt und frag mich nach der ersten App / dem ersten Task.

> ⚠️ **Status:** Entwurf v0.1 (2026-07-03). Schnelllebige Tool-Details (Coolify/Dokploy
> Templates & Backup-Optionen) sind als „prüfen" markiert — vor produktivem Einsatz
> gegen die aktuellen offiziellen Docs verifizieren.
