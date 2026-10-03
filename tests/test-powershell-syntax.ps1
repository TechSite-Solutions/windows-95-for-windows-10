param([string]$Root = (Split-Path -Parent $PSScriptRoot))
Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

$errors=@()
Get-ChildItem -Path (Join-Path $Root "scripts") -Filter "*.ps1" -Recurse | ForEach-Object {
    $tokens=$null
    $parseErrors=$null
    [System.Management.Automation.Language.Parser]::ParseFile($_.FullName,[ref]$tokens,[ref]$parseErrors)|Out-Null
    if($parseErrors.Count -gt 0){
        foreach($e in $parseErrors){$errors += "$($_.FullName): $($e.Message)"}
    }else{
        Write-Host "OK $($_.FullName)"
    }
}
if($errors.Count -gt 0){
    $errors|ForEach-Object{Write-Error $_}
    exit 1
}
Write-Host "All PowerShell scripts parsed successfully."
