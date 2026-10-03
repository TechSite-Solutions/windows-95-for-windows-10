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

    [pscustomobject]@{
        Repository  = $Repository
        Tag          = [string]$release.tag_name
        Name         = [string]$asset.name
        DownloadUrl  = [string]$asset.browser_download_url
        Size         = [long]$asset.size
        PublishedAt  = [string]$release.published_at
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

function Get-RetroBarExe {
    $candidates = @(
        "$env:ProgramFiles\RetroBar\RetroBar.exe",
        "${env:ProgramFiles(x86)}\RetroBar\RetroBar.exe",
        "$env:LOCALAPPDATA\Programs\RetroBar\RetroBar.exe"
    ) | Where-Object { $_ -and $_ -notmatch "^\\RetroBar" }

    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }

    $entry = Get-UninstallEntries | Where-Object { $_.DisplayName -eq "RetroBar" } | Select-Object -First 1
    if ($entry -and $entry.InstallLocation) {
        $path = Join-Path $entry.InstallLocation "RetroBar.exe"
        if (Test-Path $path) { return $path }
    }

    return $null
}

function Get-OpenShellExe {
    $candidates = @(
        "$env:ProgramFiles\Open-Shell\StartMenu.exe",
        "${env:ProgramFiles(x86)}\Open-Shell\StartMenu.exe"
    ) | Where-Object { $_ -and $_ -notmatch "^\\Open-Shell" }

    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }

    $entry = Get-UninstallEntries | Where-Object {
        $_.DisplayName -match "^Open-Shell"
    } | Select-Object -First 1

    if ($entry -and $entry.InstallLocation) {
        $path = Join-Path $entry.InstallLocation "StartMenu.exe"
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

function Stop-ProcessIfRunning {
    param([Parameter(Mandatory=$true)][string]$Name)

    Get-Process -Name $Name -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

function Write-Section {
    param([Parameter(Mandatory=$true)][string]$Text)
    Write-Host ""
    Write-Host "=== $Text ==="
}
