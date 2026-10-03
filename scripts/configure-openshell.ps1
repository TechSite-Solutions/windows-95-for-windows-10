param(
    [switch]$NoLaunch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Write-Section "Configuring Open-Shell for Windows 95"

Stop-ProcessIfRunning -Name "StartMenu"

$key = "HKCU:\Software\OpenShell\StartMenu\Settings"

# Open-Shell radio settings are integer indexes. 0=Classic1 for MenuStyle,
# 1=ClassicMenu for click/WinKey controls, 2=WindowsMenu for Shift variants.
Set-RegistryValue -Path $key -Name "MenuStyle"       -Value 0 -Type DWord
Set-RegistryValue -Path $key -Name "MouseClick"      -Value 1 -Type DWord
Set-RegistryValue -Path $key -Name "WinKey"          -Value 1 -Type DWord
Set-RegistryValue -Path $key -Name "ShiftClick"      -Value 2 -Type DWord
Set-RegistryValue -Path $key -Name "ShiftWin"        -Value 2 -Type DWord
Set-RegistryValue -Path $key -Name "AlignToWorkArea" -Value 1 -Type DWord

# RetroBar owns the visible Windows 95 Start button; Open-Shell owns the menu.
Set-RegistryValue -Path $key -Name "EnableStartButton" -Value 0 -Type DWord

# Classic single-column menu, no Windows 7 search box, no modern effects.
Set-RegistryValue -Path $key -Name "SkinC1"            -Value "Classic Skin" -Type String
Set-RegistryValue -Path $key -Name "SearchBox"         -Value 0 -Type DWord
Set-RegistryValue -Path $key -Name "MenuShadow"        -Value 0 -Type DWord
Set-RegistryValue -Path $key -Name "AeroGlass"         -Value 0 -Type DWord
Set-RegistryValue -Path $key -Name "EnableGlass"       -Value 0 -Type DWord
Set-RegistryValue -Path $key -Name "MainMenuAnimation" -Value 0 -Type DWord
Set-RegistryValue -Path $key -Name "SubMenuAnimation"  -Value 0 -Type DWord
Set-RegistryValue -Path $key -Name "FontSmoothing"     -Value 1 -Type DWord
Set-RegistryValue -Path $key -Name "SmallIconSize"     -Value 16 -Type DWord

Write-Host "Open-Shell Windows 95 single-column profile written."

$openShell = Get-OpenShellExe
if (-not $openShell) {
    Write-Warning "Open-Shell is not installed yet. Settings will be picked up after installation."
    return
}

if (-not $NoLaunch) {
    Start-Process -FilePath $openShell
    Write-Host "Open-Shell started."
}
