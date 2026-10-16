# GhostCore Troubleshooting & Recovery Manual

## 1. What Happens After Rebooting the Phone?
Because GhostCore operates **100% non-root**, Android does not allow third-party daemons to auto-start with elevated permissions on boot.

### After a Reboot:
* **All frozen apps (Hail)**: Remain frozen safely.
* **All AppOps permissions & Standby Buckets**: Remain 100% intact!
* **Radio settings (`wifi_scan_always_enabled 0`)**: Remain 100% intact!
* **Only Shizuku & Brevent daemons need a 5-second re-kick**:
  * Simply plug your phone into PC and double-click `scripts/kickstart-universal.bat`.
  * OR run `./scripts/ghostcore-setup.sh` from Termux via Wireless ADB.

---

## 2. Did a Daemon Die? (Diagnostics)
Run this command from PC or Termux:
```bash
adb shell "ps -ef | grep -E 'brevent|shizuku'"
```
* **Healthy Output**:
  ```text
  shell 19018     1 0 ? 00:00:01 shizuku_server
  shell 27850     1 0 ? 00:00:00 brevent_daemon
  ```
  Notice the second column is `1` (PPID = 1, meaning reparented to init).

* **If Killed**:
  * Did you accidentally open the Shizuku or Brevent app UI and swipe it away from Recent Apps?
  * **Fix**: Re-run the bootstrap command and **do not open the app UI again**.

---

## 3. How to Instantly Unfreeze an App via Command Line
If an app is frozen in Hail and you need to access it immediately without opening Hail:
```bash
adb shell pm enable --user 0 <package_name>
```
*Example for Amazon*:
```bash
adb shell pm enable --user 0 in.amazon.mShop.android.shopping
```
The app icon will immediately reappear in your app drawer with all account logins intact.

---

## 4. Banking, UPI & Play Integrity Compatibility
* **Play Integrity (MEETS_DEVICE_INTEGRITY & MEETS_BASIC_INTEGRITY)**: **100% PASSED (GREEN)**.
* **Why**: The bootloader remains completely **locked**. Android kernel and `boot.img` remain **100% stock**. Magisk/KernelSU are not used.
* **Google Pay, PhonePe, Paytm, Banking Apps**: Work completely natively without any root-hiding or Zygisk modules.

---

## 5. WhatsApp & Instant Notification Guarantee
If you ever experience a delayed message on any app:
1. Ensure the app is in **Standby Bucket 5 (Exempted)**:
   ```bash
   adb shell am set-standby-bucket <package_name> 5
   ```
2. Ensure `WAKE_LOCK` is set to `allow`:
   ```bash
   adb shell cmd appops set <package_name> WAKE_LOCK allow
   ```
3. Never add the app to Brevent or Hail.
