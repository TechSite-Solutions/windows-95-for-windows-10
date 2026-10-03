param(
    [switch]$ForceReinstall,
    [switch]$NoLaunch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Assert-Windows10
Write-Section "Open-Shell"

$existing = Get-OpenShellExe
if ($existing -and -not $ForceReinstall) {
    Write-Host "Open-Shell already installed: $existing"
} else {
    $asset = Get-LatestGitHubAsset -Repository "Open-Shell/Open-Shell-Menu" -AssetPattern "^OpenShellSetup_.*\.exe$"
    Write-Host "Stable release: $($asset.Tag)"

    $tempRoot = Join-Path $env:TEMP "Win95ForWin10-OpenShell"
    Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

    $installer = Join-Path $tempRoot $asset.Name
    Invoke-FileDownload -Uri $asset.DownloadUrl -Destination $installer

    Write-Host "Installing Open-Shell Start Menu. Windows may show a UAC prompt."
    $args = '/qn ADDLOCAL=OpenShell,StartMenu'
    $proc = Start-Process -FilePath $installer -ArgumentList $args -Verb RunAs -Wait -PassThru

    if ($proc.ExitCode -notin @(0,3010,1641)) {
        throw "Open-Shell installer exited with code $($proc.ExitCode)."
    }

    Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

$openShell = Get-OpenShellExe
if (-not $openShell) {
    throw "Open-Shell installation finished but StartMenu.exe could not be located."
}

Write-Host "Open-Shell executable: $openShell"
& (Join-Path $PSScriptRoot "configure-openshell.ps1") -NoLaunch:$NoLaunch
