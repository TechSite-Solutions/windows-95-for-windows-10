Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = Join-Path $root ("backups\" + $stamp)
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Host "Creating backup in: $backupDir"

reg.exe export "HKCU\Control Panel\Colors" (Join-Path $backupDir "colors.reg") /y | Out-Null
reg.exe export "HKCU\Control Panel\Desktop" (Join-Path $backupDir "desktop.reg") /y | Out-Null

$meta = [ordered]@{
    CreatedAt = (Get-Date).ToString("o")
    ComputerName = $env:COMPUTERNAME
    UserName = $env:USERNAME
    OS = (Get-CimInstance Win32_OperatingSystem).Caption
    Version = (Get-CimInstance Win32_OperatingSystem).Version
}

$meta | ConvertTo-Json | Set-Content -Encoding UTF8 (Join-Path $backupDir "backup.json")

Write-Host "Backup complete."
Write-Host "Keep this path for rollback:"
Write-Host $backupDir
