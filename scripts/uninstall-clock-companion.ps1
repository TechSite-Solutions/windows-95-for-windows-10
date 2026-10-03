Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Write-Section "Removing Windows 95 Clock Companion"

$destDir = Join-Path $env:LOCALAPPDATA "Windows95ForWindows10\Clock"
$pidFile = Join-Path $destDir "companion.pid"

if (Test-Path $pidFile) {
    try {
        $clockPid = [int](Get-Content $pidFile -Raw)
        Stop-Process -Id $clockPid -Force -ErrorAction SilentlyContinue
    } catch {}
}

$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Remove-ItemProperty -Path $runKey -Name "Win95ClockCompanion" -ErrorAction SilentlyContinue
Remove-Item $destDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Clock companion removed."
