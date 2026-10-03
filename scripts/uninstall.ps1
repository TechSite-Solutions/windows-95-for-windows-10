param(
    [string]$BackupPath,
    [switch]$KeepRetroBar,
    [switch]$KeepOpenShell
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Write-Section "Windows 95 theme rollback"

Stop-ProcessIfRunning -Name "RetroBar"
Stop-ProcessIfRunning -Name "StartMenu"

if($BackupPath){
    & (Join-Path $PSScriptRoot "restore.ps1") -BackupPath $BackupPath
}else{
    Write-Warning "No backup path supplied. Theme registry values will not be restored automatically."
}

if(-not $KeepRetroBar){
    $entry=Get-UninstallEntries|Where-Object{$_.DisplayName -eq "RetroBar"}|Select-Object -First 1
    if($entry -and $entry.UninstallString){
        Write-Host "RetroBar is installed. Remove it from Apps & Features or run its official uninstaller."
    }
    Remove-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "RetroBar" -ErrorAction SilentlyContinue
}

if(-not $KeepOpenShell){
    $entry=Get-UninstallEntries|Where-Object{$_.DisplayName -match "^Open-Shell"}|Select-Object -First 1
    if($entry){
        Write-Host "Open-Shell is installed. Remove it from Apps & Features after restoring settings."
    }
}

Write-Host ""
Write-Host "Rollback stage complete."
Write-Host "Sign out and sign back in after removing third-party components."
