param(
    [switch]$AllowUnsupportedWindows
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Assert-Windows10 -AllowUnsupportedWindows:$AllowUnsupportedWindows
Write-Section "Applying Windows 95 full shell profile"

# Force Windows system surfaces that follow the OS preference out of dark mode.
$personalize = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-RegistryValue -Path $personalize -Name "AppsUseLightTheme"    -Value 1 -Type DWord
Set-RegistryValue -Path $personalize -Name "SystemUsesLightTheme" -Value 1 -Type DWord
Set-RegistryValue -Path $personalize -Name "EnableTransparency"   -Value 0 -Type DWord

# Prefer the classic navy accent on title bars/borders where Windows 10 still honors it.
$dwm = "HKCU:\Software\Microsoft\Windows\DWM"
Set-RegistryValue -Path $dwm -Name "ColorPrevalence" -Value 1 -Type DWord
& reg.exe add "HKCU\Software\Microsoft\Windows\DWM" /v AccentColor /t REG_DWORD /d 0xFF800000 /f | Out-Null

# Explorer: open at This PC, expose a classic menu/status layout and keep the ribbon collapsed.
$advanced = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-RegistryValue -Path $advanced -Name "LaunchTo"        -Value 1 -Type DWord
Set-RegistryValue -Path $advanced -Name "AlwaysShowMenus" -Value 1 -Type DWord
Set-RegistryValue -Path $advanced -Name "ShowStatusBar"   -Value 1 -Type DWord

$ribbon = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Ribbon"
Set-RegistryValue -Path $ribbon -Name "MinimizedStateTabletModeOff" -Value 1 -Type DWord

# Control Panel: go directly to the classic all-items icon view.
$controlPanel = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel"
Set-RegistryValue -Path $controlPanel -Name "StartupPage"      -Value 1 -Type DWord
Set-RegistryValue -Path $controlPanel -Name "AllItemsIconView" -Value 1 -Type DWord

# Make the classic system palette effective immediately for Win32 controls and the desktop.
if (-not ("Win95Native.User32" -as [type])) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
namespace Win95Native {
    public static class User32 {
        [DllImport("user32.dll", SetLastError=true)]
        public static extern bool SetSysColors(int cElements, int[] lpaElements, int[] lpaRgbValues);

        [DllImport("user32.dll", CharSet=CharSet.Auto, SetLastError=true)]
        public static extern bool SystemParametersInfo(int uiAction, int uiParam, string pvParam, int fWinIni);
    }
}
"@
}

function New-ColorRef {
    param([int]$R,[int]$G,[int]$B)
    return ($R -bor ($G -shl 8) -bor ($B -shl 16))
}

# COLOR_* indexes used by classic Win32 controls.
$indexes = @(0,1,2,3,4,5,7,8,9,12,13,14,15,16,17,18,19,20,21,22,23,24)
$values = @(
    (New-ColorRef 192 192 192), # Scrollbar
    (New-ColorRef 0 128 128),   # Desktop
    (New-ColorRef 0 0 128),     # Active caption
    (New-ColorRef 128 128 128), # Inactive caption
    (New-ColorRef 192 192 192), # Menu
    (New-ColorRef 255 255 255), # Window
    (New-ColorRef 0 0 0),       # Menu text
    (New-ColorRef 0 0 0),       # Window text
    (New-ColorRef 255 255 255), # Caption text
    (New-ColorRef 128 128 128), # App workspace
    (New-ColorRef 0 0 128),     # Highlight
    (New-ColorRef 255 255 255), # Highlight text
    (New-ColorRef 192 192 192), # Button face
    (New-ColorRef 128 128 128), # Button shadow
    (New-ColorRef 128 128 128), # Gray text
    (New-ColorRef 0 0 0),       # Button text
    (New-ColorRef 192 192 192), # Inactive caption text
    (New-ColorRef 255 255 255), # Button highlight
    (New-ColorRef 0 0 0),       # 3D dark shadow
    (New-ColorRef 223 223 223), # 3D light
    (New-ColorRef 0 0 0),       # Info text
    (New-ColorRef 255 255 225)  # Info background
)

[void][Win95Native.User32]::SetSysColors($indexes.Count,$indexes,$values)

# SPI_SETDESKWALLPAPER with an empty path removes the wallpaper and exposes #008080.
$SPI_SETDESKWALLPAPER = 0x0014
$SPIF_UPDATEINIFILE = 0x0001
$SPIF_SENDCHANGE = 0x0002
[void][Win95Native.User32]::SystemParametersInfo(
    $SPI_SETDESKWALLPAPER,0,"",$SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE
)

Write-Host "Full shell profile written."
Write-Host "Explorer/Control Panel should switch to the light classic-oriented shell after Explorer restart or sign-out."
