param(
    [switch]$KeepWindowsIndicator
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Assert-Windows10
Write-Section "Configuring Windows 95 language indicator"

$retroSettings = Join-Path $env:LOCALAPPDATA "RetroBar\settings.json"
if (Test-Path $retroSettings) {
    try {
        $json = Get-Content $retroSettings -Raw | ConvertFrom-Json
        if (-not $json.ShowInputLanguage) {
            Write-Warning "RetroBar ShowInputLanguage is disabled. Run configure-retrobar.ps1 first."
        }
    } catch {
        Write-Warning "Could not parse RetroBar settings.json."
    }
}

if ($KeepWindowsIndicator) {
    Write-Host "Leaving the native Windows input indicator unchanged."
    return
}

$setLanguageBar = Get-Command Set-WinLanguageBarOption -ErrorAction SilentlyContinue
if (-not $setLanguageBar) {
    Write-Warning "Set-WinLanguageBarOption is unavailable. The RetroBar language switcher remains enabled, but the native Windows indicator could not be suppressed automatically."
    return
}

# Enabling the legacy desktop language bar disables the modern taskbar input indicator.
# We then hide the legacy bar itself, leaving RetroBar as the visible language switcher.
Set-WinLanguageBarOption -UseLegacyLanguageBar

$langBarKey = "HKCU:\Software\Microsoft\CTF\LangBar"
New-Item -Path $langBarKey -Force | Out-Null

# ShowStatus=3 is the legacy Language Bar's Hidden state on Windows 10.
Set-RegistryValue -Path $langBarKey -Name "ShowStatus" -Value 3 -Type DWord

$ctfmon = Join-Path $env:WINDIR "System32\ctfmon.exe"
if (Test-Path $ctfmon) {
    Start-Process $ctfmon -ErrorAction SilentlyContinue
}

Write-Host "Native Windows input indicator suppressed."
Write-Host "RetroBar remains the visible Windows 95-style language/keyboard switcher."
Write-Host "A sign-out/sign-in may be required for the native indicator to disappear completely."
