param(
    [switch]$NoRestartExplorer
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Write-Section "Configuring Open-Shell Classic Explorer"

$key = "HKCU:\Software\OpenShell\ClassicExplorer\Settings"

# Windows 95-oriented Explorer behavior. Open-Shell TYPE_INT radio values use numeric indexes.
Set-RegistryValue -Path $key -Name "TreeStyle"          -Value 0 -Type DWord
Set-RegistryValue -Path $key -Name "NoFadeButtons"      -Value 1 -Type DWord
Set-RegistryValue -Path $key -Name "FullIndent"         -Value 1 -Type DWord
Set-RegistryValue -Path $key -Name "DisableBreadcrumbs" -Value 1 -Type DWord
Set-RegistryValue -Path $key -Name "AddressBarHistory"  -Value 1 -Type DWord
Set-RegistryValue -Path $key -Name "HideSearch"         -Value 1 -Type DWord

Set-RegistryValue -Path $key -Name "UseBigButtons"      -Value 0  -Type DWord
Set-RegistryValue -Path $key -Name "SmallIconSize"      -Value 16 -Type DWord
Set-RegistryValue -Path $key -Name "LargeIconSize"      -Value 24 -Type DWord
Set-RegistryValue -Path $key -Name "MenuIconSize"       -Value 16 -Type DWord
Set-RegistryValue -Path $key -Name "ToolbarListMode"    -Value 0  -Type DWord
Set-RegistryValue -Path $key -Name "SameSizeButtons"    -Value 0  -Type DWord

Set-RegistryValue -Path $key -Name "ShowStatusBar"      -Value 1 -Type DWord
Set-RegistryValue -Path $key -Name "ShowFreeSpace2"     -Value 1 -Type DWord
Set-RegistryValue -Path $key -Name "ShowZone"           -Value 1 -Type DWord
Set-RegistryValue -Path $key -Name "ShowInfoTip2"       -Value 1 -Type DWord
Set-RegistryValue -Path $key -Name "StatusBarFont"      -Value "Microsoft Sans Serif, normal, 8" -Type String
Set-RegistryValue -Path $key -Name "FileExplorer"       -Value 1 -Type DWord

$advanced = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-RegistryValue -Path $advanced -Name "AlwaysShowMenus" -Value 1 -Type DWord
Set-RegistryValue -Path $advanced -Name "ShowStatusBar" -Value 1 -Type DWord

$classicSettings = Get-ClassicExplorerSettingsExe
if (-not $classicSettings) {
    Write-Warning "Classic Explorer component is not installed yet. Settings are ready for when it is installed."
} else {
    Write-Host "Classic Explorer component: $classicSettings"
}

Write-Host "Classic Explorer profile written."
Write-Host "If the Classic Explorer toolbar is not visible after sign-out, enable 'Classic Explorer Bar' once from Explorer's toolbar/menu context menu."

if (-not $NoRestartExplorer) {
    Write-Host "Explorer restart is recommended after installation, but the main installer performs final component startup."
}
