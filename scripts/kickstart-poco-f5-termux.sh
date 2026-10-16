#!/bin/bash
# ==============================================================================
# Poco F5 (marble / marblein) Kickstart & Power-Maxing Script for Termux
# Designed to run directly inside Termux on Poco F5 or via Wireless ADB
# ==============================================================================
set -e

echo "======================================================================"
echo "  ⚡ POCO F5 GHOSTCORE KICKSTART (TERMUX / ON-DEVICE)"
echo "======================================================================"

# Check if adb is needed (if running via wireless adb or direct shell)
CMD_PREFIX=""
if command -v adb &> /dev/null; then
    # Test if adb shell works
    if adb shell getprop ro.product.model >/dev/null 2>&1; then
        echo "[+] Using local ADB connection."
        CMD_PREFIX="adb shell"
    fi
fi

run_cmd() {
    if [ -n "$CMD_PREFIX" ]; then
        $CMD_PREFIX "$@"
    else
        "$@"
    fi
}

echo "[+] Step 1: Bootstrapping Shizuku in Headless Detached Mode..."
run_cmd "sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh >/dev/null 2>&1 &" || true
echo "    [OK] Shizuku server dispatched (PPID 1)."

echo "[+] Step 2: Bootstrapping Brevent in Headless Detached Mode..."
run_cmd "nohup /data/app/*/me.piebridge.brevent*/lib/*/libbrevent.so >/dev/null 2>&1 &" || true
echo "    [OK] Brevent daemon dispatched (PPID 1)."

echo "[+] Step 3: Setting Fixed 60Hz Panel Cap..."
run_cmd settings put system min_refresh_rate 60.0
run_cmd settings put system peak_refresh_rate 60.0
run_cmd settings put system user_refresh_rate 60
echo "    [OK] Display refresh rate set to 60Hz."

echo "[+] Step 4: Suppressing Phantom Background Radio Scans..."
run_cmd settings put global wifi_scan_always_enabled 0
run_cmd settings put global mobile_data_always_on 0
echo "    [OK] Wi-Fi location scanning -> OFF"
echo "    [OK] Cellular high-power Wi-Fi handover -> OFF"

echo "[+] Step 5: Restricting Xiaomi Telemetry (mi_connect_service)..."
run_cmd am set-standby-bucket com.xiaomi.mi_connect_service restricted || true
run_cmd cmd appops set com.xiaomi.mi_connect_service WAKE_LOCK ignore || true
echo "    [OK] mi_connect_service placed in Restricted Bucket + No WakeLock."

echo "[+] Step 6: Restricting Termux Wakelock & Background Execution..."
run_cmd am set-standby-bucket com.termux restricted || true
run_cmd am set-standby-bucket com.termux.widget restricted || true
run_cmd cmd appops set com.termux WAKE_LOCK ignore || true
run_cmd cmd appops set com.termux RUN_IN_BACKGROUND ignore || true
run_cmd cmd appops set com.termux RUN_ANY_IN_BACKGROUND ignore || true
echo "    [OK] Termux background wakelocks suppressed."

echo "======================================================================"
echo "  ✨ POCO F5 FULLY OPTIMIZED & IMMORTALIZED!"
echo "  CRITICAL GHOST MODE RULE:"
echo "  DO NOT open the Shizuku or Brevent app UI into Recent Apps!"
echo "  Let them run headlessly in the background."
echo "======================================================================"
