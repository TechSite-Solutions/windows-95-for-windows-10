param(
    [switch]$NoLaunch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Write-Section "Configuring RetroBar for Windows 95"

Stop-ProcessIfRunning -Name "RetroBar"

$settingsDir = Join-Path $env:LOCALAPPDATA "RetroBar"
$settingsFile = Join-Path $settingsDir "settings.json"
New-Item -ItemType Directory -Force -Path $settingsDir | Out-Null

$settings = [ordered]@{
    Language                = "System"
    Theme                   = "Windows 95-98"
    ShowInputLanguage       = $false
    ShowClock               = $true
    OverrideClockFormat     = $false
    ShowDesktopButton       = $false
    PeekAtDesktop           = $false
    ShowMultiMon            = $false
    ShowQuickLaunch         = $true
    CollapseNotifyIcons     = $false
    AllowFontSmoothing      = $false
    AllowFontSmoothingMenu  = $false
    UseSoftwareRendering    = $false
    RowCount                = 1
    ShowTaskThumbnails      = $false
    TaskbarScale            = 1.0
    AutoHide                = $false
    LockTaskbar             = $false
    ShowTaskBadges          = $false
    CheckForUpdates         = $true
    ShowExitMenuItem        = $true
    ShowEndTaskButton       = $false
    ShowStartButtonMultiMon = $false
    AutoHideTransparent     = $false
    SlideTaskbarButtons     = $false
    ShowClockSeconds        = $false
    AllowBlurBehind         = $false
}

$settings | ConvertTo-Json -Depth 6 | Set-Content -Path $settingsFile -Encoding UTF8
Write-Host "Wrote: $settingsFile"

$retroBar = Get-RetroBarExe
if (-not $retroBar) {
    Write-Warning "RetroBar.exe was not found. Configuration is ready and will be used after RetroBar is installed."
    return
}

$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-RegistryValue -Path $runKey -Name "RetroBar" -Value ('"{0}"' -f $retroBar) -Type String
Write-Host "RetroBar autostart enabled."

if (-not $NoLaunch) {
    Start-Process -FilePath $retroBar
    Write-Host "RetroBar started."
}
