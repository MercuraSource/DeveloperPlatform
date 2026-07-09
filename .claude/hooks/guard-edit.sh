#!/usr/bin/env bash
# PreToolUse-Hook fuer Edit/Write/MultiEdit. Schuetzt Secrets + Enforcement-Config.
# Exit 2 = Aenderung wird gestoppt.
set -euo pipefail
payload="$(cat)"
path="$(printf '%s' "$payload" | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)"
[ -z "$path" ] && exit 0

block() { echo "BLOCKIERT (Regel): $1" >&2; exit 2; }

base="$(basename "$path")"
case "$base" in
  .env|.env.*) [ "$base" = ".env.example" ] || block "Aenderung an .env/Secrets ist verboten." ;;
esac
printf '%s' "$path" | grep -Eq '(^|/)\.git/'                         && block "Aenderung an .git/ ist verboten."
printf '%s' "$path" | grep -Eq '(^|/)\.claude/(settings\.json|hooks/)' && block "Enforcement-Config (.claude/) aendert nur ein Mensch, nicht der Agent."

exit 0
