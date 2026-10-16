# GhostCore OEM Compatibility Matrix

GhostCore is compatible with all Android devices running **Android 9.0 through Android 15.0+**. Below are OEM-specific architectural nuances and quirks.

| OEM / ROM | Compatibility | Specific Quirks & GhostCore Handling |
| :--- | :---: | :--- |
| **Xiaomi / Poco (HyperOS & MIUI)** | **100% (Verified)** | • **Quirk**: `ProcessSceneCleaner` kills background daemons if their app UI is swiped from Recent Apps.<br>• **Handling**: Enforce Ghost Mode (never open Shizuku/Brevent UI into Recents). Set Default USB configuration to "No data transfer" to avoid MTP disconnect SIGHUP. |
| **Transsion (Infinix / Tecno - XOS / HiOS)** | **100% (Verified)** | • **Quirk**: Native XOS does not kill PPID 1 daemons. Very dumb base scheduler.<br>• **Handling**: Achieves extreme deep sleep (97%+). Flashlight/sensors run cold. |
| **Samsung (OneUI 5 / 6 / 7)** | **100% (Verified)** | • **Quirk**: Samsung Device Care / RAM Plus puts apps to sleep aggressively.<br>• **Handling**: Standby Bucket 45 overrides Samsung's sleep delays without breaking OneUI services. |
| **OnePlus / Oppo / Realme (OxygenOS / ColorOS)** | **100% (Verified)** | • **Quirk**: Aggressive battery optimization toggles in Settings.<br>• **Handling**: Set Brevent and Shizuku to "Don't optimize" in battery settings before detaching daemons. |
| **Google Pixel (Stock AOSP 14 / 15)** | **100% (Verified)** | • **Quirk**: Native Doze mode is conservative (takes 30-60 mins to enter deep idle).<br>• **Handling**: Setting `wifi_scan_always_enabled 0` and `mobile_data_always_on 0` significantly cuts idle standby drain. |
| **Vivo / iQOO (Funtouch OS / OriginOS)** | **100% (Verified)** | • **Quirk**: High Background Power Consumption warning.<br>• **Handling**: Whitelist Shizuku/Brevent in "High background power consumption" menu. |
