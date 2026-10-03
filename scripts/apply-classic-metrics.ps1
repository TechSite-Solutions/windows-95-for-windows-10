param(
    [switch]$AllowUnsupportedWindows
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Assert-Windows10 -AllowUnsupportedWindows:$AllowUnsupportedWindows
Write-Section "Applying classic Windows metrics"

$key = "HKCU:\Control Panel\Desktop\WindowMetrics"

# Classic-like 96-DPI metrics. Windows 10 may ignore some values for DWM-rendered UI,
# but traditional Win32 applications and shell surfaces can still honor several of them.
$metrics = [ordered]@{
    BorderWidth         = "-15"
    CaptionHeight       = "-270"
    CaptionWidth        = "-270"
    MenuHeight          = "-270"
    MenuWidth           = "-270"
    ScrollHeight        = "-240"
    ScrollWidth         = "-240"
    SmCaptionHeight     = "-210"
    SmCaptionWidth      = "-210"
    PaddedBorderWidth   = "0"
    IconSpacing         = "-1125"
    IconVerticalSpacing = "-1125"
    "Shell Icon Size"   = "32"
    "Shell Small Icon Size" = "16"
}

foreach ($item in $metrics.GetEnumerator()) {
    Set-RegistryValue -Path $key -Name $item.Key -Value $item.Value -Type String
    Write-Host ("{0,-24} {1}" -f $item.Key, $item.Value)
}

Write-Host "Classic metrics applied. Sign out/in is required for full effect."
