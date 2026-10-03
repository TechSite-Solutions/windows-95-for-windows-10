param(
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

$root = Get-ProjectRoot
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = Join-Path $root ("backups\" + $stamp)
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Section "Creating rollback backup"
Write-Host "Backup directory: $backupDir"

function Export-RegistryKeyIfPresent {
    param(
        [string]$PowerShellPath,
        [string]$RegPath,
        [string]$FileName
    )

    if (-not (Test-Path $PowerShellPath)) {
        return $false
    }

    $file = Join-Path $backupDir $FileName
    & reg.exe export $RegPath $file /y | Out-Null
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $file)) {
        throw "Failed to export registry key: $RegPath"
    }
    return $true
}

$exports = [ordered]@{}
$exports.Colors = Export-RegistryKeyIfPresent "HKCU:\Control Panel\Colors" "HKCU\Control Panel\Colors" "colors.reg"
$exports.Desktop = Export-RegistryKeyIfPresent "HKCU:\Control Panel\Desktop" "HKCU\Control Panel\Desktop" "desktop.reg"
$exports.Cursors = Export-RegistryKeyIfPresent "HKCU:\Control Panel\Cursors" "HKCU\Control Panel\Cursors" "cursors.reg"
$exports.AppEvents = Export-RegistryKeyIfPresent "HKCU:\AppEvents\Schemes" "HKCU\AppEvents\Schemes" "app-events.reg"
$exports.OpenShellStartMenu = Export-RegistryKeyIfPresent "HKCU:\Software\OpenShell\StartMenu" "HKCU\Software\OpenShell\StartMenu" "openshell-startmenu.reg"
$exports.OpenShellClassicExplorer = Export-RegistryKeyIfPresent "HKCU:\Software\OpenShell\ClassicExplorer" "HKCU\Software\OpenShell\ClassicExplorer" "openshell-classic-explorer.reg"
$exports.ThemePersonalize = Export-RegistryKeyIfPresent "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "theme-personalize.reg"
$exports.Dwm = Export-RegistryKeyIfPresent "HKCU:\Software\Microsoft\Windows\DWM" "HKCU\Software\Microsoft\Windows\DWM" "dwm.reg"
$exports.ExplorerAdvanced = Export-RegistryKeyIfPresent "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "explorer-advanced.reg"
$exports.ExplorerRibbon = Export-RegistryKeyIfPresent "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Ribbon" "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Ribbon" "explorer-ribbon.reg"
$exports.ControlPanelView = Export-RegistryKeyIfPresent "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" "control-panel-view.reg"
$exports.CtfLangBar = Export-RegistryKeyIfPresent "HKCU:\Software\Microsoft\CTF\LangBar" "HKCU\Software\Microsoft\CTF\LangBar" "ctf-langbar.reg"
$exports.HideDesktopNew = Export-RegistryKeyIfPresent "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" "desktop-icons-new.reg"
$exports.HideDesktopClassic = Export-RegistryKeyIfPresent "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" "desktop-icons-classic.reg"

$desktopGuids = @(
    "{20D04FE0-3AEA-1069-A2D8-08002B30309D}",
    "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}",
    "{59031A47-3F72-44A7-89C5-5595FE6B30EE}",
    "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}",
    "{645FF040-5081-101B-9F08-00AA002F954E}"
)

$labelExports = [ordered]@{}
$iconOverrideExports = [ordered]@{}

foreach ($guid in $desktopGuids) {
    $safe = $guid.Trim("{}")

    $labelPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\$guid"
    $labelExports[$guid] = Export-RegistryKeyIfPresent $labelPath "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\$guid" ("desktop-label-" + $safe + ".reg")

    $iconPath = "HKCU:\Software\Classes\CLSID\$guid"
    $iconOverrideExports[$guid] = Export-RegistryKeyIfPresent $iconPath "HKCU\Software\Classes\CLSID\$guid" ("desktop-icon-override-" + $safe + ".reg")
}

$retroBarSettings = Join-Path $env:LOCALAPPDATA "RetroBar\settings.json"
$retroBarSettingsExisted = Test-Path $retroBarSettings
if ($retroBarSettingsExisted) {
    Copy-Item $retroBarSettings (Join-Path $backupDir "retrobar-settings.json") -Force
}

$runSnapshot = Get-RegistryValueSnapshot -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "RetroBar"

$languageBarOptions = $null
if (Get-Command Get-WinLanguageBarOption -ErrorAction SilentlyContinue) {
    try {
        $languageBar = Get-WinLanguageBarOption
        $languageBarOptions = [ordered]@{
            IsLegacyLanguageBar = [bool]$languageBar.IsLegacyLanguageBar
            IsLegacySwitchingMode = [bool]$languageBar.IsLegacySwitchingMode
        }
    } catch {
        Write-Warning "Could not snapshot Windows language bar options."
    }
}

$os = Get-WindowsInfo
$meta = [ordered]@{
    SchemaVersion = 5
    CreatedAt = (Get-Date).ToString("o")
    ComputerName = $env:COMPUTERNAME
    UserName = $env:USERNAME
    OS = $os
    Exports = $exports
    DesktopLabelExports = $labelExports
    IconOverrideExports = $iconOverrideExports
    RetroBarSettingsExisted = $retroBarSettingsExisted
    RetroBarRun = $runSnapshot
    LanguageBarOptions = $languageBarOptions
    RetroBarInstalled = [bool](Get-RetroBarExe)
    OpenShellInstalled = [bool](Get-OpenShellExe)
}

$meta | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 (Join-Path $backupDir "backup.json")

Write-Host "Backup complete."
if ($PassThru) {
    Write-Output $backupDir
} else {
    Write-Host "Rollback path: $backupDir"
}
