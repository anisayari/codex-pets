param(
  [string]$Pet = "zoro",
  [string]$Owner = "anisayari",
  [string]$Repo = "codex-pets",
  [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

if ($env:CODEX_HOME) {
  $codexHome = $env:CODEX_HOME
} elseif ($env:USERPROFILE) {
  $codexHome = Join-Path $env:USERPROFILE ".codex"
} else {
  $codexHome = Join-Path $HOME ".codex"
}

$dest = Join-Path $codexHome "pets\$Pet"
$baseUrl = "https://raw.githubusercontent.com/$Owner/$Repo/$Branch/pets/$Pet"

New-Item -ItemType Directory -Force -Path $dest | Out-Null

Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/pet.json" -OutFile (Join-Path $dest "pet.json")
Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/spritesheet.webp" -OutFile (Join-Path $dest "spritesheet.webp")

Write-Host "Installed Codex pet '$Pet' to: $dest"
Write-Host "Reload Codex with Ctrl+K -> Force Reload Skills, or restart Codex."
Write-Host "Then select the pet in Settings -> Appearance -> Pets."
