param(
    [switch]$AllowUnsupportedWindows
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Assert-Windows10 -AllowUnsupportedWindows:$AllowUnsupportedWindows

Write-Section "Applying Windows 95 base appearance"

$colorsKey = "HKCU:\Control Panel\Colors"
$colors = [ordered]@{
    Background        = "0 128 128"
    ActiveTitle       = "0 0 128"
    TitleText         = "255 255 255"
    InactiveTitle     = "128 128 128"
    InactiveTitleText = "192 192 192"
    Window            = "255 255 255"
    WindowText        = "0 0 0"
    ButtonFace        = "192 192 192"
    ButtonText        = "0 0 0"
    ButtonHilight     = "255 255 255"
    ButtonLight       = "223 223 223"
    ButtonShadow      = "128 128 128"
    ButtonDkShadow    = "0 0 0"
    Hilight           = "0 0 128"
    HilightText       = "255 255 255"
    GrayText          = "128 128 128"
    Menu              = "192 192 192"
    MenuText          = "0 0 0"
    Scrollbar         = "192 192 192"
    AppWorkspace      = "128 128 128"
    InfoWindow        = "255 255 225"
    InfoText          = "0 0 0"
}

foreach ($item in $colors.GetEnumerator()) {
    Set-RegistryValue -Path $colorsKey -Name $item.Key -Value $item.Value -Type String
    Write-Host ("{0,-20} {1}" -f $item.Key, $item.Value)
}

$desktopKey = "HKCU:\Control Panel\Desktop"
Set-RegistryValue -Path $desktopKey -Name "Wallpaper" -Value "" -Type String
Set-RegistryValue -Path $desktopKey -Name "TileWallpaper" -Value "0" -Type String
Set-RegistryValue -Path $desktopKey -Name "WallpaperStyle" -Value "0" -Type String

Write-Host ""
Write-Host "Base profile applied. Sign out/in after installation for the most reliable refresh."
