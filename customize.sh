#!/system/bin/sh

# =============================================
# SYSTEM INFO & DIAGNOSTICS
# =============================================
uptime=$(cut -d. -f1 /proc/uptime)
memory=$(cat /proc/meminfo | tr -s ' ')
echo "OS: Android $(getprop ro.build.version.release)"
echo "Model: $(getprop ro.product.manufacturer) $(getprop ro.product.model)"
echo "Kernel: $(uname -r | cut -f1,2,3 -d-)"
echo "Uptime: $((uptime/3600)) hour(s), $((uptime%3600/60)) min(s)"
echo "Packages: $(cmd package list packages -s --user 0 | wc -l) (system), $(cmd package list packages -3 --user 0 | wc -l) (third-party)"
echo "Resolution: $(wm size | cut -d: -f2)"
echo "Theme: $(getprop ro.build.fingerprint | cut -f5 -d/ | cut -f1 -d:)"
echo "Terminal: $(dumpsys window | grep mTopFullscreenOpaqueWindowState | cut -f7 -d' ' | cut -f1 -d/)"
echo "CPU: $(getprop ro.soc.manufacturer) $(getprop ro.soc.model)"
echo "GPU: $(dumpsys SurfaceFlinger | grep GLES: | cut -f2 -d,)"
echo "Memory: $((($(echo "$memory" | grep MemTotal | cut -f2 -d' ')-$(echo "$memory" | grep MemAvailable | cut -f2 -d' '))/1024)) MiB / $((($(echo "$memory" | grep MemTotal | cut -f2 -d' '))/1024)) MiB"

# =============================================
# APP OPTIMIZATIONS (APP-OPS)
# =============================================
echo "Applying appops optimizations..."

# Function to safely set appops (avoids errors for non-existent ops)
set_appop() {
    local pkg="$1"
    local op="$2"
    local val="$3"
    if appops get "$pkg" "$op" >/dev/null 2>&1; then
        appops set "$pkg" "$op" "$val" || echo "   FAIL: $op"
    fi
}

# Optimize system apps (-s flag)
for a in $(cmd package list packages -s | cut -d ":" -f2); do
    echo "=================================================="
    echo "Tuning system app: $a"
    set_appop "$a" FOREGROUND_SERVICE_SPECIAL_USE ignore
    set_appop "$a" GET_ACCOUNTS ignore
    set_appop "$a" INSTANT_APP_START_FOREGROUND ignore
    set_appop "$a" INTERACT_ACROSS_PROFILES deny
    set_appop "$a" LOADER_USAGE_STATS ignore
    echo "Done tuning system app: $a"
done

# Optimize third-party apps (no -s flag)
for a in $(cmd package list packages | cut -d ":" -f2); do
    echo "=================================================="
    echo "Tuning third-party app: $a"
    set_appop "$a" FOREGROUND_SERVICE_SPECIAL_USE ignore
    set_appop "$a" GET_ACCOUNTS ignore
    set_appop "$a" INSTANT_APP_START_FOREGROUND ignore
    set_appop "$a" INTERACT_ACROSS_PROFILES deny
    set_appop "$a" LOADER_USAGE_STATS ignore
    echo "Done tuning third-party app: $a"
done

# =============================================
# SYSTEM & PERFORMANCE OPTIMIZATIONS
# =============================================
echo "Applying system optimizations..."

# Disable unnecessary services
settings put global binder_calls_stats "sampling_interval=600000000,detailed_tracking=disable,enabled=false,upload_data=false"
settings put global cached_apps_freezer 1
settings put system haptic_feedback_disable 1
settings put secure screensaver_activate_on_dock 0
settings put secure screensaver_enabled 0

# Disable simpleperf logging (reduces overhead)
simpleperf --log fatal --log-to-android-buffer 0

# Battery stats optimizations (keep non-zero to avoid stability issues)
settings put global battery_stats_constants \
    track_cpu_active_cluster_time=false, \
    read_binary_cpu_time=0, \
    proc_state_cpu_times_read_delay_ms=5000000000, \
    kernel_uid_readers_throttle_time=1, \
    external_stats_collection_rate_limit_ms=0, \
    battery_level_collection_delay_ms=30000000000, \
    max_history_buffer_kb=1024, \
    max_history_files=2

# Device idle optimizations (safer values to avoid breaking background tasks)
settings put system device_idle_constants \
    inactive_to=15000, \
    sensing_to=30000, \
    locating_to=30000, \
    location_accuracy=20.0, \
    motion_inactive_to=0, \
    idle_after_inactive_to=0, \
    idle_pending_to=60000, \
    max_idle_pending_to=120000, \
    idle_pending_factor=2.0, \
    idle_to=900000, \
    max_idle_to=86400000, \
    idle_factor=2.0, \
    min_time_to_alarm=600000, \
    max_temp_app_whitelist_duration=10000

# Activity manager optimizations (reduce logging overhead)
settings put global activity_manager_constants \
    memory_info_throttle_time=999999999999999999, \
    full_pss_min_interval=999999999999999999, \
    full_pss_lowered_interval=999999999999999999, \
    power_check_interval=999999999999999999, \
    usage_stats_interaction_interval=999999999999999999, \
    usage_stats_interaction_interval_post_s=999999999999999999, \
    service_usage_interaction_time=999999999999999999, \
    service_usage_interaction_time_post_s=999999999999999999

# Disable DropBox logging (reduces storage and CPU usage)
settings put global dropbox:APANIC_CONSOLE disabled
settings put global dropbox:APANIC_THREADS disabled
settings put global dropbox:BATTERY_DISCHARGE_INFO disabled
settings put global dropbox:batterystats disabled
settings put global dropbox:binder_calls_stats disabled
settings put global dropbox:data_app_anr disabled
settings put global dropbox:data_app_crash disabled
settings put global dropbox:data_app_dumper disabled
settings put global dropbox:data_app_lowmem disabled
settings put global dropbox:data_app_native_crash disabled
settings put global dropbox:data_app_native_recoverable_crash disabled
settings put global dropbox:data_app_strictmode disabled
settings put global dropbox:data_app_watchdog disabled
settings put global dropbox:data_app_wtf disabled
settings put global dropbox:diskstats disabled
settings put global dropbox:DropBoxManagerLoggerBackend disabled
settings put global dropbox:ecall_diagnostic_data disabled
settings put global dropbox:graphicsstats disabled
settings put global dropbox:imperceptible_app_kill disabled
settings put global dropbox:keymaster disabled
settings put global dropbox:looper_stats disabled
settings put global dropbox:netstats disabled
settings put global dropbox:network_watchlist_report disabled
settings put global dropbox:powerstats disabled
settings put global dropbox:procstats disabled
settings put global dropbox:restricted_profile_ssaid disabled
settings put global dropbox:stats disabled
settings put global dropbox:storage_trim disabled
settings put global dropbox:storagestats disabled
settings put global dropbox:SubsystemRestart disabled
settings put global dropbox:system_app_anr disabled
settings put global dropbox:system_app_crash disabled
settings put global dropbox:system_app_dumper disabled
settings put global dropbox:system_app_lowmem disabled
settings put global dropbox:system_app_native_crash disabled
settings put global dropbox:system_app_native_recoverable_crash disabled
settings put global dropbox:system_app_strictmode disabled
settings put global dropbox:system_app_watchdog disabled
settings put global dropbox:system_app_wtf disabled
settings put global dropbox:SYSTEM_AUDIT disabled
settings put global dropbox:SYSTEM_BOOT disabled
settings put global dropbox:SYSTEM_FSCK disabled
settings put global dropbox:SYSTEM_LAST_KMSG disabled
settings put global dropbox:SYSTEM_RECOVERY_LOG disabled
settings put global dropbox:SYSTEM_RESTART disabled
settings put global dropbox:system_server_anr disabled
settings put global dropbox:system_server_crash disabled
settings put global dropbox:system_server_dumper disabled
settings put global dropbox:system_server_lowmem disabled
settings put global dropbox:system_server_native_crash disabled
settings put global dropbox:system_server_native_recoverable_crash disabled
settings put global disable dropbox:system_server_strictmode disabled
settings put global dropbox:system_server_watchdog disabled
settings put global dropbox:system_server_wtf disabled
settings put global dropbox:SYSTEM_TOMBSTONE disabled
settings put global dropbox:SYSTEM_TOMBSTONE_PROTO disabled
settings put global dropbox:SYSTEM_TOMBSTONE_PROTO_WITH_HEADERS disabled

# Network stats optimizations
cmd settings put global netstats_enabled 0

# Storage optimizations
sm defragment abort
sm idle-maint run

# Window manager optimizations (reduce logging overhead)
wm tracing level critical
wm tracing size 0

echo "Optimizations complete! Enjoy your improved system. 😊"
