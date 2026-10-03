Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $root "scripts\lib\Common.ps1")

$missing = [pscustomobject]@{
    PSPath = "Registry::HKCU\Software\Example"
}

$value = Get-ObjectPropertyValue -Object $missing -Name "DisplayName"
if ($null -ne $value) {
    throw "Expected missing DisplayName to return null."
}

$entries = @(
    $missing,
    [pscustomobject]@{
        DisplayName = "RetroBar"
        InstallLocation = "C:\Program Files\RetroBar"
    },
    [pscustomobject]@{
        DisplayName = "Open-Shell Menu"
        InstallLocation = "C:\Program Files\Open-Shell"
    }
)

$retro = $entries | Where-Object {
    (Get-ObjectPropertyValue -Object $_ -Name "DisplayName") -eq "RetroBar"
} | Select-Object -First 1

if (-not $retro) {
    throw "RetroBar lookup failed when an earlier uninstall entry lacked DisplayName."
}

$openShell = $entries | Where-Object {
    (Get-ObjectPropertyValue -Object $_ -Name "DisplayName") -match "^Open-Shell"
} | Select-Object -First 1

if (-not $openShell) {
    throw "Open-Shell lookup failed when an earlier uninstall entry lacked DisplayName."
}

Write-Host "StrictMode uninstall-entry regression test passed."
