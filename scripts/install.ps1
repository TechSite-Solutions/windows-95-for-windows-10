param(
    [switch]$SkipRetroBar,
    [switch]$SkipOpenShell,
    [switch]$SkipMetrics,
    [switch]$SkipDesktopIcons,
    [switch]$SkipRestorePoint,
    [switch]$NoLaunch,
    [switch]$AllowUnsupportedWindows,
    [switch]$DryRun,
    [string]$ImportAssetsFrom
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Assert-Windows10 -AllowUnsupportedWindows:$AllowUnsupportedWindows

$root = Get-ProjectRoot
$stateDir = Join-Path $root "state"
$stateFile = Join-Path $stateDir "last-install.json"

if ($DryRun) {
    $manifest = Get-ComponentManifest
    Write-Host ""
    Write-Host "Windows 95 for Windows 10 - dry run"
    Write-Host "=================================="
    Write-Host "No settings or files will be changed."
    Write-Host ""
    Write-Host ("Target OS: {0}" -f (Get-WindowsInfo).Caption)
    Write-Host ("Base palette: apply")
    Write-Host ("Classic metrics: {0}" -f (-not $SkipMetrics))
    Write-Host ("Classic desktop icons/labels: {0}" -f (-not $SkipDesktopIcons))
    Write-Host ("RetroBar: {0}" -f $(if ($SkipRetroBar) { "skip" } else { "install/configure " + $manifest.retrobar.version }))
    Write-Host ("Open-Shell: {0}" -f $(if ($SkipOpenShell) { "skip" } else { "install/configure " + $manifest.openshell.version }))
    Write-Host ("Restore point attempt: {0}" -f (-not $SkipRestorePoint))
    Write-Host ("Local assets: {0}" -f $(if ($ImportAssetsFrom) { $ImportAssetsFrom } else { "none" }))
    Write-Host ""
    Write-Host "Run again without -DryRun to apply."
    return
}

New-Item -ItemType Directory -Force -Path $stateDir | Out-Null

Write-Host ""
Write-Host "Windows 95 for Windows 10"
Write-Host "========================="
Write-Host "Safe installer / reversible profile"
Write-Host ""

$retroBarBefore = [bool](Get-RetroBarExe)
$openShellBefore = [bool](Get-OpenShellExe)
$backupPath = $null

try {
    $backupPath = & (Join-Path $PSScriptRoot "backup.ps1") -PassThru
    if (-not $backupPath) { throw "Backup did not return a path." }

    $state = [ordered]@{
        SchemaVersion = 2
        StartedAt = (Get-Date).ToString("o")
        BackupPath = [string]$backupPath
        RetroBarPreExisting = $retroBarBefore
        OpenShellPreExisting = $openShellBefore
        RetroBarInstalledByProject = $false
        OpenShellInstalledByProject = $false
        ImportedAssets = [bool]$ImportAssetsFrom
        Completed = $false
    }
    $state | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 $stateFile

    if (-not $SkipRestorePoint) {
        $restoreScript = Join-Path $PSScriptRoot "create-restore-point.ps1"
        if (Get-IsAdministrator) {
            & $restoreScript
        } else {
            try {
                $proc = Start-Process powershell.exe -Verb RunAs -Wait -PassThru -ArgumentList @(
                    "-NoLogo","-NoProfile","-ExecutionPolicy","Bypass","-File",('"{0}"' -f $restoreScript)
                )
                if ($proc.ExitCode -ne 0) { Write-Warning "Elevated restore-point helper returned $($proc.ExitCode)." }
            } catch {
                Write-Warning "Restore-point elevation was cancelled or failed. Local rollback backup still exists."
            }
        }
    }

    & (Join-Path $PSScriptRoot "apply-base-theme.ps1") -AllowUnsupportedWindows:$AllowUnsupportedWindows

    if (-not $SkipMetrics) {
        & (Join-Path $PSScriptRoot "apply-classic-metrics.ps1") -AllowUnsupportedWindows:$AllowUnsupportedWindows
    }

    if (-not $SkipDesktopIcons) {
        & (Join-Path $PSScriptRoot "configure-desktop-icons.ps1")
    }

    if (-not $SkipRetroBar) {
        & (Join-Path $PSScriptRoot "install-retrobar.ps1") -NoLaunch
        & (Join-Path $PSScriptRoot "configure-retrobar.ps1") -NoLaunch
        $state.RetroBarInstalledByProject = (-not $retroBarBefore) -and [bool](Get-RetroBarExe)
    }

    if (-not $SkipOpenShell) {
        & (Join-Path $PSScriptRoot "install-openshell.ps1") -NoConfigure
        & (Join-Path $PSScriptRoot "configure-openshell.ps1") -NoLaunch
        $state.OpenShellInstalledByProject = (-not $openShellBefore) -and [bool](Get-OpenShellExe)
    }

    if ($ImportAssetsFrom) {
        & (Join-Path $PSScriptRoot "import-user-assets.ps1") -SourceDirectory $ImportAssetsFrom -ApplyCursors -ApplySounds -ApplyIcons
    }

    $state.Completed = $true
    $state.CompletedAt = (Get-Date).ToString("o")
    $state | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 $stateFile

    if (-not $NoLaunch) {
        if (-not $SkipRetroBar) {
            $retroBar = Get-RetroBarExe
            if ($retroBar) { Stop-ProcessIfRunning -Name "RetroBar"; Start-Process $retroBar }
        }
        if (-not $SkipOpenShell) {
            $openShell = Get-OpenShellExe
            if ($openShell) { Stop-ProcessIfRunning -Name "StartMenu"; Start-Process $openShell }
        }
    }

    Write-Section "Validation"
    $verifyScript = Join-Path $PSScriptRoot "verify.ps1"
    $verify = Start-Process powershell.exe -Wait -PassThru -ArgumentList @(
        "-NoLogo","-NoProfile","-ExecutionPolicy","Bypass","-File",('"{0}"' -f $verifyScript)
    )
    if ($verify.ExitCode -ne 0) {
        Write-Warning "Verification reported a mismatch. Run .\scripts\verify.ps1 for details."
    }

    Write-Host ""
    Write-Host "Installation complete."
    Write-Host "Backup: $backupPath"
    Write-Host "For the most authentic result, sign out and sign back in."
    Write-Host "Rollback: .\scripts\uninstall.ps1"
}
catch {
    Write-Error $_
    if ($backupPath -and (Test-Path $backupPath)) {
        Write-Warning "Installation failed. Restoring the appearance backup automatically..."
        try {
            & (Join-Path $PSScriptRoot "restore.ps1") -BackupPath $backupPath -NoLaunch
        } catch {
            Write-Warning "Automatic rollback also failed: $($_.Exception.Message)"
            Write-Warning "Manual backup path: $backupPath"
        }
    }
    throw
}
