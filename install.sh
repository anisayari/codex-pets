#!/usr/bin/env bash
set -euo pipefail

PET="${PET:-}"
OWNER="${OWNER:-anisayari}"
REPO="${REPO:-codex-pets}"
BRANCH="${BRANCH:-main}"
BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/$OWNER/$REPO/$BRANCH}"
LIST=0
ALL=0

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --list|-l)
      LIST=1
      ;;
    --all|-a)
      ALL=1
      ;;
    --pet)
      shift
      PET="${1:-}"
      ;;
    --pet=*)
      PET="${1#*=}"
      ;;
    --base-url=*)
      BASE_URL="${1#*=}"
      ;;
    *)
      PET="$1"
      ;;
  esac
  shift
done

BASE_URL="${BASE_URL%/}"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REGISTRY="$TMP_DIR/pets.json"
curl -fsSL "$BASE_URL/pets.json" -o "$REGISTRY"

PET_IDS="$(sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$REGISTRY")"

if [[ -z "$PET_IDS" ]]; then
  echo "No pets found in registry: $BASE_URL/pets.json" >&2
  exit 1
fi

show_pets() {
  echo "Available Codex pets:"
  while IFS= read -r pet_id; do
    [[ -n "$pet_id" ]] && echo "  - $pet_id"
  done <<< "$PET_IDS"
}

choose_pet() {
  local count first choice index current i
  count="$(printf '%s\n' "$PET_IDS" | sed '/^$/d' | wc -l | tr -d ' ')"
  first="$(printf '%s\n' "$PET_IDS" | sed '/^$/d' | sed -n '1p')"

  if [[ "$count" == "1" ]]; then
    printf '%s\n' "$first"
    return
  fi

  show_pets >&2
  printf 'Choose a pet number or id: ' >&2
  read -r choice

  if [[ "$choice" =~ ^[0-9]+$ ]]; then
    index=1
    while IFS= read -r current; do
      if [[ "$index" == "$choice" ]]; then
        printf '%s\n' "$current"
        return
      fi
      index=$((index + 1))
    done <<< "$PET_IDS"
  fi

  while IFS= read -r current; do
    if [[ "$current" == "$choice" ]]; then
      printf '%s\n' "$current"
      return
    fi
  done <<< "$PET_IDS"

  echo "Invalid pet: $choice" >&2
  exit 1
}

install_pet() {
  local pet_id dest pet_url
  pet_id="$1"
  dest="$CODEX_DIR/pets/$pet_id"
  pet_url="$BASE_URL/pets/$pet_id"

  mkdir -p "$dest"
  curl -fsSL "$pet_url/pet.json" -o "$dest/pet.json"
  curl -fsSL "$pet_url/spritesheet.webp" -o "$dest/spritesheet.webp"

  echo "Installed Codex pet '$pet_id' to: $dest"
}

if [[ "$LIST" == "1" ]]; then
  show_pets
  exit 0
fi

if [[ "$ALL" == "1" ]]; then
  while IFS= read -r pet_id; do
    [[ -n "$pet_id" ]] && install_pet "$pet_id"
  done <<< "$PET_IDS"
else
  if [[ -z "$PET" ]]; then
    PET="$(choose_pet)"
  fi

  install_pet "$PET"
fi

echo ""
echo "Reload Codex with Ctrl+K -> Force Reload Skills, or restart Codex."
echo "Then select the pet in Settings -> Appearance -> Pets."
