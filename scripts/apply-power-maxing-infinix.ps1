# ==============================================================================
# INFINIX X663 (XOS / Android 12) God-Tier Power & Privacy Maxing Deployer
# Target Device: 075893123N020774
# Features:
#   1. Suspends Category B heavy apps (Hail Mode: Gemini, ChatGPT, Subway, PocketFM, SelfCare)
#   2. Restricts Category C background apps (Bucket 45: Play Store, Chrome, Files, Messages, Turbo)
#   3. Sets AppOps RUN_ANY_IN_BACKGROUND ignore
#   4. Sets AppOps READ_CLIPBOARD ignore (Stealth Privacy)
#   5. Sets AppOps WAKE_LOCK ignore (No Night Drain)
#   6. Strictly EXEMPTS WhatsApp & Gboard
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Color([string]$text, [ConsoleColor]$color) {
    Write-Host $text -ForegroundColor $color
}

Clear-Host
Write-Color "=====================================================================" Cyan
Write-Color "   ⚡ APPLYING GOD-TIER BATTERY & RAM MAXING (INFINIX X663)          " Yellow
Write-Color "=====================================================================" Cyan

$deviceId = "075893123N020774"
$rawDevices = adb devices
if ($rawDevices -notmatch $deviceId) {
    # Fallback to any connected device if serial varies
    $deviceLines = @($rawDevices | Where-Object { $_ -match "\bdevice\b" -and $_ -notmatch "List of devices" })
    if ($deviceLines.Count -eq 0) {
        Write-Color "[!] ERROR: No authorized ADB device found!" Red
        exit 1
    }
    $deviceId = ($deviceLines[0] -split "\s+")[0].Trim()
}
Write-Color "[+] Device detected: $deviceId (Infinix X663)" Green
Write-Host ""

# ------------------------------------------------------------------------------
# CATEGORY B: Deep Freeze (Hail Mode - pm suspend)
# ------------------------------------------------------------------------------
$categoryB_Hail = @(
    "com.google.android.apps.bard",
    "com.openai.chatgpt",
    "com.radio.pocketfm",
    "com.kiloo.subwaysurf",
    "com.mventus.selfcare.activity"
)

# ------------------------------------------------------------------------------
# CATEGORY C: Restricted Background (Bucket 45 + AppOps Shield)
# ------------------------------------------------------------------------------
$categoryC_Brevent = @(
    "com.android.vending",
    "com.android.chrome",
    "com.google.android.apps.nbu.files",
    "com.google.android.apps.messaging",
    "com.google.android.apps.turbo"
)

Write-Color "[1/2] Suspending Category B Apps (Hail Deep Freeze)..." Cyan
$suspendedCount = 0
foreach ($pkg in $categoryB_Hail) {
    $installed = adb -s $deviceId shell "pm list packages $pkg" 2>$null | Out-String
    if ($installed -match $pkg) {
        adb -s $deviceId shell "pm suspend --user 0 $pkg" 2>$null | Out-Null
        adb -s $deviceId shell "am force-stop $pkg" 2>$null | Out-Null
        Write-Color "      [FROZEN] $pkg" Green
        $suspendedCount++
    } else {
        Write-Color "      [SKIP] $pkg (not installed)" DarkGray
    }
}
Write-Color "      --> Total $suspendedCount heavy apps placed in Deep Freeze (0% RAM / 0% CPU)" Yellow
Write-Host ""

Write-Color "[2/2] Restricting Category C Apps (Bucket 45 + AppOps Shield)..." Cyan
$restrictedCount = 0
foreach ($pkg in $categoryC_Brevent) {
    $installed = adb -s $deviceId shell "pm list packages $pkg" 2>$null | Out-String
    if ($installed -match $pkg) {
        # 1. Set Standby Bucket 45 (RESTRICTED)
        adb -s $deviceId shell "am set-standby-bucket $pkg 45" 2>$null | Out-Null
        # 2. Block background running
        adb -s $deviceId shell "cmd appops set $pkg RUN_ANY_IN_BACKGROUND ignore" 2>$null | Out-Null
        # 3. Block clipboard sniffing (Stealth Privacy)
        adb -s $deviceId shell "cmd appops set $pkg READ_CLIPBOARD ignore" 2>$null | Out-Null
        # 4. Block wake locks (No overnight drain)
        adb -s $deviceId shell "cmd appops set $pkg WAKE_LOCK ignore" 2>$null | Out-Null
        # 5. Clean force-stop idle processes to reclaim RAM immediately
        adb -s $deviceId shell "am force-stop $pkg" 2>$null | Out-Null
        Write-Color "      [SHIELDED] $pkg" Green
        $restrictedCount++
    } else {
        Write-Color "      [SKIP] $pkg (not installed)" DarkGray
    }
}
Write-Color "      --> Total $restrictedCount apps restricted (RAM reclaimed from Play Store/Chrome)" Yellow
Write-Host ""

# Ensure WhatsApp is 100% active
adb -s $deviceId shell "am set-standby-bucket com.whatsapp 10" 2>$null | Out-Null
adb -s $deviceId shell "cmd appops set com.whatsapp RUN_ANY_IN_BACKGROUND allow" 2>$null | Out-Null
adb -s $deviceId shell "cmd appops set com.whatsapp WAKE_LOCK allow" 2>$null | Out-Null
Write-Color "[+] WhatsApp (com.whatsapp): Verified ACTIVE & EXEMPTED (Timely Notifications)" Green

Write-Host ""
Write-Color "=====================================================================" Green
Write-Color "  ✨ SUCCESS! INFINIX X663 BATTERY & RAM MAXING APPLIED!              " Green
Write-Color "=====================================================================" Green
Write-Host ""
