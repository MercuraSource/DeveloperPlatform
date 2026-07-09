#!/usr/bin/env bash
# PreToolUse-Hook fuer Bash. Blockt nicht verhandelbare Kommandos HART.
# Exit 2 = Aktion wird vor der Ausfuehrung gestoppt (auch gegen allow-Regeln).
# Braucht python3 (auf Dev-Maschinen ueblich). Fehlt es, faellt der Hook offen aus;
# die harte Absicherung ist dann die server-seitige Branch-Protection + CI.
set -euo pipefail
payload="$(cat)"
cmd="$(printf '%s' "$payload" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)"
[ -z "$cmd" ] && exit 0

block() {
  echo "BLOCKIERT (Regel): $1" >&2
  echo "  -> rules/AGENT.md + docs/enforcement.md" >&2
  exit 2
}

# Kein Direkt-Push auf main/master
printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push([[:space:]]+[^[:space:]]+)*[[:space:]]+(origin[[:space:]]+)?(main|master)([[:space:]]|:|$)' \
  && block "Direkt-Push auf main/master. Feature-Branch + PR nutzen (WORKFLOW 4.5)."
# Kein Force-Push
printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push.*(--force([[:space:]]|=|$)|[[:space:]]-f([[:space:]]|$))' \
  && block "Force-Push ist verboten."
# Keine Hook-Umgehung
printf '%s' "$cmd" | grep -Eq -- '--no-verify' \
  && block "--no-verify umgeht die lokalen Hooks."
# Keine Secret-Dateien ueber die Shell lesen
printf '%s' "$cmd" | grep -Eq '(^|[^[:alnum:]_./-])(cat|bat|less|more|head|tail|nano|vi|vim|strings|xxd|hexdump)[[:space:]]+[^|;&]*(^|/|[[:space:]])\.env([[:space:]]|$|\.)' \
  && block "Zugriff auf .env/Secrets ueber die Shell."
# Kein gefaehrliches rekursives Loeschen
printf '%s' "$cmd" | grep -Eiq 'rm[[:space:]]+(-[a-z]*f[a-z]*[[:space:]]+)+(/($|[[:space:]])|~|\$home|\.\.($|/))' \
  && block "Gefaehrliches rekursives Loeschen."

exit 0
