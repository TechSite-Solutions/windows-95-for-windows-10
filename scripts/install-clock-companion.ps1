param(
    [ValidateSet("Authentic","Enhanced")]
    [string]$Mode = "Enhanced",

    [ValidateRange(150,5000)]
    [int]$HoverDelayMs = 500,

    [switch]$NoLaunch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Assert-Windows10
Write-Section "Windows 95 Clock Companion"

$root = Get-ProjectRoot
$source = Join-Path $root "components\clock\Win95ClockCompanion.ps1"
if (-not (Test-Path $source)) { throw "Missing clock companion source: $source" }

$destDir = Join-Path $env:LOCALAPPDATA "Windows95ForWindows10\Clock"
$dest = Join-Path $destDir "Win95ClockCompanion.ps1"
$configPath = Join-Path $destDir "clock-config.json"
$pidFile = Join-Path $destDir "companion.pid"

if (Test-Path $pidFile) {
    try {
        $oldPid = [int](Get-Content $pidFile -Raw)
        Stop-Process -Id $oldPid -Force -ErrorAction SilentlyContinue
    } catch {}
}

New-Item -ItemType Directory -Force -Path $destDir | Out-Null
Copy-Item $source $dest -Force

$config = [ordered]@{
    Mode = $Mode
    HoverDelayMs = $HoverDelayMs
    CloseDelayMs = 350
    ClockHitPixels = 76
}
$json = $config | ConvertTo-Json
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($configPath,$json,$utf8NoBom)

$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$command = 'powershell.exe -NoLogo -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "{0}" -ConfigPath "{1}"' -f $dest,$configPath
Set-RegistryValue -Path $runKey -Name "Win95ClockCompanion" -Value $command -Type String

Write-Host "Clock companion installed."
Write-Host ("Mode: {0}" -f $Mode)
Write-Host ("Hover delay: {0} ms" -f $HoverDelayMs)

if (-not $NoLaunch) {
    Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @(
        "-NoLogo","-NoProfile","-ExecutionPolicy","Bypass",
        "-File",('"{0}"' -f $dest),
        "-ConfigPath",('"{0}"' -f $configPath)
    )
    Write-Host "Clock companion started."
}
