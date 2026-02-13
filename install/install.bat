@echo off
echo ========================================
echo   PowerShell Backup Profile Installer
echo ========================================
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1"
echo.
pause
