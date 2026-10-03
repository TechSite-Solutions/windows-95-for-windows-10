@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install.ps1"
set CODE=%ERRORLEVEL%
echo.
if not "%CODE%"=="0" echo Installation returned exit code %CODE%.
pause
exit /b %CODE%
