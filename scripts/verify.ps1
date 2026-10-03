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
            if (-not $settings.ShowInputLanguage) {
                $failures.Add("RetroBar ShowInputLanguage is disabled.")
            }
            if ("$($settings.ClockClickAction)" -ne "0") {
                $failures.Add("RetroBar ClockClickAction is '$($settings.ClockClickAction)', expected 0 (DoNothing).")
            }
        } catch {
            $failures.Add("RetroBar settings.json could not be parsed.")
        }
    } else {
        $failures.Add("RetroBar settings.json is missing.")
    }
}

$languageBarCommand = Get-Command Get-WinLanguageBarOption -ErrorAction SilentlyContinue
if ($languageBarCommand) {
    try {
        $languageBar = Get-WinLanguageBarOption
        if (-not $languageBar.IsLegacyLanguageBar) {
            $failures.Add("Legacy language bar mode is not enabled, so the native Windows input indicator may remain visible.")
        }
        Test-ExpectedRegistryValue -Path "HKCU:\Software\Microsoft\CTF\LangBar" -Name "ShowStatus" -Expected 3
    } catch {
        $warnings.Add("Could not verify Windows language bar mode.")
    }
} else {
    $warnings.Add("Get-WinLanguageBarOption is unavailable; native Windows input indicator suppression was not verified.")
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

$stateFile = Join-Path (Get-ProjectRoot) "state\last-install.json"
$expectClockCompanion = $false
if (Test-Path $stateFile) {
    try {
        $state = Get-Content $stateFile -Raw | ConvertFrom-Json
        if ($state.PSObject.Properties.Name -contains "ClockCompanionInstalledByProject") {
            $expectClockCompanion = [bool]$state.ClockCompanionInstalledByProject
        }
    } catch {}
}

$clockDir = Join-Path $env:LOCALAPPDATA "Windows95ForWindows10\Clock"
$clockScript = Join-Path $clockDir "Win95ClockCompanion.ps1"
$clockConfig = Join-Path $clockDir "clock-config.json"
$clockRun = Get-RegistryValueSnapshot -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Win95ClockCompanion"

if ($expectClockCompanion) {
    if (-not (Test-Path $clockScript)) { $failures.Add("Win95 Clock Companion script is missing.") }
    if (-not (Test-Path $clockConfig)) { $failures.Add("Win95 Clock Companion config is missing.") }
    if (-not $clockRun.Exists) { $failures.Add("Win95 Clock Companion startup value is missing.") }
} elseif (-not (Test-Path $clockScript)) {
    $warnings.Add("Win95 Clock Companion is not installed.")
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
