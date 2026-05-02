#!/usr/bin/env bash
set -euo pipefail

PET="${PET:-zoro}"
OWNER="${OWNER:-anisayari}"
REPO="${REPO:-codex-pets}"
BRANCH="${BRANCH:-main}"

if [[ -n "${CODEX_HOME:-}" ]]; then
  CODEX_DIR="$CODEX_HOME"
else
  CODEX_DIR="$HOME/.codex"
fi

DEST="$CODEX_DIR/pets/$PET"
BASE_URL="https://raw.githubusercontent.com/$OWNER/$REPO/$BRANCH/pets/$PET"

mkdir -p "$DEST"
curl -fsSL "$BASE_URL/pet.json" -o "$DEST/pet.json"
curl -fsSL "$BASE_URL/spritesheet.webp" -o "$DEST/spritesheet.webp"

echo "Installed Codex pet '$PET' to: $DEST"
echo "Reload Codex with Ctrl+K -> Force Reload Skills, or restart Codex."
echo "Then select the pet in Settings -> Appearance -> Pets."
