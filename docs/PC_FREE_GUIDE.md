# GhostCore PC-Free Deployment Guide: Android Without a Computer

You do **NOT** need a PC or Mac to install and run the GhostCore protocol. You can run the entire system directly on your Android phone using **Wireless ADB**, **Termux**, or via a **Secondary Phone / OTG cable**.

---

## Method 1: On-Device Self-Bootstrap (Single Phone via Wireless ADB)
*Works on Android 11, 12, 13, 14, and 15 (HyperOS, OneUI, OxygenOS, Pixel).*

### Prerequisites:
1. Connect to any Wi-Fi network (or your own second phone's hotspot).
2. Install **Termux** (from F-Droid or GitHub).
3. Install **Shizuku** and **Brevent** APKs.

### Step-by-Step Execution:

#### 1. Enable Wireless Debugging
1. Go to **Settings -> Developer Options**.
2. Turn on **Wireless Debugging** and tap on it.
3. Split screen or open Termux in floating window.
4. Tap **Pair device with pairing code**. You will see:
   * IP address and Pairing Port (e.g., `192.168.1.5:38475`)
   * 6-digit Wi-Fi pairing code (e.g., `123456`)

#### 2. Pair and Connect in Termux
Open Termux and run:
```bash
pkg update && pkg install android-tools git python -y

# Pair your device
adb pair 192.168.1.5:38475
# (Enter the 6-digit pairing code when prompted)

# Connect to the Wireless Debugging port (shown on main Wireless Debugging screen)
adb connect 192.168.1.5:41235
```

#### 3. Clone and Run GhostCore
```bash
git clone https://github.com/your-username/GhostCore.git
cd GhostCore
chmod +x scripts/*.sh

# Run the 1-click bootstrap
./scripts/ghostcore-setup.sh
```

---

## Method 2: Phone-to-Phone Setup (OTG or Friend's Phone)
If you cannot connect to Wi-Fi for Wireless Debugging, use a friend's or family member's phone:

### Hardware Needed:
* USB-C to USB-C cable (or standard USB cable + OTG adapter).

### Steps:
1. On **Phone A (Host / Friend's phone)**: Install **Termux** or **Bugjaeger**.
2. On **Phone B (Target / Your phone)**: Enable **USB Debugging** in Developer Options.
3. Connect both phones using the OTG cable.
4. On Phone B: Tap **"Always allow from this computer"** when prompted.
5. In Phone A's Termux:
   ```bash
   pkg install android-tools git python -y
   adb devices
   git clone https://github.com/your-username/GhostCore.git
   cd GhostCore
   ./scripts/ghostcore-setup.sh
   ```

---

## Method 3: AI-Assisted Interactive Triage (Antigravity in Termux)
If you want an autonomous AI agent to inspect your packages, interview you interactively, and customize rules for your daily routine:

1. In Termux, install Python and Antigravity CLI:
   ```bash
   pip install antigravity-cli
   ```
2. Export your free Google Gemini API key:
   ```bash
   export GEMINI_API_KEY="your-free-gemini-key"
   ```
3. Run the interactive agent:
   ```bash
   python scripts/triage-packages.py --interactive
   ```
4. The agent will inspect every installed app:
   * *"Do you use Amazon daily, or only when shopping?"* $\to$ Freezes into Hail.
   * *"Do you want WhatsApp messages instant?"* $\to$ Places in VIP Bucket 5.
   * *"Do you own a Xiaomi Laptop/Pad?"* $\to$ Suppresses `mi_connect_service` telemetry.

---

## The Immortal Invariant: Ghost Mode
After running the script on Termux or PC:
1. **Never open the Shizuku or Brevent app from your app drawer!**
2. Hide their app icons or place them in a folder.
3. Because their UI is never loaded into Recent Apps, OEM Task Killers (HyperOS `ProcessSceneCleaner`, Samsung OneUI Memory Cleaner) will **never detect them or kill them**. They run silently in the background until the phone is manually rebooted!
