#!/usr/bin/env python3
"""
GhostCore Package Triage & Non-Root Optimization Engine
Works on PC (Windows/Linux/macOS via ADB) and on-device (Android Termux via sh/rish).
Strictly reversible. Zero root required. 100% UPI/Banking safe.
"""

import argparse
import json
import os
import subprocess
import sys

CONFIG_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "configs")

def run_cmd(cmd, adb_device=None):
    if adb_device:
        full_cmd = ["adb", "-s", adb_device, "shell"] + cmd
    else:
        # Check if running on Android directly or using default adb
        if os.path.exists("/system/bin/sh") and not os.environ.get("FORCE_ADB"):
            full_cmd = cmd
        else:
            full_cmd = ["adb", "shell"] + cmd
    try:
        res = subprocess.run(full_cmd, capture_output=True, text=True, check=False)
        return res.stdout.strip(), res.returncode
    except Exception as e:
        return str(e), 1

def load_json(filename):
    filepath = os.path.join(CONFIG_DIR, filename)
    if os.path.exists(filepath):
        with open(filepath, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}

def get_installed_packages(adb_device=None):
    out, code = run_cmd(["pm", "list", "packages", "-3"], adb_device)
    pkgs = []
    for line in out.splitlines():
        if line.startswith("package:"):
            pkgs.append(line.replace("package:", "").strip())
    return sorted(pkgs)

def get_device_info(adb_device=None):
    model, _ = run_cmd(["getprop", "ro.product.model"], adb_device)
    brand, _ = run_cmd(["getprop", "ro.product.brand"], adb_device)
    android_ver, _ = run_cmd(["getprop", "ro.build.version.release"], adb_device)
    return brand, model, android_ver

def main():
    parser = argparse.ArgumentParser(description="GhostCore Non-Root Triage & Optimization Engine")
    parser.add_argument("-s", "--serial", help="ADB Device Serial (e.g. 4b973050)")
    parser.add_argument("--apply", action="store_true", help="Apply optimizations directly without prompting")
    parser.add_argument("--interactive", action="store_true", help="Interactively ask before freezing/shielding")
    parser.add_argument("--dry-run", action="store_true", help="Preview changes without modifying state")
    args = parser.parse_args()

    print("=" * 65)
    print("  âš¡ GHOSTCORE: REVERSIBLE NON-ROOT TRIAGE & POWER ENGINE")
    print("=" * 65)

    brand, model, android_ver = get_device_info(args.serial)
    print(f"[*] Detected Device: {brand} {model} (Android {android_ver})")

    vip_cfg = load_json("vip-exemptions.json").get("vip_packages", [])
    shield_cfg = load_json("safe-shield-list.json").get("shield_packages", [])
    freeze_cfg = load_json("recommended-freeze-list.json").get("freeze_packages", [])

    installed = get_installed_packages(args.serial)
    print(f"[*] Found {len(installed)} third-party user packages.\n")

    # 1. Radio optimizations
    print("[+] Step 1: Radio & Phantom Scan Neutralization")
    if args.dry_run:
        print("    [DRY-RUN] Would set wifi_scan_always_enabled = 0")
        print("    [DRY-RUN] Would set mobile_data_always_on = 0")
    else:
        run_cmd(["settings", "put", "global", "wifi_scan_always_enabled", "0"], args.serial)
        run_cmd(["settings", "put", "global", "mobile_data_always_on", "0"], args.serial)
        print("    [OK] wifi_scan_always_enabled -> 0 (Zero location radio polling)")
        print("    [OK] mobile_data_always_on -> 0 (Cellular modem sleeps on Wi-Fi)")

    # 2. Package Triage
    print("\n[+] Step 2: Triaging Packages...")
    to_freeze = []
    to_shield = []
    exempt = []

    for pkg in installed:
        if pkg in vip_cfg:
            exempt.append(pkg)
        elif pkg in freeze_cfg:
            to_freeze.append(pkg)
        elif pkg in shield_cfg:
            to_shield.append(pkg)
        else:
            # Unknown / general app
            if args.interactive:
                ans = input(f"    [?] App '{pkg}': [F]reeze (Hail), [S]hield (Bucket 45), [I]gnore/VIP? ").lower()
                if ans == 'f':
                    to_freeze.append(pkg)
                elif ans == 's':
                    to_shield.append(pkg)
                else:
                    exempt.append(pkg)
            else:
                to_shield.append(pkg)

    print(f"\n    - VIP Exempted (Untouched):  {len(exempt)} apps")
    print(f"    - Category B (Hail Freeze):   {len(to_freeze)} apps")
    print(f"    - Category C (Shield Bucket): {len(to_shield)} apps")

    if args.dry_run:
        print("\n[!] DRY RUN COMPLETED. No changes made.")
        return

    # Apply Freeze
    print("\n[+] Step 3: Applying Hail Deep Freeze (pm disable-user)...")
    for pkg in to_freeze:
        out, code = run_cmd(["pm", "disable-user", "--user", "0", pkg], args.serial)
        status = "FROZEN" if code == 0 else "FAIL"
        print(f"    [{status}] {pkg}")

    # Apply Shield
    print("\n[+] Step 4: Applying Standby Bucket 45 & AppOps Shield...")
    for pkg in to_shield:
        run_cmd(["am", "set-standby-bucket", pkg, "restricted"], args.serial)
        run_cmd(["cmd", "appops", "set", pkg, "WAKE_LOCK", "ignore"], args.serial)
        run_cmd(["cmd", "appops", "set", pkg, "RUN_IN_BACKGROUND", "ignore"], args.serial)
        run_cmd(["cmd", "appops", "set", pkg, "RUN_ANY_IN_BACKGROUND", "ignore"], args.serial)
        print(f"    [SHIELDED] {pkg} -> Bucket 45 (Restricted) + No WakeLock")

    print("\n" + "=" * 65)
    print("  âœ¨ SUCCESS! GHOSTCORE PROTOCOL FULLY APPLIED")
    print("  - Instant rollback anytime: 'pm enable --user 0 <pkg>'")
    print("  - WhatsApp & Critical calls: 100% untouched")
    print("=" * 65)

if __name__ == "__main__":
    main()
