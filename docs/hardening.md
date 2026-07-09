# Docker-Haertung (VPS)

Was im Repo bereits umgesetzt ist, wie du es verifizierst, und die optionalen naechsten Stufen.

## Umgesetzt (out of the box)

### 1. Runner ohne Host-Socket (groesster Hebel)
CI-Jobs fuehren beliebigen Code aus. Der Host-Docker-Socket im Runner waere Host-Root.
Deshalb (`infra/gitea/docker-compose.yml`):
- Ein **socket-proxy** (read-only am echten Socket, `cap_drop: ALL`, `read_only`) ist das
  einzige, was `/var/run/docker.sock` beruehrt.
- Der Runner spricht ueber `DOCKER_HOST=tcp://socketproxy:2375` und bekommt nur die
  noetigen API-Bereiche (Container/Images/Networks/Volumes/Exec/Build). `SWARM`, `SECRETS`,
  `CONFIGS`, `PLUGINS`, `SYSTEM`, `AUTH` sind gesperrt.
- Der `dockerapi`-Netzwerk ist `internal: true` (kein Weg nach draußen), nicht veroeffentlicht.

> Restrisiko: der Runner kann weiterhin Container starten (das ist sein Zweck). Der Proxy
> reduziert die Angriffsflaeche, ersetzt aber keine echte Isolation. Fuer maximale Trennung
> -> eigener Runner-Host (unten).

### 2. Gehaerteter Daemon (`infra/gitea/daemon.json`)
`no-new-privileges`, `live-restore`, `userland-proxy: false`, `icc: false`
(keine Inter-Container-Comms auf der Default-Bridge), Log-Limits, ulimits. Wird von
`bootstrap.sh` nach `/etc/docker/daemon.json` deployt.

### 3. Firewall regiert Docker (`ufw-docker`)
Docker umgeht UFW normalerweise via eigener iptables-Regeln — veroeffentlichte Ports waeren
trotz UFW offen. `bootstrap.sh` installiert `ufw-docker`, das UFW auch fuer Container gelten
laesst. Zusaetzlich ist Gitea-Web an `127.0.0.1` gebunden (nur per SSH-Tunnel erreichbar).

### 4. Least privilege pro Container
`security_opt: no-new-privileges` auf allen Services, `mem_limit` + `pids_limit`,
socket-proxy zusaetzlich `cap_drop: ALL` + `read_only`. Image-Tags gepinnt (kein `latest`).

### 5. Host-Basis (`bootstrap.sh`)
SSH-Key-only, kein root-Passwort-Login, UFW default-deny, fail2ban, unattended-upgrades.

## Verifizieren

```bash
docker info | grep -iE 'live restore|userland'      # live-restore true, userland-proxy false
docker inspect socketproxy | grep -i readonly       # ReadonlyRootfs true
ufw status                                           # nur 22, 2222, 80, 443
ufw-docker list                                      # Docker-Regeln unter UFW-Kontrolle
```
**Ersten CI-Lauf pruefen:** Wenn der Runner ueber den Proxy keine Jobs starten kann
(Bind-Mount-/Pfadthemen bei remote `DOCKER_HOST`), in `infra/gitea/docker-compose.yml`
temporaer den Host-Socket direkt am Runner mounten und die Ursache eingrenzen — Ziel bleibt
der Proxy.

## Optionale naechste Stufen (opt-in, vorher testen)

### A. User-Namespace-Remapping (Container-Root != Host-Root)
In `/etc/docker/daemon.json` ergaenzen: `"userns-remap": "default"`, dann Docker neu starten.
Aendert Volume-Eigentuemerschaft — vorher auf einem Testsystem pruefen (Gitea-`/data`-Rechte).

### B. Rootless Docker
Docker als non-root-User betreiben (`dockerd-rootless-setuptool.sh install`). Staerkste
Reduktion der Daemon-Angriffsflaeche; erfordert Anpassung von Socket-Pfad + Ports.

### C. Runner-Isolation
Den act_runner auf eine **eigene, wegwerfbare VM/VPS** legen, getrennt von Gitea. Beste
Trennung, da CI-Jobs dann nie neben dem Git-Server laufen.

### D. Gitea-Caps weiter reduzieren
Statt Default-Caps: `cap_drop: [ALL]` + gezielt zurueck (`CHOWN, DAC_OVERRIDE, FOWNER,
SETGID, SETUID`) oder das `gitea/gitea:1.22-rootless`-Image nutzen. Vorher testen, da Gitea
fuer User-Switching + SSH einige Caps braucht.

### E. Images scannen + aktuell halten
`trivy image <image>` bzw. `grype` in CI/Cron; Tags gepinnt lassen und bewusst hochziehen.

### F. Secret-Dateirechte
`chmod 600 infra/gitea/.env`; Secrets nie ins Image backen; Gitea-Secrets fuer CI nutzen.
