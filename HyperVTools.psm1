# ================================
# HyperVTools.psm1
# Module principal
# ================================

# --- Import des fonctions privées ---
$privatePath = Join-Path $PSScriptRoot "Private"
Get-ChildItem -Path $privatePath -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# --- Import des fonctions publiques ---
$publicPath = Join-Path $PSScriptRoot "Public"
Get-ChildItem -Path $publicPath -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# --- Export des fonctions publiques ---
Export-ModuleMember -Function @(
    "New-CustomVM",
    "New-CustomVSwitch",
    "New-CustomNAT",
    "Get-AvailableVSwitches"
)
