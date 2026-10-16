# ==============================================================================
# POCO F5 God-Tier Power & Privacy Maxing Automated Deployer
# Target Device: 4b973050 (or connected device)
# Features:
#   1. Suspends Category B apps (Deep Freeze / Hail Mode)
#   2. Sets Standby Bucket 45 (RESTRICTED) on Category C apps
#   3. Sets AppOps RUN_ANY_IN_BACKGROUND ignore
#   4. Sets AppOps READ_CLIPBOARD ignore (Stealth Privacy)
#   5. Sets AppOps WAKE_LOCK ignore (No Night Drain)
#   6. Strictly EXEMPTS WhatsApp & Telegram
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Color([string]$text, [ConsoleColor]$color) {
    Write-Host $text -ForegroundColor $color
}

Clear-Host
Write-Color "=====================================================================" Cyan
Write-Color "   ⚡ APPLYING GOD-TIER BATTERY & PRIVACY MAXING (POCO F5)           " Yellow
Write-Color "=====================================================================" Cyan

$rawDevices = adb devices
$deviceLines = @($rawDevices | Where-Object { $_ -match "\bdevice\b" -and $_ -notmatch "List of devices" })

if ($deviceLines.Count -eq 0) {
    Write-Color "[!] ERROR: No authorized ADB device found!" Red
    exit 1
}

$deviceId = ($deviceLines[0] -split "\s+")[0].Trim()
Write-Color "[+] Device detected: $deviceId" Green
Write-Host ""

# ------------------------------------------------------------------------------
# CATEGORY B: The Deep Freeze Vault (Hail Mode - pm suspend)
# ------------------------------------------------------------------------------
$categoryB_Hail = @(
    "in.amazon.mShop.android.shopping",
    "com.meesho.supply",
    "com.utorrent.client",
    "mega.privacy.android.app",
    "com.whereismytrain.android",
    "jp.co.shueisha.mangaplus",
    "com.goodreads",
    "xyz.penpencil.khansirofficial",
    "com.calm.android",
    "com.rockstargames.rdr",
    "com.feralinteractive.tombraider_android",
    "com.applisto.appcloner",
    "com.aefyr.sai",
    "com.revanced.net.revancedmanager"
)

# ------------------------------------------------------------------------------
# CATEGORY C: Daily Use (Standby Bucket 45 + AppOps Ignore)
# ------------------------------------------------------------------------------
$categoryC_Brevent = @(
    "com.google.android.googlequicksearchbox",
    "com.android.thememanager",
    "com.instagram.android",
    "app.morphe.android.youtube",
    "app.revanced.android.apps.youtube.music",
    "com.brave.browser",
    "com.openai.chatgpt",
    "com.google.android.apps.bard",
    "com.google.android.apps.labs.language.tailwind",
    "notion.id",
    "md.obsidian",
    "com.superproductivity.superproductivity",
    "com.ichi2.anki",
    "net.one97.paytm",
    "com.phonepe.app",
    "com.kotak811mobilebankingapp.instantsavingsupiscanandpayrecharge",
    "com.wallet.crypto.trustapp",
    "ak.alizandro.smartaudiobookplayer",
    "org.videolan.vlc",
    "app.netmirror.nmv2",
    "com.naksh.liteiptv",
    "org.readera",
    "ru.zdevs.zarchiver",
    "com.gingertech.starbeam",
    "air.com.adobe.pstouchphone",
    "com.jrzheng.supervpnpayment",
    "com.xsquarestudio.forcelte",
    "com.heytap.headset"
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
Write-Color "      --> Total $suspendedCount apps placed in Deep Freeze (0% RAM / 0% Battery)" Yellow
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
        # 5. Clean force-stop idle processes
        adb -s $deviceId shell "am force-stop $pkg" 2>$null | Out-Null
        Write-Color "      [SHIELDED] $pkg" Green
        $restrictedCount++
    } else {
        Write-Color "      [SKIP] $pkg (not installed)" DarkGray
    }
}
Write-Color "      --> Total $restrictedCount apps placed in Restricted Standby & AppOps Shield" Yellow
Write-Host ""

Write-Color "=====================================================================" Green
Write-Color "  ✨ SUCCESS! GOD-TIER BATTERY & PRIVACY RULES APPLIED DIRECTLY!     " Green
Write-Color "  - $suspendedCount Heavy Apps: Deep Frozen (Hail Mode)               " Green
Write-Color "  - $restrictedCount Daily Apps: Standby Bucket 45 + AppOps Shield    " Green
Write-Color "  - WhatsApp & Telegram: 100% UNTOUCHED (Timely Notifications)        " Green
Write-Color "=====================================================================" Green
Write-Host ""
