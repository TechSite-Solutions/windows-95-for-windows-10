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
    ShowInputLanguage       = $true
    ShowClock               = $true
    OverrideClockFormat     = $false
    ShowDesktopButton       = $false
    PeekAtDesktop           = $false
    ShowMultiMon            = $false
    ShowQuickLaunch         = $true
    QuickLaunchPath         = "%appdata%\Microsoft\Internet Explorer\Quick Launch"
    CollapseNotifyIcons     = $false
    AllowFontSmoothing      = $false
    AllowFontSmoothingMenu  = $false
    UseSoftwareRendering    = $false
    Edge                    = 3
    RowCount                = 1
    RowLimit                = 5
    TaskbarWidth            = 1
    TaskbarWidthLimit       = 7
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
    ClockClickAction        = 0
    AllowBlurBehind         = $false
}

$json = $settings | ConvertTo-Json -Depth 6
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($settingsFile, $json, $utf8NoBom)
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
