#!/system/bin/sh
# Wait for system boot to complete
while [ -z "$(getprop sys.boot_completed)" ]; do
    sleep 5
done

# =============================================
# SYSTEM & PERFORMANCE OPTIMIZATIONS
# =============================================

# Disable unnecessary logging and debug features
resetprop -n logcat.live disable
resetprop -n ro.kernel.checkjni 0
resetprop -n ro.kernel.android.checkjni 0
resetprop -n persist.android.strictmode 0
resetprop -n sys.wifitracing.started 0
resetprop -n debug.tracing.battery_stats.wifi 0
resetprop -n ro.config.nocheckin 1
resetprop -n ro.ril.disable.power.collapse 0

# Disable Qualcomm sensor logging (if not needed)
resetprop -n ro.qti.sensors.pedometer false
resetprop -n ro.qti.sensors.step_counter false
resetprop -n ro.qti.sensors.step_detector false
resetprop -n ro.qti.sensors.facing false
resetprop -n ro.qti.sensors.pick_up false

# Disable debug and crash logs
resetprop -n debug.mdpcomp.logs 0
resetprop -n debugtool.anrhistory 0
resetprop -n persist.brcm.ap_crash none
resetprop -n persist.brcm.cp_crash none
resetprop -n persist.brcm.log none
resetprop -n persist.sys.qc.sub.rdump.on 0
resetprop -n profiler.debugmonitor false
resetprop -n profiler.hung.dumpdobugreport false
resetprop -n profiler.launch false
resetprop -n persist.ims.disableDebugLogs 1

# WiFi optimizations
resetprop -n wifi.supplicant_scan_interval 1200  # Reduce WiFi scanning frequency

# MIUI-specific optimizations
resetprop -n debug.miui.perf.inspector 0

# Disable incremental build optimizations (if not needed)
resetprop -n debug.incremental.always_enable_read_timeouts_for_system_dataloaders 0
resetprop -n debug.incremental.enforce_readlogs_max_interval_for_system_dataloaders 0

# Enable FUSE passthrough for better I/O performance
resetprop -n persist.sys.fuse.passthrough.enable true

# =============================================
# LOGGING & DIAGNOSTIC CLEANUP
# =============================================

# Extract and disable log tags
current_props="$(getprop | cut -f1 -d ']')"
eval "$(echo "$current_props" | grep -F '[log.tag' | sed 's/\[/setprop persist./g' | sed 's/$/ S/g')"
eval "$(echo "$current_props" | grep -F '[persist.log.tag' | sed 's/\[persist./setprop /g' | sed 's/$/ S/g')"
eval "$(echo "$current_props" | grep 'log.tag' | sed 's/\[/setprop /g' | sed 's/$/ S/g')"

# Disable window logging (reduces overhead)
for f in $(dumpsys window | grep "^  Proto:" | sed 's/^  Proto: //' | tr ' ' '\n'; \
           dumpsys window | grep "^  Logcat:" | sed 's/^  Logcat: //' | tr ' ' '\n'); do
    wm logging disable "$f"
    wm logging disable-text "$f"
done
cmd window logging stop

# =============================================
# DEVICE CONFIG & SERVICE OPTIMIZATIONS
# =============================================

# Disable backup manager and telephony logging
device_config put activity_manager activity_start_pss_defer 999999999999999999
device_config put telephony max_logcat_lines 0
device_config put telephony max_logcat_lines_low_mem 0
device_config put activity_manager_native_boot use_freezer true
device_config put activity_manager use_compaction true
device_config set_sync_disabled_for_tests persistent

# Disable backup services
bmgr cancel backups
bmgr enable 0

# Disable foreground service notifications and idle maintenance
cmd activity fgs-notification-rate-limit enable
cmd activity idle-maintenance
cmd activity set-deterministic-uid-idle true
cmd activity untrack-associations

# Audio optimizations
cmd audio reset-sound-dose-timeout
cmd audio set-ringer-mode SILENT

# Disable autofill and content capture
cmd autofill destroy sessions
cmd autofill reset
cmd autofill set max_partitions 0
cmd autofill set max_visible_datasets 0
cmd content_capture destroy sessions
cmd content_capture set bind-instant-service-allowed false
cmd content_capture set default-service-enabled 0 false

# Storage and battery optimizations
cmd devicestoragemonitor force-not-low
cmd display set-user-disabled-hdr-types 1 2 3 4
cmd greezer enable false
cmd greezer unmonitor 0

# Disable location and time updates
cmd location_time_zone_manager stop
cmd network_time_update_service reset_server_config_for_tests

# Disable silent updates throttling (for faster updates)
cmd package set-silent-updates-policy --throttle-time "$(echo 2^62|bc)"

# Disable face-down detection and print services
cmd power set-face-down-detector false
cmd print set-bind-instant-service-allowed false

# Disable role qualification and SDK sandbox
cmd role set-bypassing-role-qualification false
cmd sdk_sandbox set-state --reset

# Disable shortcut throttling and reset config
cmd shortcut reset-all-throttling
cmd shortcut reset-config
cmd shortcut unload-user

# Disable time zone auto-detection (if not needed)
cmd time_zone_detector set_auto_detection_enabled true
cmd time_zone_detector set_auto_detection_enabled false

# Disable wearable sensing and WiFi optimizations
cmd wearable_sensing destroy-data-stream
cmd wifi reset-connected-score
cmd wifi set-connected-score 60
cmd wifi set-ipreach-disconnect disabled
cmd wifi set-network-selection-config disabled enabled -a 0
cmd wifi set-network-selection-config enabled disabled -a 0

# =============================================
# PROCESS & SERVICE MANAGEMENT
# =============================================

# Stop unnecessary system services
stop heapprofd
stop incidentd
stop mobile_log_d
stop tombstoned
stop traced
stop idd-logreader
stop idd-logreadermain
stop stats
stop dumpstate
stop vendor.tcpdump
stop vendor_tcpdump
stop vendor.cnss_diag
stop tcpdump
stop cnss_diag

# =============================================
# CPU & SCHEDULER OPTIMIZATIONS
# =============================================

# Adjust CPU shares for background processes
for cpuctl in /dev/cpuctl/; do
    echo "2" > "$cpuctl/background/cpu.shares"
    echo "2" > "$cpuctl/system-background/cpu.shares"
    echo "2" > "$cpuctl/system/cpu.shares"
    echo "2" > "$cpuctl/camera-daemon/cpu.shares"
    echo "2" > "$cpuctl/nnapi-hal/cpu.shares"
    echo "2" > "$cpuctl/dex2oat/cpu.shares"
done

# Enable prefer_idle for background tasks
for cpuidle in /dev/stune; do
    echo "1" > "$cpuidle/background/schedtune.prefer_idle"
    echo "1" > "$cpuidle/camera-daemon/schedtune.prefer_idle"
    echo "1" > "$cpuidle/nnapi-hal/schedtune.prefer_idle"
done

# Adjust scheduler relax domain levels
for cpuset in /dev/cpuset; do
    echo "1" > "$cpuset/background/sched_relax_domain_level"
    echo "1" > "$cpuset/restricted/sched_relax_domain_level"
    echo "2" > "$cpuset/camera-daemon/sched_relax_domain_level"
    echo "2" > "$cpuset/system-background/sched_relax_domain_level"
    echo "3" > "$cpuset/foreground/sched_relax_domain_level"
    echo "3" > "$cpuset/top-app/sched_relax_domain_level"
done

# Disable garbage collection for userdata
for gc in /dev/sys/fs/by-name/userdata/; do
    echo "1" > "$gc/gc_idle"
done

# Adjust block I/O idle settings
for blkio in /dev/blkio/; do
    echo "1" > "$blkio/blkio.group_idle"
    echo "1" > "$blkio/background/blkio.group_idle"
    echo "1" > "$blkio/background/blkio.weight"
done

# =============================================
# FILE SYSTEM OPTIMIZATIONS
# =============================================

# Run fstrim to optimize storage
busybox fstrim -v /system
busybox fstrim -v /vendor
busybox fstrim -v /system_ext

# =============================================
# APP OPTIMIZATIONS (USER & SYSTEM APPS)
# =============================================

echo
echo "=== APP TWEAKS ==="
echo

# Loop through all installed packages (system and user)
for a in $(cmd package list packages --all-users | cut -d ":" -f2); do
    for user_id in $(pm list users | cut -d "{" -f2 | cut -d ":" -f1); do
        echo "Processing app: $a (User: $user_id)"

        # Kill app process
        am kill "$a" 2>/dev/null

        # Set background restrictions (hibernation mode)
        am service-restart-backoff disable "$a" 2>/dev/null
        am set-bg-restriction-level --user "$user_id" "$a" hibernation 2>/dev/null
        am set-foreground-service-delegate --user "$user_id" "$a" stop 2>/dev/null

        # Ignore app and set to inactive
        am set-ignore-delivery-group-policy "$a" 2>/dev/null
        am set-inactive --user "$user_id" "$a" true 2>/dev/null
        am set-standby-bucket "$a" restricted 2>/dev/null

        # Clear logs and disable visibility
        logcat -c 2>/dev/null
        pm log-visibility "$a" --disable 2>/dev/null

        # Revoke unnecessary permissions (WiFi, sensors, location)
        pm revoke "$a" android.permission.ACCESS_WIFI_STATE 2>/dev/null
        pm revoke "$a" android.permission.BODY_SENSORS 2>/dev/null
        pm revoke "$a" android.permission.ACCESS_BACKGROUND_LOCATION 2>/dev/null

        # Permanently block WiFi permission for non-system apps
        if [[ "$a" != "com.android."* && "$a" != "com.google.android."* ]]; then
            pm revoke "$a" android.permission.ACCESS_WIFI_STATE 2>/dev/null
        fi
    done
done

# =============================================
# FINAL CLEANUP & STATUS
# =============================================

# Re-enable logcat.live (optional, for debugging)
resetprop -n logcat.live enable

echo
echo "=== OPTIMIZATIONS COMPLETE ==="
echo "All apps and services have been optimized for performance."
echo
