Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Applying Windows 95 base appearance..."
Write-Host "This changes current-user appearance values only."

$colorsKey = "HKCU:\Control Panel\Colors"

$colors = @{
    Background          = "0 128 128"
    ActiveTitle         = "0 0 128"
    TitleText           = "255 255 255"
    InactiveTitle       = "128 128 128"
    InactiveTitleText   = "192 192 192"
    Window              = "255 255 255"
    WindowText          = "0 0 0"
    ButtonFace          = "192 192 192"
    ButtonText          = "0 0 0"
    ButtonHilight       = "255 255 255"
    ButtonLight         = "223 223 223"
    ButtonShadow        = "128 128 128"
    ButtonDkShadow      = "0 0 0"
    Hilight             = "0 0 128"
    HilightText         = "255 255 255"
    GrayText            = "128 128 128"
    Menu                = "192 192 192"
    MenuText            = "0 0 0"
    Scrollbar           = "192 192 192"
    AppWorkspace        = "128 128 128"
    InfoWindow          = "255 255 225"
    InfoText            = "0 0 0"
}

foreach ($name in $colors.Keys) {
    Set-ItemProperty -Path $colorsKey -Name $name -Value $colors[$name]
    Write-Host ("Set {0} = {1}" -f $name, $colors[$name])
}

$desktopKey = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $desktopKey -Name "Wallpaper" -Value ""

Write-Host ""
Write-Host "Base Windows 95 profile applied."
Write-Host "Sign out and sign in again for the most reliable refresh."
Write-Host ""
Write-Host "Next:"
Write-Host "1. Install/configure RetroBar."
Write-Host "2. Install/configure Open-Shell."
Write-Host "3. See docs\INSTALL.md."
