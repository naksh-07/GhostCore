@echo off
title Poco F5 Post-Reboot Kickstarter
color 0A
chcp 65001 >nul

set "PATH=%LOCALAPPDATA%\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools;%LOCALAPPDATA%\Android\Sdk\platform-tools;%PATH%"

echo =====================================================================
echo       🚀 POCO F5 POST-REBOOT KICKSTARTER (GOD-TIER TIER 1)
echo =====================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0kickstart-poco-f5.ps1"

echo.
pause
