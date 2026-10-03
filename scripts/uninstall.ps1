param(
    [string]$BackupPath,
    [switch]$KeepThirdParty,
    [switch]$RemoveImportedAssets,
    [switch]$NoLaunch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

$root = Get-ProjectRoot
$stateFile = Join-Path $root "state\last-install.json"
$state = $null

if (Test-Path $stateFile) {
    $state = Get-Content $stateFile -Raw | ConvertFrom-Json
}

if (-not $BackupPath) {
    if ($state -and $state.BackupPath -and (Test-Path $state.BackupPath)) {
        $BackupPath = [string]$state.BackupPath
    } else {
        $latest = Get-ChildItem (Join-Path $root "backups") -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending |
            Select-Object -First 1
        if ($latest) {
            $BackupPath = $latest.FullName
            Write-Warning "Install state was unavailable. Using latest backup: $BackupPath"
        }
    }
}

if (-not $BackupPath -or -not (Test-Path $BackupPath)) {
    throw "No valid rollback backup was found. Use -BackupPath to select one explicitly."
}

Write-Host ""
Write-Host "Windows 95 for Windows 10 - rollback"
Write-Host "===================================="
Write-Host "Backup: $BackupPath"

$clockUninstall = Join-Path $PSScriptRoot "uninstall-clock-companion.ps1"
if (Test-Path $clockUninstall) {
    & $clockUninstall
}

& (Join-Path $PSScriptRoot "restore.ps1") -BackupPath $BackupPath -NoLaunch

function Invoke-UninstallEntry {
    param(
        [Parameter(Mandatory=$true)]$Entry,
        [ValidateSet("RetroBar","OpenShell")][string]$Kind
    )

    $command = $null
    $quietUninstall = Get-ObjectPropertyValue -Object $Entry -Name "QuietUninstallString"
    $uninstall = Get-ObjectPropertyValue -Object $Entry -Name "UninstallString"

    if ($quietUninstall) {
        $command = [string]$quietUninstall
    } elseif ($uninstall) {
        $command = [string]$uninstall
    }

    if (-not $command) {
        Write-Warning "No uninstall command found for $Kind."
        return
    }

    if ($command -match '(?i)msiexec(?:\.exe)?\s+.*?(\{[0-9a-f-]+\})') {
        $productCode = $Matches[1]
        Write-Host "Uninstalling $Kind via MSI..."
        $proc = Start-Process msiexec.exe -Verb RunAs -Wait -PassThru -ArgumentList @(
            "/x", $productCode, "/qn", "/norestart"
        )
        if ($proc.ExitCode -notin @(0,1605,1614,3010)) {
            Write-Warning "$Kind MSI uninstall returned $($proc.ExitCode)."
        }
        return
    }

    $exe = $null
    $args = ""
    if ($command -match '^\s*"([^"]+)"\s*(.*)$') {
        $exe = $Matches[1]
        $args = $Matches[2]
    } elseif ($command -match '^\s*(\S+)\s*(.*)$') {
        $exe = $Matches[1]
        $args = $Matches[2]
    }

    if (-not $exe -or -not (Test-Path $exe)) {
        Write-Warning "Could not resolve uninstall executable for $Kind."
        return
    }

    if ($Kind -eq "RetroBar" -and $args -notmatch '(?i)verysilent|silent') {
        $args = ($args + ' /VERYSILENT /SUPPRESSMSGBOXES /NORESTART').Trim()
    }

    Write-Host "Uninstalling $Kind..."
    try {
        $proc = Start-Process -FilePath $exe -ArgumentList $args -Verb RunAs -Wait -PassThru
        if ($proc.ExitCode -notin @(0,3010)) {
            Write-Warning "$Kind uninstall returned $($proc.ExitCode)."
        }
    } catch {
        Write-Warning "$Kind uninstall failed or elevation was cancelled: $($_.Exception.Message)"
    }
}

if (-not $KeepThirdParty -and $state) {
    if ($state.RetroBarInstalledByProject) {
        Stop-ProcessIfRunning -Name "RetroBar"
        $entry = Get-UninstallEntries | Where-Object {
            (Get-ObjectPropertyValue -Object $_ -Name "DisplayName") -eq "RetroBar"
        } | Select-Object -First 1
        if ($entry) { Invoke-UninstallEntry -Entry $entry -Kind "RetroBar" }
    }

    if ($state.OpenShellInstalledByProject) {
        Stop-ProcessIfRunning -Name "StartMenu"
        $entry = Get-UninstallEntries | Where-Object {
            (Get-ObjectPropertyValue -Object $_ -Name "DisplayName") -match "^Open-Shell"
        } | Select-Object -First 1
        if ($entry) { Invoke-UninstallEntry -Entry $entry -Kind "OpenShell" }
    }
}

if ($RemoveImportedAssets) {
    Remove-Item (Join-Path $env:LOCALAPPDATA "Windows95ForWindows10") -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Removed locally imported assets."
}

if (-not $NoLaunch) {
    if ($state -and $state.RetroBarPreExisting) {
        $retroBar = Get-RetroBarExe
        if ($retroBar) { Start-Process $retroBar }
    }
    if ($state -and $state.OpenShellPreExisting) {
        $openShell = Get-OpenShellExe
        if ($openShell) { Start-Process $openShell }
    }
}

Remove-Item $stateFile -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Rollback complete."
Write-Host "Sign out and sign back in to fully refresh Windows."
