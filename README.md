<div align="center">

# ⚡ GhostCore (AndroCryo)
### The Sovereign Non-Root Android Optimization & Daemon Immortality Framework

[![Android Version](https://img.shields.io/badge/Android-9.0%20to%2015%2B-green.svg)](https://developer.android.com)
[![Root Status](https://img.shields.io/badge/Root-100%25%20NON--ROOT-brightgreen.svg)](#)
[![Play Integrity](https://img.shields.io/badge/Play%20Integrity-100%25%20PASSED%20(GREEN)-blue.svg)](#)
[![UPI & Banking](https://img.shields.io/badge/Banking%20%26%20UPI-100%25%20SAFE-success.svg)](#)
[![License](https://img.shields.io/badge/License-MIT-orange.svg)](LICENSE)

**Achieve keypad-phone standby battery life (0.2%–0.4% per hour / 9–14 days idle endurance) on any modern smartphone without unlocking the bootloader, tripping Knox, or risking banking apps.**

[Architecture Deep Dive](docs/ARCHITECTURE.md) • [PC-Free Guide (Termux/OTG)](docs/PC_FREE_GUIDE.md) • [OEM Matrix](docs/OEM_COMPATIBILITY_MATRIX.md) • [Troubleshooting](docs/TROUBLESHOOTING.md)

</div>

---

## 🎯 The Problem GhostCore Solves

Every modern smartphone is throttled by the **"OEM Bloatware Tax"**:
1. **Planned Battery Depreciation**: 30–50 system telemetry daemons, phantom Wi-Fi probes, and carrier 5G wake locks drain 20–40% of your battery in pure idle standby.
2. **The Fragile Daemon Death Trap**: Useful tools like **Shizuku** and **Brevent** die the moment you unplug the USB cable (`SIGHUP` signal) or swipe them away from Recent Apps (`ProcessSceneCleaner` / `OneKeyClean`).
3. **The "Nuclear" Custom ROM Trade-off**: Unlocking bootloaders and flashing custom ROMs trips Google Play Integrity, breaks banking/UPI apps (Google Pay, PhonePe, Paytm), and introduces device certification headaches.

**GhostCore solves all three permanently through pure userspace engineering.**

---

## 🔬 How GhostCore Works: The 4 Pillars

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        GHOSTCORE ARCHITECTURE                          │
├─────────────────────────┬───────────────────────┬──────────────────────┤
│       PILLAR 1          │       PILLAR 2        │       PILLAR 3       │
│ Headless Daemon PPID 1  │  Ghost Mode Protocol  │  Tri-Tier Governance │
├─────────────────────────┼───────────────────────┼──────────────────────┤
│ • nohup disown          │ • Zero-UI in Recents  │ • VIP Exempt (5)     │
│ • sys.usb.config=adb    │ • Bypass SceneCleaner │ • Shield Bucket (45) │
│ • Survives USB unplug   │ • Survives LockClean  │ • Hail Cryo-Freeze   │
└─────────────────────────┴───────────────────────┴──────────────────────┘
```

### 1. Headless Daemon Persistence (`PPID 1` + Gadget Decoupling)
* Standard daemons die when unplugging USB because the kernel MTP gadget teardown sends `SIGHUP` to the PTS session.
* GhostCore pins `sys.usb.config=adb` (No Data Transfer) and disowns daemon processes into background `nohup` jobs attached directly to `init` (**PPID 1**). Daemons survive cable disconnection permanently.

### 2. The Ghost Mode Protocol (HyperOS / OEM Cleaner Bypass)
* HyperOS's `ProcessSceneCleaner` sweeps tasks present in the `ActivityTaskManagerService` Recent Apps list.
* **The Ghost Invariant**: Once bootstrapped, **never open the Shizuku or Brevent app UI into Recent Apps**. Because their UI never enters the Recent task stack, OEM cleaners consider them non-existent and **never kill them**.

### 3. Tri-Tier Reversible App Governance
* **Tier 1 (VIP - Exempted 5)**: WhatsApp, Telegram, Phone, Gboard, Alarms. Zero notification delay, 100% native.
* **Tier 2 (Shielded - Standby Bucket 45)**: YouTube, Browsers, Anki, Notes. Run at 100% full speed when open, but enter instantaneous deep sleep upon screen lock via `WAKE_LOCK: ignore`.
* **Tier 3 (Cryo-Frozen - Hail)**: Heavy bloat, Amazon, Meesho, Torrent clients, games. Frozen into `pm disable-user`. 0% RAM, 0% CPU, 0% battery. 1-tap unfreeze when needed.

### 4. Phantom Radio Scans Purged
* `wifi_scan_always_enabled 0`: Stops 1,500+ phantom Wi-Fi probe requests per day by Google Location Services.
* `mobile_data_always_on 0`: Allows the cellular 5G/LTE modem to enter true low-power eDRX sleep when connected to Wi-Fi, saving 150–250 mAh per day.

---

## 📊 Real-World Hardware Benchmarks

| Metric | Stock Poco F5 (Snapdragon 7+ Gen 2) | GhostCore Poco F5 | Impact |
| :--- | :--- | :--- | :--- |
| **Idle Drain Rate** | ~981 mAh / hr (~20%/hr) | **~11.4 mAh / 30 mins (0.4%/hr)** | **98% Drain Eliminated** |
| **Standby Endurance** | 5–6 Hours | **9.2 to 14.5 Days** | Keypad-Phone Longevity |
| **Chassis Temperature** | 36.7°C (Warm in idle) | **31.0°C (Cold to touch)** | -5.7°C Heat Drop |
| **Deep Sleep Ratio** | 0% (Wakelocks active) | **87.4% to 97.1%** | CPU rests in C-States |
| **Banking / UPI** | Native | **100% Native & Safe** | Zero Play Integrity Risk |

*Tested on Poco F5 (`marblein`) and Infinix X663 (`X663-GL`).*

---

## 🚀 Quick Start

### Option A: With PC (Windows / Linux / macOS)

#### Windows (1-Click):
1. Enable **USB Debugging** on your phone (Developer Options).
2. Set "Default USB configuration" to **No data transfer**.
3. Plug in your phone, clone the repo, and double-click:
   ```cmd
   scripts\kickstart-universal.bat
   ```

#### Linux / macOS:
```bash
git clone https://github.com/your-username/GhostCore.git
cd GhostCore
chmod +x scripts/*.sh
./scripts/ghostcore-setup.sh
```

---

### Option B: 100% PC-Free (On-Device via Termux)
*No computer needed! Works using Android 11+ Wireless Debugging or a friend's phone over OTG.*

1. Connect to any Wi-Fi network.
2. In **Developer Options -> Wireless Debugging**, tap **Pair device with pairing code**.
3. Open **Termux** and execute:
   ```bash
   pkg update && pkg install android-tools git python -y
   adb pair <IP>:<PAIR_PORT>
   adb connect <IP>:<CONNECT_PORT>
   
   git clone https://github.com/your-username/GhostCore.git
   cd GhostCore
   chmod +x scripts/*.sh
   ./scripts/ghostcore-setup.sh
   ```
👉 *Read the full [PC-Free Deployment Guide](docs/PC_FREE_GUIDE.md) for step-by-step screenshots and OTG instructions.*

---

## 🛡️ Zero-Brick & Instant Reversibility Guarantee

GhostCore **never** deletes APK files from `/system` or `/vendor`. It utilizes Android's native userspace switches.
* To instantly unfreeze any frozen app from terminal:
  ```bash
  adb shell pm enable --user 0 <package_name>
  ```
* To restore stock Wi-Fi/Modem behavior:
  ```bash
  adb shell settings put global wifi_scan_always_enabled 1
  adb shell settings put global mobile_data_always_on 1
  ```

---

## 📁 Repository Structure

```text
├── configs/
│   ├── vip-exemptions.json           # Critical packages never restricted
│   ├── safe-shield-list.json         # Daily apps (Bucket 45 + No WakeLock)
│   └── recommended-freeze-list.json  # Heavy bloat & games for Hail freeze
├── docs/
│   ├── ARCHITECTURE.md               # Linux process tree, SIGHUP, & Ghost Mode
│   ├── PC_FREE_GUIDE.md              # Termux & Phone-to-Phone deployment
│   ├── OEM_COMPATIBILITY_MATRIX.md   # HyperOS, OneUI, ColorOS, Pixel quirks
│   └── TROUBLESHOOTING.md            # Re-kick after reboot & diagnostics
├── scripts/
│   ├── kickstart-universal.bat       # 1-Click Windows Runner
│   ├── ghostcore-setup.ps1           # Windows PowerShell bootstrapper
│   ├── ghostcore-setup.sh            # Linux / macOS / Termux bootstrapper
│   └── triage-packages.py            # Interactive Python package classifier
└── README.md
```

---

## 📜 License & Disclaimer
This project is open-source under the [MIT License](LICENSE). 
*Disclaimer: GhostCore utilizes official, documented Android SDK/ADB commands (`pm`, `appops`, `settings`, `am`). It does not modify system partitions or kernel binaries.*
