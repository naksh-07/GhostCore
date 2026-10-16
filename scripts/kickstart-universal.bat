@echo off
setlocal enabledelayedexpansion

echo ======================================================================
echo   GHOSTCORE: 1-CLICK UNIVERSAL NON-ROOT POWER MAXING ENGINE
echo ======================================================================

set "PATH=%PATH%;C:\platform-tools;%LOCALAPPDATA%\Android\Sdk\platform-tools"

where adb >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [-] Error: adb not found in PATH or standard platform-tools directory.
    pause
    exit /b 1
)

echo [*] Checking connected ADB devices...
adb devices
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0ghostcore-setup.ps1"

pause
