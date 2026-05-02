param(
  [string]$Pet = "",
  [switch]$All,
  [switch]$List,
  [string]$Owner = "anisayari",
  [string]$Repo = "codex-pets",
  [string]$Branch = "main",
  [string]$BaseUrl = ""
)

$ErrorActionPreference = "Stop"

function Get-CodexHome {
  if ($env:CODEX_HOME) {
    return $env:CODEX_HOME
  }

  if ($env:USERPROFILE) {
    return (Join-Path $env:USERPROFILE ".codex")
  }

  return (Join-Path $HOME ".codex")
}

function Get-RawBaseUrl {
  if (-not [string]::IsNullOrWhiteSpace($BaseUrl)) {
    return $BaseUrl.TrimEnd("/")
  }

  return "https://raw.githubusercontent.com/$Owner/$Repo/$Branch"
}

function Get-PetRegistry {
  param([string]$RawBaseUrl)

  $registryUrl = "$RawBaseUrl/pets.json"
  try {
    return Invoke-RestMethod -UseBasicParsing -Uri $registryUrl
  } catch {
    throw "Could not load pet registry from $registryUrl. $($_.Exception.Message)"
  }
}

function Get-Pets {
  param($Registry)

  if ($null -eq $Registry.pets) {
    throw "The registry does not contain a pets list."
  }

  return @($Registry.pets)
}

function Show-Pets {
  param([object[]]$Pets)

  Write-Host "Available Codex pets:"
  for ($i = 0; $i -lt $Pets.Count; $i++) {
    $petInfo = $Pets[$i]
    Write-Host ("  {0}. {1} ({2})" -f ($i + 1), $petInfo.displayName, $petInfo.id)
    if ($petInfo.description) {
      Write-Host ("     {0}" -f $petInfo.description)
    }
  }
}

function Find-Pet {
  param(
    [object[]]$Pets,
    [string]$PetId
  )

  foreach ($petInfo in $Pets) {
    if ($petInfo.id -eq $PetId) {
      return $petInfo
    }
  }

  $available = ($Pets | ForEach-Object { $_.id }) -join ", "
  throw "Unknown pet '$PetId'. Available pets: $available"
}

function Select-PetId {
  param([object[]]$Pets)

  if ($Pets.Count -eq 1) {
    return $Pets[0].id
  }

  Show-Pets -Pets $Pets
  while ($true) {
    $choice = Read-Host "Choose a pet number or id"

    $number = 0
    if ([int]::TryParse($choice, [ref]$number)) {
      if ($number -ge 1 -and $number -le $Pets.Count) {
        return $Pets[$number - 1].id
      }
    }

    foreach ($petInfo in $Pets) {
      if ($petInfo.id -eq $choice) {
        return $petInfo.id
      }
    }

    Write-Host "Invalid choice. Try again."
  }
}

function Install-Pet {
  param(
    $PetInfo,
    [string]$RawBaseUrl,
    [string]$CodexHome
  )

  $petId = [string]$PetInfo.id
  if ([string]::IsNullOrWhiteSpace($petId)) {
    throw "Registry entry is missing a pet id."
  }

  $petPath = if ($PetInfo.path) { [string]$PetInfo.path } else { "pets/$petId" }
  $files = if ($PetInfo.files) { @($PetInfo.files) } else { @("pet.json", "spritesheet.webp") }

  $dest = Join-Path $CodexHome "pets\$petId"
  New-Item -ItemType Directory -Force -Path $dest | Out-Null

  foreach ($file in $files) {
    $fileName = Split-Path -Leaf $file
    $uri = "$RawBaseUrl/$petPath/$file"
    $outFile = Join-Path $dest $fileName
    Invoke-WebRequest -UseBasicParsing -Uri $uri -OutFile $outFile
  }

  Write-Host "Installed Codex pet '$petId' to: $dest"
}

$rawBaseUrl = Get-RawBaseUrl
$registry = Get-PetRegistry -RawBaseUrl $rawBaseUrl
$pets = Get-Pets -Registry $registry

if ($List) {
  Show-Pets -Pets $pets
  return
}

$codexHome = Get-CodexHome

if ($All) {
  foreach ($petInfo in $pets) {
    Install-Pet -PetInfo $petInfo -RawBaseUrl $rawBaseUrl -CodexHome $codexHome
  }
} else {
  if ([string]::IsNullOrWhiteSpace($Pet)) {
    $Pet = Select-PetId -Pets $pets
  }

  $selectedPet = Find-Pet -Pets $pets -PetId $Pet
  Install-Pet -PetInfo $selectedPet -RawBaseUrl $rawBaseUrl -CodexHome $codexHome
}

Write-Host ""
Write-Host "Reload Codex with Ctrl+K -> Force Reload Skills, or restart Codex."
Write-Host "Then select the pet in Settings -> Appearance -> Pets."
