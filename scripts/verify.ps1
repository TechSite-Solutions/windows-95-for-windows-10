param(
    [switch]$Quiet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

$failures = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

function Test-ExpectedRegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        $Expected,
        [switch]$WarningOnly
    )
    try {
        $actual = Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction Stop
        if ("$actual" -ne "$Expected") {
            $message = "$Path :: $Name expected '$Expected', got '$actual'"
            if ($WarningOnly) { $warnings.Add($message) } else { $failures.Add($message) }
        }
    } catch {
        $message = "$Path :: $Name is missing"
        if ($WarningOnly) { $warnings.Add($message) } else { $failures.Add($message) }
    }
}

if (-not $Quiet) { Write-Section "Verification" }

Test-ExpectedRegistryValue -Path "HKCU:\Control Panel\Colors" -Name "Background" -Expected "0 128 128"
Test-ExpectedRegistryValue -Path "HKCU:\Control Panel\Colors" -Name "ButtonFace" -Expected "192 192 192"
Test-ExpectedRegistryValue -Path "HKCU:\Control Panel\Colors" -Name "ActiveTitle" -Expected "0 0 128"

Test-ExpectedRegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Expected 1
Test-ExpectedRegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Expected 1
Test-ExpectedRegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Expected 0
Test-ExpectedRegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AlwaysShowMenus" -Expected 1
Test-ExpectedRegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Expected 1

$retroBar = Get-RetroBarExe
if (-not $retroBar) {
    $warnings.Add("RetroBar is not installed.")
} else {
    $settingsFile = Join-Path $env:LOCALAPPDATA "RetroBar\settings.json"
    if (Test-Path $settingsFile) {
        try {
            $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
            if ($settings.Theme -ne "Windows 95-98") {
                $failures.Add("RetroBar Theme is '$($settings.Theme)', expected 'Windows 95-98'.")
            }
        } catch {
            $failures.Add("RetroBar settings.json could not be parsed.")
        }
    } else {
        $failures.Add("RetroBar settings.json is missing.")
    }
}

$openShell = Get-OpenShellExe
if (-not $openShell) {
    $warnings.Add("Open-Shell is not installed.")
} else {
    $key = "HKCU:\Software\OpenShell\StartMenu\Settings"
    Test-ExpectedRegistryValue -Path $key -Name "MenuStyle" -Expected 0
    Test-ExpectedRegistryValue -Path $key -Name "WinKey" -Expected 1
    Test-ExpectedRegistryValue -Path $key -Name "SearchBox" -Expected 0
    Test-ExpectedRegistryValue -Path $key -Name "AlignToWorkArea" -Expected 1
    Test-ExpectedRegistryValue -Path $key -Name "EnableStartButton" -Expected 0

    $classicExplorer = Get-ClassicExplorerSettingsExe
    if (-not $classicExplorer) {
        $failures.Add("Open-Shell Classic Explorer component is not installed.")
    } else {
        $classicKey = "HKCU:\Software\OpenShell\ClassicExplorer\Settings"
        Test-ExpectedRegistryValue -Path $classicKey -Name "TreeStyle" -Expected 0
        Test-ExpectedRegistryValue -Path $classicKey -Name "DisableBreadcrumbs" -Expected 1
        Test-ExpectedRegistryValue -Path $classicKey -Name "HideSearch" -Expected 1
        Test-ExpectedRegistryValue -Path $classicKey -Name "ShowStatusBar" -Expected 1
    }
}

if (-not $Quiet) {
    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "Warnings:"
        $warnings | ForEach-Object { Write-Warning $_ }
    }

    if ($failures.Count -eq 0) {
        Write-Host ""
        Write-Host "PASS: configured settings are consistent."
    } else {
        Write-Host ""
        Write-Host "FAILURES:"
        $failures | ForEach-Object { Write-Host " - $_" }
    }
}

if ($failures.Count -gt 0) { exit 1 }
exit 0
