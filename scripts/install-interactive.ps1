Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "Windows 95 for Windows 10"
Write-Host "Interactive installer"
Write-Host "=========================="
Write-Host ""
Write-Host "1 - Recommended full core setup"
Write-Host "2 - Full core setup + import local-assets"
Write-Host "3 - Base appearance only (no RetroBar/Open-Shell)"
Write-Host "4 - Custom"
Write-Host "5 - Dry run"
Write-Host ""

$choice = Read-Host "Choose 1-5"
$params = @{}

switch ($choice) {
    "1" {
    }
    "2" {
        $defaultAssets = Join-Path (Split-Path -Parent $PSScriptRoot) "local-assets"
        $params.ImportAssetsFrom = $defaultAssets
    }
    "3" {
        $params.SkipRetroBar = $true
        $params.SkipOpenShell = $true
    }
    "4" {
        if ((Read-Host "Install/configure RetroBar? [Y/n]") -match '^[Nn]') {
            $params.SkipRetroBar = $true
        }
        if ((Read-Host "Install/configure Open-Shell? [Y/n]") -match '^[Nn]') {
            $params.SkipOpenShell = $true
        }
        if ((Read-Host "Apply full Windows 95 shell profile (light system UI, teal desktop, classic Explorer/Control Panel)? [Y/n]") -match '^[Nn]') {
            $params.SkipFullShell = $true
        }
        if ((Read-Host "Apply classic WindowMetrics? [Y/n]") -match '^[Nn]') {
            $params.SkipMetrics = $true
        }
        if ((Read-Host "Show classic desktop entries/labels? [Y/n]") -match '^[Nn]') {
            $params.SkipDesktopIcons = $true
        }
        if ((Read-Host "Attempt a System Restore point? [Y/n]") -match '^[Nn]') {
            $params.SkipRestorePoint = $true
        }

        $assetPath = Read-Host "Optional user-owned asset directory (blank = none)"
        if ($assetPath) {
            $params.ImportAssetsFrom = $assetPath
        }
    }
    "5" {
        $params.DryRun = $true
    }
    default {
        throw "Unknown choice '$choice'."
    }
}

Write-Host ""
& (Join-Path $PSScriptRoot "install.ps1") @params
