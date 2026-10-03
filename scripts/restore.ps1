param(
    [Parameter(Mandatory = $true)]
    [string]$BackupPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$resolved = Resolve-Path $BackupPath
$colors = Join-Path $resolved "colors.reg"
$desktop = Join-Path $resolved "desktop.reg"

if (-not (Test-Path $colors)) {
    throw "Missing colors.reg in backup."
}
if (-not (Test-Path $desktop)) {
    throw "Missing desktop.reg in backup."
}

Write-Host "Restoring user appearance registry settings..."

reg.exe import $colors | Out-Null
reg.exe import $desktop | Out-Null

Write-Host "Restore complete."
Write-Host "Sign out and sign back in to refresh the shell."
