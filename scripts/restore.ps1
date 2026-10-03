param(
    [Parameter(Mandatory=$true)]
    [string]$BackupPath,

    [switch]$NoLaunch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

$resolved = (Resolve-Path $BackupPath).Path
$metaPath = Join-Path $resolved "backup.json"
if (-not (Test-Path $metaPath)) {
    throw "Missing backup.json in '$resolved'."
}

$meta = Get-Content $metaPath -Raw | ConvertFrom-Json

Write-Section "Restoring pre-theme state"
Stop-ProcessIfRunning -Name "RetroBar"
Stop-ProcessIfRunning -Name "StartMenu"

function Import-RegIfPresent {
    param([string]$FileName)

    $file = Join-Path $resolved $FileName
    if (Test-Path $file) {
        & reg.exe import $file | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to import $file"
        }
        Write-Host "Restored: $FileName"
    }
}

Import-RegIfPresent "colors.reg"
Import-RegIfPresent "desktop.reg"
Import-RegIfPresent "cursors.reg"
Import-RegIfPresent "app-events.reg"

if ($meta.Exports.OpenShellStartMenu) {
    Import-RegIfPresent "openshell-startmenu.reg"
} else {
    Remove-Item "HKCU:\Software\OpenShell\StartMenu" -Recurse -Force -ErrorAction SilentlyContinue
}

if ($meta.Exports.HideDesktopNew) {
    Import-RegIfPresent "desktop-icons-new.reg"
} else {
    Remove-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Recurse -Force -ErrorAction SilentlyContinue
}

if ($meta.Exports.HideDesktopClassic) {
    Import-RegIfPresent "desktop-icons-classic.reg"
} else {
    Remove-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Recurse -Force -ErrorAction SilentlyContinue
}

foreach ($property in $meta.DesktopLabelExports.PSObject.Properties) {
    $guid = $property.Name
    $existed = [bool]$property.Value
    $safe = $guid.Trim("{}")

    if ($existed) {
        Import-RegIfPresent ("desktop-label-" + $safe + ".reg")
    } else {
        Remove-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\$guid" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$retroBarSettings = Join-Path $env:LOCALAPPDATA "RetroBar\settings.json"
if ($meta.RetroBarSettingsExisted) {
    $savedSettings = Join-Path $resolved "retrobar-settings.json"
    if (Test-Path $savedSettings) {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $retroBarSettings) | Out-Null
        Copy-Item $savedSettings $retroBarSettings -Force
        Write-Host "Restored RetroBar settings."
    }
} else {
    Remove-Item $retroBarSettings -Force -ErrorAction SilentlyContinue
}

$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
if ($meta.RetroBarRun.Exists) {
    Set-RegistryValue -Path $runKey -Name "RetroBar" -Value ([string]$meta.RetroBarRun.Value) -Type String
} else {
    Remove-ItemProperty -Path $runKey -Name "RetroBar" -ErrorAction SilentlyContinue
}

Write-Host "Registry and local settings restored."

if (-not $NoLaunch) {
    if ($meta.RetroBarInstalled) {
        $retroBar = Get-RetroBarExe
        if ($retroBar) { Start-Process $retroBar }
    }

    if ($meta.OpenShellInstalled) {
        $openShell = Get-OpenShellExe
        if ($openShell) { Start-Process $openShell }
    }
}

Write-Host "Sign out and sign back in for a complete shell refresh."
