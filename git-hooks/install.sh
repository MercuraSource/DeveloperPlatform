#!/usr/bin/env bash
# Lokale Hooks im aktuellen Repo aktivieren. Im Repo-Root ausfuehren:
#   bash git-hooks/install.sh
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SRC="$ROOT/git-hooks"

for hook in pre-commit pre-push; do
  cp "$SRC/$hook" "$ROOT/.git/hooks/$hook"
  chmod +x "$ROOT/.git/hooks/$hook"
  echo "installiert: .git/hooks/$hook"
done

echo "Fertig. HINWEIS: lokale Hooks sind mit --no-verify umgehbar."
echo "Die verbindliche Erzwingung ist Branch-Protection + CI (docs/enforcement.md)."
