param(
    [switch]$ForceReinstall,
    [switch]$NoConfigure
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
    $manifest = Get-ComponentManifest
    $component = $manifest.openshell

    Write-Host "Pinned release: $($component.version)"
    $tempRoot = Join-Path $env:TEMP "Win95ForWin10-OpenShell"
    Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

    $installer = Join-Path $tempRoot ([string]$component.asset)
    Invoke-FileDownload -Uri ([string]$component.url) -Destination $installer
    Assert-FileSha256 -Path $installer -Expected ([string]$component.sha256)

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

if (-not $NoConfigure) {
    & (Join-Path $PSScriptRoot "configure-openshell.ps1")
}
