#!/bin/bash
# ==============================================================================
# GhostCore Universal Daemon & Power Bootstrapper (Linux / macOS / Termux)
# ==============================================================================
set -e

SERIAL_ARG=""
if [ -n "$1" ]; then
    SERIAL_ARG="-s $1"
fi

ADB_CMD="adb $SERIAL_ARG"

echo "======================================================================"
echo "  ⚡ GHOSTCORE: REVERSIBLE NON-ROOT DAEMON & POWER ENGINE"
echo "======================================================================"

# Check ADB
if ! command -v adb &> /dev/null; then
    if [ -f "/system/bin/sh" ]; then
        echo "[!] Running directly in Android shell/Termux."
        ADB_CMD=""
    else
        echo "[-] Error: 'adb' command not found. Please install platform-tools."
        exit 1
    fi
fi

# 1. Daemon Kickstart
echo "[+] Step 1: Bootstrapping Shizuku Server in Headless Detached Mode..."
if [ -n "$ADB_CMD" ]; then
    $ADB_CMD shell "sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh >/dev/null 2>&1 &" || true
    echo "    [OK] Shizuku server dispatched."
    
    echo "[+] Step 2: Bootstrapping Brevent Daemon in Headless Detached Mode..."
    $ADB_CMD shell "nohup /data/app/*/me.piebridge.brevent*/lib/*/libbrevent.so >/dev/null 2>&1 &" || true
    echo "    [OK] Brevent daemon dispatched."
else
    sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh >/dev/null 2>&1 &
    nohup /data/app/*/me.piebridge.brevent*/lib/*/libbrevent.so >/dev/null 2>&1 &
fi

# 2. Radio Settings
echo "[+] Step 3: Neutralizing Phantom Radio Scans..."
if [ -n "$ADB_CMD" ]; then
    $ADB_CMD shell settings put global wifi_scan_always_enabled 0
    $ADB_CMD shell settings put global mobile_data_always_on 0
else
    settings put global wifi_scan_always_enabled 0
    settings put global mobile_data_always_on 0
fi
echo "    [OK] Wi-Fi background location scanning -> OFF"
echo "    [OK] Cellular high-power Wi-Fi handover -> OFF"

# 3. Python Package Triage
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if command -v python3 &> /dev/null; then
    echo "[+] Step 4: Running Package Triage Engine..."
    if [ -n "$1" ]; then
        python3 "$SCRIPT_DIR/triage-packages.py" -s "$1" --apply
    else
        python3 "$SCRIPT_DIR/triage-packages.py" --apply
    fi
else
    echo "[!] python3 not found. Skipping automatic app triaging."
fi

echo "======================================================================"
echo "  ✨ GHOSTCORE DEPLOYMENT COMPLETE!"
echo "  Remember the Ghost Mode Rule:"
echo "  DO NOT open the Shizuku/Brevent UI into Recent Apps on HyperOS/MIUI!"
echo "======================================================================"
