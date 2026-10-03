param(
    [switch]$SkipRetroBar,
    [switch]$SkipOpenShell,
    [switch]$NoLaunch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Assert-Windows10

Write-Host "Windows 95 for Windows 10"
Write-Host "========================="
Write-Host "This installer will:"
Write-Host " - back up current user appearance settings"
Write-Host " - apply the Windows 95 base palette"
Write-Host " - install/configure RetroBar unless skipped"
Write-Host " - install/configure Open-Shell unless skipped"
Write-Host ""

& (Join-Path $PSScriptRoot "backup.ps1")
& (Join-Path $PSScriptRoot "apply-base-theme.ps1")

if (-not $SkipRetroBar) {
    & (Join-Path $PSScriptRoot "install-retrobar.ps1") -NoLaunch:$NoLaunch
}

if (-not $SkipOpenShell) {
    & (Join-Path $PSScriptRoot "install-openshell.ps1")
    if ($NoLaunch) {
        & (Join-Path $PSScriptRoot "configure-openshell.ps1") -NoLaunch
    }
}

Write-Host ""
Write-Host "Installation stage complete."
Write-Host "Run .\scripts\status.ps1 to inspect the setup."
Write-Host "For the most reliable visual refresh, sign out of Windows and sign back in."
