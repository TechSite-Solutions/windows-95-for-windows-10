Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Windows 95 for Windows 10 - system check"
Write-Host "========================================="

if ($env:OS -ne "Windows_NT") {
    throw "This project supports Windows only."
}

$os = Get-CimInstance Win32_OperatingSystem
Write-Host ("OS: {0}" -f $os.Caption)
Write-Host ("Version: {0}" -f $os.Version)
Write-Host ("Build: {0}" -f $os.BuildNumber)
Write-Host ("Architecture: {0}" -f $os.OSArchitecture)
Write-Host ("PowerShell: {0}" -f $PSVersionTable.PSVersion)

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
Write-Host ("Administrator: {0}" -f $isAdmin)

if ($os.Caption -notmatch "Windows 10") {
    Write-Warning "Primary supported target is Windows 10. Continue only if you understand this configuration is not validated for your OS."
}

$colorsKey = "HKCU:\Control Panel\Colors"
if (-not (Test-Path $colorsKey)) {
    throw "Cannot access $colorsKey"
}

Write-Host "Registry access: OK"
Write-Host "System check complete."
