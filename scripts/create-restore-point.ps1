param(
    [string]$Description = "Before Windows 95 Theme"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\Common.ps1")

Write-Section "System Restore point"

if (-not (Get-IsAdministrator)) {
    Write-Warning "Administrator rights are required to create a System Restore point. Skipping."
    return
}

try {
    Enable-ComputerRestore -Drive "$($env:SystemDrive)\" -ErrorAction Stop
} catch {
    Write-Warning "Could not enable System Restore automatically: $($_.Exception.Message)"
}

try {
    Checkpoint-Computer -Description $Description -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "Restore point created: $Description"
} catch {
    Write-Warning "Windows did not create the restore point: $($_.Exception.Message)"
    Write-Warning "The project registry/file backup will still be used for rollback."
}
