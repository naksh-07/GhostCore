<#
.SYNOPSIS
    GhostCore Universal Non-Root Power Maxing & Daemon Engine (PowerShell)
#>
[CmdletBinding()]
param(
    [string]$DeviceId = ""
)

$ErrorActionPreference = "Continue"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "  ⚡ GHOSTCORE: REVERSIBLE NON-ROOT POWER MAXING (WINDOWS PS)" -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Cyan

# 1. Resolve ADB
$adbPath = (Get-Command adb -ErrorAction SilentlyContinue)?.Source
if (-not $adbPath) {
    if (Test-Path "C:\platform-tools\adb.exe") {
        $adbPath = "C:\platform-tools\adb.exe"
    } elseif (Test-Path "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe") {
        $adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
    } else {
        Write-Error "adb.exe not found! Please install Android SDK platform-tools."
        exit 1
    }
}

# 2. Select Device
if (-not $DeviceId) {
    $devices = & $adbPath devices | Select-String "`tdevice$" | ForEach-Object { ($_ -split "`t")[0] }
    if ($devices.Count -eq 0) {
        Write-Error "No authorized ADB devices detected. Please connect phone and enable USB Debugging."
        exit 1
    }
    $DeviceId = $devices[0]
}

Write-Host "[+] Target Device Selected: $DeviceId" -ForegroundColor Green

# 3. Headless Daemons Kickstart
Write-Host "`n[+] Step 1: Bootstrapping Shizuku Server in Headless Detached Mode..." -ForegroundColor White
& $adbPath -s $DeviceId shell "sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh >/dev/null 2>&1 &"
Write-Host "    [OK] Shizuku server dispatched." -ForegroundColor Green

Write-Host "[+] Step 2: Bootstrapping Brevent Daemon in Headless Detached Mode..." -ForegroundColor White
& $adbPath -s $DeviceId shell "nohup /data/app/*/me.piebridge.brevent*/lib/*/libbrevent.so >/dev/null 2>&1 &"
Write-Host "    [OK] Brevent daemon dispatched." -ForegroundColor Green

# 4. Radio Neutralization
Write-Host "`n[+] Step 3: Neutralizing Phantom Radio Scans..." -ForegroundColor White
& $adbPath -s $DeviceId shell settings put global wifi_scan_always_enabled 0
& $adbPath -s $DeviceId shell settings put global mobile_data_always_on 0
Write-Host "    [OK] Wi-Fi background location scanning -> OFF" -ForegroundColor Green
Write-Host "    [OK] Cellular high-power Wi-Fi handover -> OFF" -ForegroundColor Green

# 5. Run Python Triage
$triageScript = Join-Path $PSScriptRoot "triage-packages.py"
if (Test-Path $triageScript) {
    Write-Host "`n[+] Step 4: Running Package Triage & Classification Engine..." -ForegroundColor White
    python $triageScript -s $DeviceId --apply
}

Write-Host "`n======================================================================" -ForegroundColor Cyan
Write-Host "  ✨ GHOSTCORE PROTOCOL FULLY APPLIED!" -ForegroundColor Yellow
Write-Host "  CRITICAL GHOST MODE INVARIANT:" -ForegroundColor Magenta
Write-Host "  DO NOT open the Shizuku or Brevent app UI into Recent Apps!" -ForegroundColor White
Write-Host "  They will run silently with PPID 1 forever without being killed." -ForegroundColor White
Write-Host "======================================================================" -ForegroundColor Cyan
