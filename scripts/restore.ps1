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
$schema = 1
if ($meta.PSObject.Properties.Name -contains "SchemaVersion") {
    $schema = [int]$meta.SchemaVersion
}

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

if ($schema -ge 2) {
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
}

if ($schema -ge 4) {
    $fullShellKeys = @(
        @{ Name = "OpenShellClassicExplorer"; File = "openshell-classic-explorer.reg"; Path = "HKCU:\Software\OpenShell\ClassicExplorer" },
        @{ Name = "ThemePersonalize"; File = "theme-personalize.reg"; Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" },
        @{ Name = "Dwm"; File = "dwm.reg"; Path = "HKCU:\Software\Microsoft\Windows\DWM" },
        @{ Name = "ExplorerAdvanced"; File = "explorer-advanced.reg"; Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" },
        @{ Name = "ExplorerRibbon"; File = "explorer-ribbon.reg"; Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Ribbon" },
        @{ Name = "ControlPanelView"; File = "control-panel-view.reg"; Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" }
    )

    foreach ($item in $fullShellKeys) {
        $property = $meta.Exports.PSObject.Properties[$item.Name]
        $existed = $property -and [bool]$property.Value
        if ($existed) {
            Import-RegIfPresent $item.File
        } else {
            Remove-Item $item.Path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

if ($schema -ge 3 -and ($meta.PSObject.Properties.Name -contains "IconOverrideExports")) {
    foreach ($property in $meta.IconOverrideExports.PSObject.Properties) {
        $guid = $property.Name
        $existed = [bool]$property.Value
        $safe = $guid.Trim("{}")

        if ($existed) {
            Import-RegIfPresent ("desktop-icon-override-" + $safe + ".reg")
        } else {
            Remove-Item "HKCU:\Software\Classes\CLSID\$guid" -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

$retroBarSettings = Join-Path $env:LOCALAPPDATA "RetroBar\settings.json"
if ($meta.PSObject.Properties.Name -contains "RetroBarSettingsExisted") {
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
}

$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
if ($meta.PSObject.Properties.Name -contains "RetroBarRun") {
    if ($meta.RetroBarRun.Exists) {
        Set-RegistryValue -Path $runKey -Name "RetroBar" -Value ([string]$meta.RetroBarRun.Value) -Type String
    } else {
        Remove-ItemProperty -Path $runKey -Name "RetroBar" -ErrorAction SilentlyContinue
    }
}

Write-Host "Registry and local settings restored."

if (-not $NoLaunch) {
    if (($meta.PSObject.Properties.Name -contains "RetroBarInstalled") -and $meta.RetroBarInstalled) {
        $retroBar = Get-RetroBarExe
        if ($retroBar) { Start-Process $retroBar }
    }

    if (($meta.PSObject.Properties.Name -contains "OpenShellInstalled") -and $meta.OpenShellInstalled) {
        $openShell = Get-OpenShellExe
        if ($openShell) { Start-Process $openShell }
    }
}

Write-Host "Sign out and sign back in for a complete shell refresh."
