@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install-interactive.ps1"
set CODE=%ERRORLEVEL%
echo.
if not "%CODE%"=="0" echo Installer returned exit code %CODE%.
pause
exit /b %CODE%
