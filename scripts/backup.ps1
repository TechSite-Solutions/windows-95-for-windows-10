Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = Join-Path $root ("backups\" + $stamp)
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Host "Creating backup in: $backupDir"

$registryExports = [ordered]@{
    "colors.reg"     = "HKCU\Control Panel\Colors"
    "desktop.reg"    = "HKCU\Control Panel\Desktop"
    "openshell.reg"  = "HKCU\Software\OpenShell"
    "run.reg"        = "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
}

foreach ($item in $registryExports.GetEnumerator()) {
    $target = Join-Path $backupDir $item.Key
    & reg.exe export $item.Value $target /y *> $null
}

$retroBarDir = Join-Path $env:LOCALAPPDATA "RetroBar"
$retroBarSettings = Join-Path $retroBarDir "settings.json"
if (Test-Path $retroBarSettings) {
    Copy-Item $retroBarSettings (Join-Path $backupDir "retrobar-settings.json") -Force
}

$meta = [ordered]@{
    CreatedAt    = (Get-Date).ToString("o")
    ComputerName = $env:COMPUTERNAME
    UserName     = $env:USERNAME
    OS           = (Get-CimInstance Win32_OperatingSystem).Caption
    Version      = (Get-CimInstance Win32_OperatingSystem).Version
}

$meta | ConvertTo-Json | Set-Content -Encoding UTF8 (Join-Path $backupDir "backup.json")

Write-Host "Backup complete."
Write-Host "Backup path:"
Write-Host $backupDir
