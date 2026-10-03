param(
    [switch]$KeepLocalizedNames
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Write-Section "Configuring classic desktop icons"

$icons = [ordered]@{
    "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" = "My Computer"
    "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" = "Network Neighborhood"
    "{59031A47-3F72-44A7-89C5-5595FE6B30EE}" = "My Documents"
    "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" = "Control Panel"
    "{645FF040-5081-101B-9F08-00AA002F954E}" = "Recycle Bin"
}

$visibilityKeys = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu"
)

foreach ($guid in $icons.Keys) {
    foreach ($key in $visibilityKeys) {
        Set-RegistryValue -Path $key -Name $guid -Value 0 -Type DWord
    }

    if (-not $KeepLocalizedNames) {
        $labelKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\$guid"
        New-Item -Path $labelKey -Force | Out-Null
        Set-Item -Path $labelKey -Value $icons[$guid]
    }

    Write-Host ("Show: {0}" -f $icons[$guid])
}

Write-Host "Desktop icon configuration written."
Write-Host "Press F5 on the desktop or sign out/in if the icons do not refresh immediately."
