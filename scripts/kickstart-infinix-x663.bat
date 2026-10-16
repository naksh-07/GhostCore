@echo off
title Infinix X663 Post-Reboot Kickstarter
color 0E
chcp 65001 >nul

set "PATH=%LOCALAPPDATA%\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools;%LOCALAPPDATA%\Android\Sdk\platform-tools;%PATH%"

echo =====================================================================
echo       🚀 INFINIX X663 POST-REBOOT KICKSTARTER (GOD-TIER MAXING)
echo =====================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0kickstart-infinix-x663.ps1"

echo.
pause
