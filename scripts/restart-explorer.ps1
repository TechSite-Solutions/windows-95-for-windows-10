Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Warning "This will close open File Explorer windows."

Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Process explorer.exe

Write-Host "Explorer restarted."
