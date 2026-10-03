param(
    [Parameter(Mandatory = $true)]
    [string]$BackupPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$resolved = Resolve-Path $BackupPath
Write-Host "Restoring from: $resolved"

$imports = @("colors.reg","desktop.reg","openshell.reg","run.reg")
foreach ($name in $imports) {
    $file = Join-Path $resolved $name
    if (Test-Path $file) {
        & reg.exe import $file | Out-Null
        Write-Host "Imported $name"
    }
}

$retroBackup = Join-Path $resolved "retrobar-settings.json"
if (Test-Path $retroBackup) {
    $retroDir = Join-Path $env:LOCALAPPDATA "RetroBar"
    New-Item -ItemType Directory -Force -Path $retroDir | Out-Null
    Copy-Item $retroBackup (Join-Path $retroDir "settings.json") -Force
    Write-Host "Restored RetroBar settings."
}

Write-Host "Restore complete."
Write-Host "Sign out and sign back in to refresh the shell."
