param(
    [Parameter(Mandatory=$true)]
    [string]$SourceDirectory,

    [switch]$ApplyCursors,
    [switch]$ApplySounds
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

$source = Resolve-Path $SourceDirectory
$assetRoot = Join-Path $env:LOCALAPPDATA "Windows95ForWindows10\Assets"
$cursorDest = Join-Path $assetRoot "Cursors"
$soundDest = Join-Path $assetRoot "Sounds"

New-Item -ItemType Directory -Force -Path $cursorDest,$soundDest | Out-Null

Write-Section "Importing user-owned assets"
Write-Host "Source: $source"
Write-Host "Destination: $assetRoot"

# This repository never ships Microsoft Windows 95 assets.
# To keep the importer deterministic, rename files to the role names below.

$cursorMap = [ordered]@{
    Arrow       = "arrow.cur"
    Help        = "help.cur"
    AppStarting = "appstarting.ani"
    Wait        = "wait.ani"
    Crosshair   = "crosshair.cur"
    IBeam       = "ibeam.cur"
    NWPen       = "nwpen.cur"
    No          = "no.cur"
    SizeNS      = "sizens.cur"
    SizeWE      = "sizewe.cur"
    SizeNWSE    = "sizenwse.cur"
    SizeNESW    = "sizenesw.cur"
    SizeAll     = "sizeall.cur"
    UpArrow     = "uparrow.cur"
    Hand        = "hand.cur"
}

foreach ($role in $cursorMap.Keys) {
    $candidate = Join-Path $source $cursorMap[$role]
    if (Test-Path $candidate) {
        Copy-Item $candidate (Join-Path $cursorDest $cursorMap[$role]) -Force
        Write-Host "Cursor: $role"
    }
}

$soundMap = [ordered]@{
    ".Default\SystemAsterisk"    = "asterisk.wav"
    ".Default\SystemExclamation" = "exclamation.wav"
    ".Default\SystemHand"        = "critical-stop.wav"
    ".Default\SystemQuestion"    = "question.wav"
    ".Default\SystemStart"       = "startup.wav"
    ".Default\SystemExit"        = "shutdown.wav"
    "Explorer\EmptyRecycleBin"   = "empty-recycle-bin.wav"
}

foreach ($event in $soundMap.Keys) {
    $candidate = Join-Path $source $soundMap[$event]
    if (Test-Path $candidate) {
        Copy-Item $candidate (Join-Path $soundDest $soundMap[$event]) -Force
        Write-Host "Sound: $event"
    }
}

if ($ApplyCursors) {
    Write-Section "Applying imported cursor set"
    $cursorKey = "HKCU:\Control Panel\Cursors"
    foreach ($role in $cursorMap.Keys) {
        $path = Join-Path $cursorDest $cursorMap[$role]
        if (Test-Path $path) {
            Set-RegistryValue -Path $cursorKey -Name $role -Value $path -Type String
        }
    }
    Set-RegistryValue -Path $cursorKey -Name "Scheme Source" -Value 1 -Type DWord
    Write-Host "Cursor registry values updated. Sign out/in if Windows does not reload them immediately."
}

if ($ApplySounds) {
    Write-Section "Applying imported sound set"
    foreach ($event in $soundMap.Keys) {
        $path = Join-Path $soundDest $soundMap[$event]
        if (-not (Test-Path $path)) { continue }

        $parts = $event -split "\\", 2
        $app = $parts[0]
        $eventName = $parts[1]
        $currentKey = "HKCU:\AppEvents\Schemes\Apps\$app\$eventName\.Current"
        New-Item -Path $currentKey -Force | Out-Null
        Set-Item -Path $currentKey -Value $path
    }
    Write-Host "Sound event .Current values updated."
}

Write-Host ""
Write-Host "Import complete."
