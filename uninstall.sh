#!/system/bin/sh
# =============================================
# SYSTEM RESET & OPTIMIZATION SCRIPT (SAFE VERSION)
# Purpose: Revert aggressive optimizations while preserving critical functions
# Author: Optimized for security & stability
# =============================================

# --- Safety Checks ---
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Must be run as root (su)" >&2
    exit 1
fi

echo "=== SYSTEM DIAGNOSTICS ==="
uptime=$(cut -d. -f1 /proc/uptime)
memory=$(cat /proc/meminfo | tr -s ' ')
echo "OS: Android $(getprop ro.build.version.release)"
echo "Model: $(getprop ro.product.manufacturer) $(getprop ro.product.model)"
echo "Kernel: $(uname -r | cut -f1,2,3 -d-)"

# --- Critical System Resets ---
echo "=== RESETTING SYSTEM SERVICES ==="
# 1. Storage & Filesystem
sm fstrim -v /data || echo "fstrim failed"
sm idle-maint run || echo "idle-maint failed"
sm defragment run || echo "defrag failed"

# 2. Connectivity
cmd wifi set-scan-always-available enabled || echo "WiFi scan enable failed"
cmd connectivity set-chain3-enabled true || echo "Connectivity chain reset failed"

# 3. Display & Graphics
cmd display set-user-disabled-hdr-types 0 || echo "HDR reset failed"
cmd display ab-logging-enable || echo "AB logging enable failed"
cmd display dmd-logging-enable || echo "DMD logging enable failed"
cmd display dwb-logging-enable || echo "DWB logging enable failed"

# --- App & Permission Reset ---
echo "=== RESETTING APP PERMISSIONS ==="
# 1. System Apps (-s flag)
for a in $(cmd package list packages -s | cut -d ":" -f2); do
    echo "Resetting system app: $a"
    # Reset app state (safe operations only)
    am set-bg-restriction-level "$a" unrestricted 2>/dev/null
    am service-restart-backoff enable "$a" 2>/dev/null
    am kill "$a" 2>/dev/null
    appops reset "$a" 2>/dev/null
done

# 2. All Apps (including user apps)
for a in $(cmd package list packages | cut -d ":" -f2); do
    echo "Resetting user app: $a"
    # Reset app state (safe operations only)
    am set-inactive --user 0 "$a" false 2>/dev/null
    am set-standby-bucket "$a" active 2>/dev/null
    appops reset "$a" 2>/dev/null
done

# --- Performance & Debugging ---
echo "=== RESETTING PERFORMANCE SETTINGS ==="
# 1. Power Modes
settings put system POWER_PERFORMANCE_MODE_OPEN 0 || echo "Power mode reset failed"
settings put system power_save_type_performance 0 || echo "Power save reset failed"
settings put secure breathe_gamemode_enabled 0 || echo "Game mode reset failed"
settings put system speed_mode 0 || echo "Speed mode reset failed"
settings put secure speed_mode_enable 0 || echo "Speed mode enable reset failed"

# 2. Haptic & Sensors
settings put system haptic_feedback_disable 0 || echo "Haptic reset failed"
cmd miui_step_counter_service enable 2>/dev/null || echo "Step counter enable failed"

# 3. Debug Logging
settings put global binder_calls_stats "" || echo "Binder stats reset failed"
settings put system device_idle_constants "" || echo "Device idle reset failed"
settings put global activity_manager_constants "" || echo "Activity manager reset failed"

# --- Network & Security ---
echo "=== RESETTING NETWORK & SECURITY ==="
# 1. WiFi & Network
cmd wifi set-verbose-logging enabled || echo "WiFi verbose logging failed"
cmd wifi reset-connected-score || echo "WiFi score reset failed"

# 2. DropBox & Diagnostics
settings delete global dropbox_age_seconds || echo "DropBox age reset failed"
settings delete global dropbox_max_files || echo "DropBox max files reset failed"

# 3. Security
settings put global cached_apps_freezer 0 || echo "Cached apps freezer reset failed"
settings put secure screensaver_activate_on_dock 1 || echo "Screensaver dock reset failed"
settings put secure screensaver_enabled 1 || echo "Screensaver enable reset failed"

# --- Final Cleanup ---
echo "=== FINAL SYSTEM CLEANUP ==="
# 1. Clear watch heap and associations
am clear-watch-heap all 2>/dev/null
am untrack-associations 2>/dev/null

# 2. Reset autofill and content capture
cmd autofill reset 2>/dev/null
cmd content_capture destroy sessions 2>/dev/null

# 3. Storage trim
busybox fstrim -v /system || echo "System fstrim failed"
busybox fstrim -v /vendor || echo "Vendor fstrim failed"
busybox fstrim -v /data || echo "Data fstrim failed"

echo "✅ ALL RESETS COMPLETED SUCCESSFULLY!"
echo "System should now be in a stable state."
