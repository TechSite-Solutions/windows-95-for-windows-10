Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Write-Host "Windows 95 for Windows 10 - status"
Write-Host "=================================="

$os=Get-WindowsInfo
Write-Host ("OS: {0} {1} build {2} ({3})" -f $os.Caption,$os.Version,$os.BuildNumber,$os.Architecture)

$retro=Get-RetroBarExe
$open=Get-OpenShellExe
$retroSettings=Join-Path $env:LOCALAPPDATA "RetroBar\settings.json"
$openKey="HKCU:\Software\OpenShell\StartMenu\Settings"

Write-Host ""
Write-Host ("RetroBar installed: {0}" -f [bool]$retro)
if($retro){Write-Host ("  Path: {0}" -f $retro)}
Write-Host ("RetroBar config:    {0}" -f (Test-Path $retroSettings))

Write-Host ("Open-Shell installed: {0}" -f [bool]$open)
if($open){Write-Host ("  Path: {0}" -f $open)}
Write-Host ("Open-Shell config:    {0}" -f (Test-Path $openKey))

$colors=Get-ItemProperty "HKCU:\Control Panel\Colors"
Write-Host ""
Write-Host ("Desktop color: {0}" -f $colors.Background)
Write-Host ("Active title:  {0}" -f $colors.ActiveTitle)
Write-Host ("Button face:   {0}" -f $colors.ButtonFace)

$expected = ($colors.Background -eq "0 128 128" -and $colors.ActiveTitle -eq "0 0 128" -and $colors.ButtonFace -eq "192 192 192")
Write-Host ("Base Win95 palette active: {0}" -f $expected)
