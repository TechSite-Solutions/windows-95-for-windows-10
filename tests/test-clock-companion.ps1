Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$script = Join-Path $root "components\clock\Win95ClockCompanion.ps1"
if (-not (Test-Path $script)) { throw "Clock companion script missing." }

$tokens=$null
$errors=$null
[void][System.Management.Automation.Language.Parser]::ParseFile($script,[ref]$tokens,[ref]$errors)
if ($errors.Count -gt 0) { throw ($errors -join "; ") }

$source = Get-Content $script -Raw
foreach ($needle in @("Authentic","Enhanced","ClockHitPixels","Win95 Clock Companion")) {
    if ($source -notmatch [regex]::Escape($needle)) {
        throw "Clock companion missing expected token: $needle"
    }
}

Write-Host "Clock companion static test passed."
