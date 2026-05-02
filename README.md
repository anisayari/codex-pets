# Codex Pets

One-command custom pet installer for the Codex desktop app.

## Pets

### Zoro

A fan-made chibi swordsman pet for Codex, with sword idle, dash, jump-combo, lost-direction, review, and failed animations.

![Zoro contact sheet](previews/zoro-contact-sheet.png)

Included files:

- `pets/zoro/pet.json`
- `pets/zoro/spritesheet.webp`

## Fast Install

### Windows PowerShell

Run this in PowerShell:

```powershell
irm https://raw.githubusercontent.com/anisayari/codex-pets/main/install.ps1 | iex
```

List available pets:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/anisayari/codex-pets/main/install.ps1))) -List
```

Install a specific pet:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/anisayari/codex-pets/main/install.ps1))) -Pet zoro
```

### macOS / Linux

Run this in a terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/anisayari/codex-pets/main/install.sh | bash
```

List available pets:

```bash
curl -fsSL https://raw.githubusercontent.com/anisayari/codex-pets/main/install.sh | bash -s -- --list
```

Install a specific pet:

```bash
curl -fsSL https://raw.githubusercontent.com/anisayari/codex-pets/main/install.sh | bash -s -- zoro
```

## How It Works

No localhost server or package manager is required. The installer:

1. Reads `pets.json` from this repo.
2. Downloads only the selected pet files.
3. Copies them into your local Codex pets folder:

   - Windows: `%USERPROFILE%\.codex\pets\<pet-id>`
   - macOS/Linux: `~/.codex/pets/<pet-id>`

4. You reload Codex and select the pet.

## Add Another Pet

1. Add the pet package:

   - `pets/<pet-id>/pet.json`
   - `pets/<pet-id>/spritesheet.webp`

2. Add an entry to `pets.json`.
3. Push to `main`.

The same install commands will then be able to list and install the new pet.

## Manual Install

1. Create this folder:

   - Windows: `%USERPROFILE%\.codex\pets\zoro`
   - macOS/Linux: `~/.codex/pets/zoro`

2. Copy these files into that folder:

   - `pets/zoro/pet.json`
   - `pets/zoro/spritesheet.webp`

3. In Codex, reload pets:

   - `Ctrl+K` -> `Force Reload Skills`
   - or restart Codex

4. Open `Settings` -> `Appearance` -> `Pets`, then select `Zoro`.

## Notes

- This is an unofficial fan-made pet.
- It is not affiliated with or endorsed by OpenAI, Codex, One Piece, Shueisha, Toei Animation, or Eiichiro Oda.
- The installer only writes to your local Codex pets folder.
