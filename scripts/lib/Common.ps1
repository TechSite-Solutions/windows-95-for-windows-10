Set-StrictMode -Version Latest

function Get-ProjectRoot {
    return (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
}

function Get-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-WindowsInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    [pscustomobject]@{
        Caption      = $os.Caption
        Version      = $os.Version
        BuildNumber  = $os.BuildNumber
        Architecture = $os.OSArchitecture
    }
}

function Assert-Windows10 {
    param([switch]$AllowUnsupportedWindows)

    if ($env:OS -ne "Windows_NT") {
        throw "This project supports Windows only."
    }

    $os = Get-WindowsInfo
    if ($os.Caption -notmatch "Windows 10") {
        if (-not $AllowUnsupportedWindows) {
            throw "Primary supported target is Windows 10. Use -AllowUnsupportedWindows only for deliberate testing."
        }
        Write-Warning "Unsupported target: $($os.Caption)."
    }
}

function Get-ComponentManifest {
    $root = Get-ProjectRoot
    $path = Join-Path $root "config\components.json"
    if (-not (Test-Path $path)) {
        throw "Missing component manifest: $path"
    }
    return (Get-Content $path -Raw | ConvertFrom-Json)
}

function Get-LatestGitHubAsset {
    param(
        [Parameter(Mandatory=$true)][string]$Repository,
        [Parameter(Mandatory=$true)][string]$AssetPattern
    )

    $headers = @{
        "User-Agent" = "windows-95-for-windows-10"
        "Accept"     = "application/vnd.github+json"
    }
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repository/releases/latest" -Headers $headers

    if ($release.draft -or $release.prerelease) {
        throw "Latest release for $Repository is not a stable release."
    }

    $asset = @($release.assets) | Where-Object { $_.name -match $AssetPattern } | Select-Object -First 1
    if (-not $asset) {
        throw "No release asset matching '$AssetPattern' was found for $Repository."
    }

    $digest = $null
    if ($asset.PSObject.Properties.Name -contains "digest") {
        $digest = [string]$asset.digest
    }

    [pscustomobject]@{
        Repository  = $Repository
        Tag          = [string]$release.tag_name
        Name         = [string]$asset.name
        DownloadUrl  = [string]$asset.browser_download_url
        Size         = [long]$asset.size
        PublishedAt  = [string]$release.published_at
        Digest       = $digest
    }
}

function Invoke-FileDownload {
    param(
        [Parameter(Mandatory=$true)][string]$Uri,
        [Parameter(Mandatory=$true)][string]$Destination
    )

    $parent = Split-Path -Parent $Destination
    if ($parent) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    Write-Host "Downloading: $Uri"
    Invoke-WebRequest -Uri $Uri -OutFile $Destination -UseBasicParsing
    if (-not (Test-Path $Destination)) {
        throw "Download failed: $Destination"
    }
}

function Assert-FileSha256 {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Expected
    )

    $actual = (Get-FileHash -Path $Path -Algorithm SHA256).Hash.ToLowerInvariant()
    $expectedNormalized = $Expected.ToLowerInvariant().Replace("sha256:","")

    if ($actual -ne $expectedNormalized) {
        throw "SHA-256 mismatch for '$Path'. Expected $expectedNormalized, got $actual."
    }

    Write-Host "SHA-256 verified: $actual"
}

function Get-UninstallEntries {
    $paths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    foreach ($path in $paths) {
        Get-ItemProperty $path -ErrorAction SilentlyContinue
    }
}

function Get-ObjectPropertyValue {
    param(
        [Parameter(Mandatory=$true)]$Object,
        [Parameter(Mandatory=$true)][string]$Name
    )

    if ($null -eq $Object) {
        return $null
    }

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $null
    }

    return $property.Value
}

function Get-RetroBarExe {
    $programFilesX86 = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)")
    $candidates = @(
        (Join-Path $env:ProgramFiles "RetroBar\RetroBar.exe"),
        $(if ($programFilesX86) { Join-Path $programFilesX86 "RetroBar\RetroBar.exe" }),
        (Join-Path $env:LOCALAPPDATA "Programs\RetroBar\RetroBar.exe")
    ) | Where-Object { $_ }

    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }

    $entry = Get-UninstallEntries | Where-Object {
        (Get-ObjectPropertyValue -Object $_ -Name "DisplayName") -eq "RetroBar"
    } | Select-Object -First 1

    if ($entry) {
        $installLocation = Get-ObjectPropertyValue -Object $entry -Name "InstallLocation"
        if ($installLocation) {
            $path = Join-Path ([string]$installLocation) "RetroBar.exe"
            if (Test-Path $path) { return $path }
        }
    }

    return $null
}

function Get-OpenShellExe {
    $programFilesX86 = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)")
    $candidates = @(
        (Join-Path $env:ProgramFiles "Open-Shell\StartMenu.exe"),
        $(if ($programFilesX86) { Join-Path $programFilesX86 "Open-Shell\StartMenu.exe" })
    ) | Where-Object { $_ }

    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }

    $entry = Get-UninstallEntries | Where-Object {
        (Get-ObjectPropertyValue -Object $_ -Name "DisplayName") -match "^Open-Shell"
    } | Select-Object -First 1

    if ($entry) {
        $installLocation = Get-ObjectPropertyValue -Object $entry -Name "InstallLocation"
        if ($installLocation) {
            $path = Join-Path ([string]$installLocation) "StartMenu.exe"
            if (Test-Path $path) { return $path }
        }
    }

    return $null
}

function Get-ClassicExplorerSettingsExe {
    $programFilesX86 = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)")
    $candidates = @(
        (Join-Path $env:ProgramFiles "Open-Shell\ClassicExplorerSettings.exe"),
        $(if ($programFilesX86) { Join-Path $programFilesX86 "Open-Shell\ClassicExplorerSettings.exe" })
    ) | Where-Object { $_ }

    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }

    return $null
}

function Set-RegistryValue {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)]$Value,
        [ValidateSet("String","DWord","QWord","MultiString","Binary")]
        [string]$Type = "String"
    )

    New-Item -Path $Path -Force | Out-Null
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
}

function Get-RegistryValueSnapshot {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Name
    )

    if (-not (Test-Path $Path)) {
        return [pscustomobject]@{ Exists = $false; Value = $null }
    }

    try {
        $value = Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction Stop
        return [pscustomobject]@{ Exists = $true; Value = $value }
    } catch {
        return [pscustomobject]@{ Exists = $false; Value = $null }
    }
}

function Stop-ProcessIfRunning {
    param([Parameter(Mandatory=$true)][string]$Name)
    Get-Process -Name $Name -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

function Write-Section {
    param([Parameter(Mandatory=$true)][string]$Text)
    Write-Host ""
    Write-Host "=== $Text ==="
}
