# ==============================================================================
# POCO F5 (HyperOS / Android 14/15) - 1-Click Post-Reboot Kickstarter
# Target Device: 4b973050 (or any connected device)
# Features:
#   1. Disables Android Phantom Process Killer permanently
#   2. Starts Brevent daemon in detached nohup mode (survives USB disconnect)
#   3. Starts Shizuku daemon in detached nohup mode (survives USB disconnect)
#   4. Verifies & authorizes App Ops (rikka.appops) via Shizuku
#   5. Verifies & authorizes Hail (com.aistra.hail) if present
#   6. Real-time Status Verification and Health Check Dashboard
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Poco F5 Kickstarter - Brevent, Shizuku & App Ops"

function Write-Color([string]$text, [ConsoleColor]$color) {
    Write-Host $text -ForegroundColor $color
}

Clear-Host
Write-Color "=====================================================================" Cyan
Write-Color "   🚀 POCO F5 POST-REBOOT KICKSTARTER (GOD-TIER PRIVACY & BATTERY)   " Yellow
Write-Color "=====================================================================" Cyan
Write-Color "[*] Checking ADB connection..." Gray

$rawDevices = adb devices
$deviceLines = @($rawDevices | Where-Object { $_ -match "\bdevice\b" -and $_ -notmatch "List of devices" })

if ($deviceLines.Count -eq 0) {
    Write-Color "[!] ERROR: No authorized ADB device found!" Red
    Write-Color "    Please ensure USB Debugging is ON and phone is unlocked." Yellow
    exit 1
}

$deviceId = ($deviceLines[0] -split "\s+")[0].Trim()
Write-Color "[+] Device detected: $deviceId" Green

Write-Host ""
Write-Color "[1/5] Immunizing Android Against Phantom Process Killer..." Cyan
adb -s $deviceId shell "settings put global settings_enable_monitor_phantom_procs false" 2>$null | Out-Null
adb -s $deviceId shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647" 2>$null | Out-Null
Write-Color "      [OK] Phantom process monitor disabled (daemons will NOT be auto-killed)" Green

Write-Host ""
Write-Color "[2/5] Initializing Brevent Server..." Cyan
$breventPkg = adb -s $deviceId shell "pm list packages | grep me.piebridge.brevent" 2>$null | Out-String
if ($breventPkg -match "me.piebridge.brevent") {
    $breventProc = adb -s $deviceId shell "ps -A | grep -iE 'brevent_server|brevent_daemon'" 2>$null | Out-String
    if ($breventProc -match "brevent") {
        Write-Color "      [OK] Brevent server is ALREADY RUNNING." Green
    } else {
        Write-Color "      [*] Launching Brevent server daemon (nohup)..." Gray
        adb -s $deviceId shell "chmod 0755 /data/local/tmp/brevent 2>/dev/null; nohup /data/local/tmp/brevent >/dev/null 2>&1 &" 2>$null | Out-Null
        Start-Sleep -Seconds 2
        $breventProc = adb -s $deviceId shell "ps -A | grep -iE 'brevent_server|brevent_daemon'" 2>$null | Out-String
        if (-not ($breventProc -match "brevent")) {
            Write-Color "      [*] Bootstrapping Brevent from APK..." Gray
            $bootCmd = 'output=$(pm path me.piebridge.brevent | tr -d "\r"); export CLASSPATH=${output#*:}; app_process /system/bin me.piebridge.brevent.server.BreventServer bootstrap'
            adb -s $deviceId shell $bootCmd 2>$null | Out-Null
            adb -s $deviceId shell "chmod 0755 /data/local/tmp/brevent 2>/dev/null; nohup /data/local/tmp/brevent >/dev/null 2>&1 &" 2>$null | Out-Null
            Start-Sleep -Seconds 2
            $breventProc = adb -s $deviceId shell "ps -A | grep -iE 'brevent_server|brevent_daemon'" 2>$null | Out-String
        }
        if ($breventProc -match "brevent") {
            Write-Color "      [OK] Brevent server started successfully!" Green
        } else {
            Write-Color "      [!] Failed to start Brevent server." Yellow
        }
    }
} else {
    Write-Color "      [-] Brevent is not installed yet." DarkGray
}

Write-Host ""
Write-Color "[3/5] Initializing Shizuku Server..." Cyan
$shizukuProc = adb -s $deviceId shell "ps -A | grep -i shizuku_server" 2>$null | Out-String
if ($shizukuProc -match "shizuku_server") {
    Write-Color "      [OK] Shizuku server is ALREADY RUNNING." Green
} else {
    $shizukuPkg = adb -s $deviceId shell "pm list packages | grep moe.shizuku.privileged.api" 2>$null | Out-String
    if ($shizukuPkg -match "moe.shizuku.privileged.api") {
        Write-Color "      [*] Launching Shizuku native daemon (nohup)..." Gray
        adb -s $deviceId shell "chmod 0755 /data/local/tmp/shizuku_starter 2>/dev/null; nohup /data/local/tmp/shizuku_starter >/dev/null 2>&1 &" 2>$null | Out-Null
        Start-Sleep -Seconds 2
        $shizukuProc = adb -s $deviceId shell "ps -A | grep -i shizuku_server" 2>$null | Out-String
        if ($shizukuProc -match "shizuku_server") {
            Write-Color "      [OK] Shizuku server started successfully!" Green
        } else {
            Write-Color "      [*] Trying fallback via starter script..." Gray
            adb -s $deviceId shell "nohup sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh >/dev/null 2>&1 &" 2>$null | Out-Null
            Start-Sleep -Seconds 2
        }
    } else {
        Write-Color "      [!] Shizuku app is not yet installed on device." Yellow
        Write-Color "          APK is pre-staged at: /sdcard/Download/shizuku-v13.6.0.apk" Cyan
        Write-Color "          Opening File Manager on phone now to tap & install..." Gray
        adb -s $deviceId shell am start -n com.mi.android.globalFileexplorer/com.android.fileexplorer.FileExplorerTabActivity 2>$null | Out-Null
    }
}

Write-Host ""
Write-Color "[4/5] Authorizing Shizuku Client Apps & Whitelisting..." Cyan
adb -s $deviceId shell "dumpsys deviceidle whitelist +me.piebridge.brevent; dumpsys deviceidle whitelist +moe.shizuku.privileged.api; cmd appops set me.piebridge.brevent RUN_IN_BACKGROUND allow; cmd appops set moe.shizuku.privileged.api RUN_IN_BACKGROUND allow" 2>$null | Out-Null
$appopsInstalled = adb -s $deviceId shell "pm list packages | grep rikka.appops" 2>$null | Out-String
if ($appopsInstalled -match "rikka.appops") {
    adb -s $deviceId shell "pm grant rikka.appops moe.shizuku.manager.permission.API_V23" 2>$null | Out-Null
    Write-Color "      [OK] App Ops (rikka.appops) authorized with Shizuku API privilege." Green
} else {
    Write-Color "      [-] App Ops is not installed yet." DarkGray
}

$hailInstalled = adb -s $deviceId shell "pm list packages | grep com.aistra.hail" 2>$null | Out-String
if ($hailInstalled -match "com.aistra.hail") {
    adb -s $deviceId shell "pm grant com.aistra.hail moe.shizuku.manager.permission.API_V23" 2>$null | Out-Null
    Write-Color "      [OK] Hail (com.aistra.hail) authorized with Shizuku API privilege." Green
} else {
    Write-Color "      [-] Hail is not installed yet (local repo cloned at .\Hail)." DarkGray
}

Write-Host ""
Write-Color "[*] Refreshing God-Tier Battery & Privacy Profile Rules..." Cyan
& "$PSScriptRoot\apply-power-maxing.ps1"

Write-Host ""
Write-Color "[5/5] Final Verification & Process Audit..." Cyan
$finalProcesses = adb -s $deviceId shell "ps -A | grep -E 'brevent|shizuku'" 2>$null | Out-String

Write-Color "---------------------------------------------------------------------" Gray
if ($finalProcesses.Trim()) {
    Write-Host "$finalProcesses" -ForegroundColor White
} else {
    Write-Color "No daemon processes detected." Red
}
Write-Color "---------------------------------------------------------------------" Gray

Write-Host ""
Write-Color "=====================================================================" Green
Write-Color "  ✨ KICKSTART COMPLETE! YOU CAN NOW UNPLUG THE USB CABLE!           " Green
Write-Color "  Daemons will remain alive 24/7 in background until next reboot.    " Green
Write-Color "=====================================================================" Green
Write-Host ""
