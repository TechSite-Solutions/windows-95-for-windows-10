Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Write-Host "Windows 95 for Windows 10 - status"
Write-Host "=================================="

$os = Get-WindowsInfo
Write-Host ("OS: {0} {1} build {2} ({3})" -f $os.Caption,$os.Version,$os.BuildNumber,$os.Architecture)

$manifest = Get-ComponentManifest
Write-Host ("Pinned RetroBar:   {0}" -f $manifest.retrobar.version)
Write-Host ("Pinned Open-Shell: {0}" -f $manifest.openshell.version)

$retro = Get-RetroBarExe
$open = Get-OpenShellExe
$retroSettings = Join-Path $env:LOCALAPPDATA "RetroBar\settings.json"
$openKey = "HKCU:\Software\OpenShell\StartMenu\Settings"
$classicExplorerExe = Get-ClassicExplorerSettingsExe
$classicExplorerKey = "HKCU:\Software\OpenShell\ClassicExplorer\Settings"

Write-Host ""
Write-Host ("RetroBar installed: {0}" -f [bool]$retro)
if ($retro) { Write-Host ("  Path: {0}" -f $retro) }

if (Test-Path $retroSettings) {
    try {
        $retroConfig = Get-Content $retroSettings -Raw | ConvertFrom-Json
        Write-Host ("  Theme: {0}" -f $retroConfig.Theme)
        Write-Host ("  Quick Launch: {0}" -f $retroConfig.ShowQuickLaunch)
        Write-Host ("  Clock: {0}" -f $retroConfig.ShowClock)
    } catch {
        Write-Warning "RetroBar settings.json exists but could not be parsed."
    }
} else {
    Write-Host "  Config: missing"
}

Write-Host ""
Write-Host ("Open-Shell installed: {0}" -f [bool]$open)
if ($open) { Write-Host ("  Path: {0}" -f $open) }
Write-Host ("Classic Explorer installed: {0}" -f [bool]$classicExplorerExe)
if ($classicExplorerExe) { Write-Host ("  Path: {0}" -f $classicExplorerExe) }

if (Test-Path $openKey) {
    $props = Get-ItemProperty $openKey
    Write-Host ("  MenuStyle: {0}" -f $props.MenuStyle)
    Write-Host ("  WinKey: {0}" -f $props.WinKey)
    Write-Host ("  AlignToWorkArea: {0}" -f $props.AlignToWorkArea)
    Write-Host ("  Open-Shell Start button enabled: {0}" -f $props.EnableStartButton)
} else {
    Write-Host "  Config: missing"
}


if (Test-Path $classicExplorerKey) {
    $ce = Get-ItemProperty $classicExplorerKey
    Write-Host ("  Classic Explorer TreeStyle: {0}" -f $ce.TreeStyle)
    Write-Host ("  Classic Explorer breadcrumbs disabled: {0}" -f $ce.DisableBreadcrumbs)
    Write-Host ("  Classic Explorer status bar: {0}" -f $ce.ShowStatusBar)
}

$personalize = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
if (Test-Path $personalize) {
    $theme = Get-ItemProperty $personalize
    Write-Host ""
    Write-Host ("Windows app light mode: {0}" -f $theme.AppsUseLightTheme)
    Write-Host ("Windows system light mode: {0}" -f $theme.SystemUsesLightTheme)
    Write-Host ("Transparency enabled: {0}" -f $theme.EnableTransparency)
}

$colors = Get-ItemProperty "HKCU:\Control Panel\Colors"
Write-Host ""
Write-Host ("Desktop color: {0}" -f $colors.Background)
Write-Host ("Active title:  {0}" -f $colors.ActiveTitle)
Write-Host ("Button face:   {0}" -f $colors.ButtonFace)

$expectedPalette = (
    $colors.Background -eq "0 128 128" -and
    $colors.ActiveTitle -eq "0 0 128" -and
    $colors.ButtonFace -eq "192 192 192"
)
Write-Host ("Base Win95 palette active: {0}" -f $expectedPalette)

$metricsKey = "HKCU:\Control Panel\Desktop\WindowMetrics"
if (Test-Path $metricsKey) {
    $metrics = Get-ItemProperty $metricsKey
    Write-Host ("Classic CaptionHeight: {0}" -f $metrics.CaptionHeight)
    Write-Host ("Classic ScrollWidth:   {0}" -f $metrics.ScrollWidth)
}

$stateFile = Join-Path (Get-ProjectRoot) "state\last-install.json"
Write-Host ""
Write-Host ("Install state exists: {0}" -f (Test-Path $stateFile))
if (Test-Path $stateFile) {
    $state = Get-Content $stateFile -Raw | ConvertFrom-Json
    Write-Host ("  Completed: {0}" -f $state.Completed)
    Write-Host ("  Backup: {0}" -f $state.BackupPath)
    Write-Host ("  RetroBar installed by project: {0}" -f $state.RetroBarInstalledByProject)
    Write-Host ("  Open-Shell installed by project: {0}" -f $state.OpenShellInstalledByProject)
}

Write-Host ""
Write-Host "Strict check: .\scripts\verify.ps1"
