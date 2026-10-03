param(
    [switch]$ForceReinstall,
    [switch]$NoLaunch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Assert-Windows10
Write-Section "RetroBar"

$existing = Get-RetroBarExe
if ($existing -and -not $ForceReinstall) {
    Write-Host "RetroBar already installed: $existing"
} else {
    $manifest = Get-ComponentManifest
    $component = $manifest.retrobar

    Write-Host "Pinned release: $($component.version)"
    $tempRoot = Join-Path $env:TEMP "Win95ForWin10-RetroBar"
    Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

    $zip = Join-Path $tempRoot ([string]$component.asset)
    Invoke-FileDownload -Uri ([string]$component.url) -Destination $zip
    Assert-FileSha256 -Path $zip -Expected ([string]$component.sha256)
    Expand-Archive -Path $zip -DestinationPath $tempRoot -Force

    $installer = Get-ChildItem $tempRoot -Recurse -File -Filter "*.exe" |
        Where-Object { $_.Name -match "RetroBar.*Installer|RetroBarInstaller" } |
        Select-Object -First 1

    if (-not $installer) {
        throw "RetroBar installer executable was not found in the verified official release archive."
    }

    Write-Host "Running official RetroBar installer..."
    $args = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /TASKS="autostart"'
    $proc = Start-Process -FilePath $installer.FullName -ArgumentList $args -Wait -PassThru

    if ($proc.ExitCode -notin @(0,3010)) {
        throw "RetroBar installer exited with code $($proc.ExitCode)."
    }

    Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

$retroBar = Get-RetroBarExe
if (-not $retroBar) {
    throw "RetroBar installation finished but RetroBar.exe could not be located."
}

Write-Host "RetroBar executable: $retroBar"

if (-not $NoLaunch) {
    & (Join-Path $PSScriptRoot "configure-retrobar.ps1")
}
