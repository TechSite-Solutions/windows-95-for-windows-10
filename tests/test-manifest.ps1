param([string]$Root = (Split-Path -Parent $PSScriptRoot))

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$path = Join-Path $Root "config\components.json"
$manifest = Get-Content $path -Raw | ConvertFrom-Json

$components = @(
    @{ Name = "retrobar"; Value = $manifest.retrobar },
    @{ Name = "openshell"; Value = $manifest.openshell }
)

foreach ($entry in $components) {
    $name = $entry.Name
    $component = $entry.Value

    foreach ($property in @("version","tag","repository","asset","url","sha256")) {
        if (-not ($component.PSObject.Properties.Name -contains $property) -or -not $component.$property) {
            throw "$name is missing required property '$property'."
        }
    }

    if ([string]$component.sha256 -notmatch '^[0-9a-fA-F]{64}$') {
        throw "$name sha256 is not a 64-character hexadecimal digest."
    }

    if ([string]$component.url -notmatch '^https://github\.com/') {
        throw "$name URL is not an HTTPS github.com release URL."
    }

    $expectedFragment = "/$($component.repository)/releases/download/$($component.tag)/$($component.asset)"
    if (-not ([string]$component.url).EndsWith($expectedFragment)) {
        throw "$name URL does not match repository/tag/asset metadata."
    }

    Write-Host "OK $name $($component.version)"
}

Write-Host "Component manifest validation passed."
