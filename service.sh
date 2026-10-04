#!/system/bin/sh
# BlueAngel-SE Module - Optimized System Tweaks
# Version: 1.0

# Wait for boot completion (with timeout)
timeout=12
while [ -z "$(getprop sys.boot_completed)" ] && [ $timeout -gt 0 ]; do
    sleep 5
    timeout=$((timeout - 1))
done

# Basic logging function
LOG_DIR="/data/adb/batteryblueangel-se"
LOG_FILE="$LOG_DIR/batteryblueangel-se.log"

mkdir -p "$LOG_DIR" || exit 1
chown 0:2000 "$LOG_DIR"
chmod 0770 "$LOG_DIR"

if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE" || exit 1
    chmod 600 "$LOG_FILE"
fi
chown 0:2000 "$LOG_FILE"
chmod 0660 "$LOG_FILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE" 2>/dev/null
    echo "$1"
}

log "=== BlueAngel-SE Module Started ==="

# System optimizations with error handling
log "Applying system optimizations..."

safe_settings_put() {
    local key="$1"
    local value="$2"
    local success_msg="$3"
    local error_msg="$4"
    
    if settings put "$key" "$value" 2>/dev/null; then
        log "$success_msg"
        return 0
    else
        log "$error_msg"
        return 1
    fi
}

apply_optimizations() {
    safe_settings_put "system k2hd_effect" "1" "Enabled k2hd_effect" "Failed to enable k2hd_effect"
    safe_settings_put "system tube_amp_effect" "1" "Enabled tube_amp_effect" "Failed to enable tube_amp_effect"
    safe_settings_put "system dolby_enable" "1" "Enabled dolby_effect" "Failed to enable dolby_effect"
    safe_settings_put "global disable_window_blurs" "1" "Disabled window blurs" "Failed to disable window blurs"
    safe_settings_put "global accessibility_reduce_transparency" "1" "Reduced transparency" "Failed to reduce transparency"
    safe_settings_put "secure long_press_timeout" "250" "Set long_press_timeout to 250ms" "Failed to set long_press_timeout"
    safe_settings_put "secure multi_press_timeout" "250" "Set multi_press_timeout to 250ms" "Failed to set multi_press_timeout"
    safe_settings_put "secure tap_duration_threshold" "0.0" "Set tap_duration_threshold to 0.0" "Failed to set tap_duration_threshold"
    safe_settings_put "secure touch_blocking_period" "0.0" "Set touch_blocking_period to 0.0" "Failed to set touch_blocking_period"
    
    if setprop debug.force-opengl 1 2>/dev/null; then
        log "Forced OpenGL rendering"
    else
        log "Failed to force OpenGL rendering"
    fi
    
    safe_settings_put "system multicore_packet_scheduler" "1" "Enabled multicore packet scheduler" "Failed to enable multicore packet scheduler"
    safe_settings_put "global sem_enhanced_cpu_responsiveness" "1" "Enabled CPU responsiveness enhancement" "Failed to enable CPU responsiveness enhancement"
}

apply_optimizations || log "Some optimizations failed but continuing..."
l#!/system/bin/sh
# BlueAngel-SE Module - Optimized System Tweaks

# Wait for boot completion (with timeout)
timeout=12
while [ -z "$(getprop sys.boot_completed)" ] && [ $timeout -gt 0 ]; do
    sleep 5
    timeout=$((timeout - 1))
done

# Basic logging function
LOG_DIR="/data/adb/batteryblueangel-se"
LOG_FILE="$LOG_DIR/batteryblueangel-se.log"

mkdir -p "$LOG_DIR" || exit 1
chown 0:2000 "$LOG_DIR"
chmod 0770 "$LOG_DIR"

if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE" || exit 1
    chmod 600 "$LOG_FILE"
fi
chown 0:2000 "$LOG_FILE"
chmod 0660 "$LOG_FILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE" 2>/dev/null
    echo "$1"
}

log "=== BlueAngel-SE Module Started ==="

# =============================================
# SYSTEM INFO & DIAGNOSTICS (Logged)
# =============================================
uptime=$(cut -d. -f1 /proc/uptime)
memory=$(cat /proc/meminfo | tr -s ' ')
log "OS: Android $(getprop ro.build.version.release)"
log "Model: $(getprop ro.product.manufacturer) $(getprop ro.product.model)"
log "Kernel: $(uname -r | cut -f1,2,3 -d-)"
log "Uptime: $((uptime/3600)) hour(s), $((uptime%3600/60)) min(s)"

# =============================================
# SYSTEM & PERFORMANCE OPTIMIZATIONS
# =============================================
log "Applying system optimizations..."

safe_settings_put() {
    local key="$1"
    local value="$2"
    local success_msg="$3"
    local error_msg="$4"
    
    if settings put "$key" "$value" 2>/dev/null; then
        log "$success_msg"
        return 0
    else
        log "$error_msg"
        return 1
    fi
}

apply_optimizations() {
    safe_settings_put "system k2hd_effect" "1" "Enabled k2hd_effect" "Failed to enable k2hd_effect"
    safe_settings_put "system tube_amp_effect" "1" "Enabled tube_amp_effect" "Failed to enable tube_amp_effect"
    safe_settings_put "system dolby_enable" "1" "Enabled dolby_effect" "Failed to enable dolby_effect"
    safe_settings_put "global disable_window_blurs" "1" "Disabled window blurs" "Failed to disable window blurs"
    safe_settings_put "global accessibility_reduce_transparency" "1" "Reduced transparency" "Failed to reduce transparency"
    safe_settings_put "secure long_press_timeout" "250" "Set long_press_timeout to 250ms" "Failed to set long_press_timeout"
    safe_settings_put "secure multi_press_timeout" "250" "Set multi_press_timeout to 250ms" "Failed to set multi_press_timeout"
    safe_settings_put "secure tap_duration_threshold" "0.0" "Set tap_duration_threshold to 0.0" "Failed to set tap_duration_threshold"
    safe_settings_put "secure touch_blocking_period" "0.0" "Set touch_blocking_period to 0.0" "Failed to set touch_blocking_period"
    
    if setprop debug.force-opengl 1 2>/dev/null; then
        log "Forced OpenGL rendering"
    else
        log "Failed to force OpenGL rendering"
    fi
    
    safe_settings_put "system multicore_packet_scheduler" "1" "Enabled multicore packet scheduler" "Failed to enable multicore packet scheduler"
    safe_settings_put "global sem_enhanced_cpu_responsiveness" "1" "Enabled CPU responsiveness enhancement" "Failed to enable CPU responsiveness enhancement"

    # Additional performance settings from your script
    settings put global binder_calls_stats "sampling_interval=600000000,detailed_tracking=disable,enabled=false,upload_data=false"
    settings put global cached_apps_freezer 1
    settings put system haptic_feedback_disable 1
    settings put secure screensaver_activate_on_dock 0
    settings put secure screensaver_enabled 0

    # Battery & Idle constants
    settings put global battery_stats_constants track_cpu_active_cluster_time=false,read_binary_cpu_time=0,proc_state_cpu_times_read_delay_ms=5000000000,kernel_uid_readers_throttle_time=1,external_stats_collection_rate_limit_ms=0,battery_level_collection_delay_ms=30000000000,max_history_buffer_kb=1024,max_history_files=2
    settings put system device_idle_constants inactive_to=15000,sensing_to=30000,locating_to=30000,location_accuracy=20.0,motion_inactive_to=0,idle_after_inactive_to=0,idle_pending_to=60000,max_idle_pending_to=120000,idle_pending_factor=2.0,idle_to=900000,max_idle_to=86400000,idle_factor=2.0,min_time_to_alarm=600000,max_temp_app_whitelist_duration=10000
    settings put global activity_manager_constants memory_info_throttle_time=999999999999999999,full_pss_min_interval=999999999999999999,full_pss_lowered_interval=999999999999999999,power_check_interval=999999999999999999,usage_stats_interaction_interval=999999999999999999,usage_stats_interaction_interval_post_s=999999999999999999,service_usage_interaction_time=999999999999999999,service_usage_interaction_time_post_s=999999999999999999

    # Disable DropBox logging
    for db_item in APANIC_CONSOLE APANIC_THREADS BATTERY_DISCHARGE_INFO batterystats binder_calls_stats data_app_anr data_app_crash data_app_dumper data_app_lowmem data_app_native_crash data_app_native_recoverable_crash data_app_strictmode data_app_watchdog data_app_wtf diskstats DropBoxManagerLoggerBackend ecall_diagnostic_data graphicsstats imperceptible_app_kill keymaster looper_stats netstats network_watchlist_report powerstats procstats restricted_profile_ssaid stats storage_trim storagestats SubsystemRestart system_app_anr system_app_crash system_app_dumper system_app_lowmem system_app_native_crash system_app_native_recoverable_crash system_app_strictmode system_app_watchdog system_app_wtf SYSTEM_AUDIT SYSTEM_BOOT SYSTEM_FSCK SYSTEM_LAST_KMSG SYSTEM_RECOVERY_LOG SYSTEM_RESTART system_server_anr system_server_crash system_server_dumper system_server_lowmem system_server_native_crash system_server_native_recoverable_crash system_server_strictmode system_server_watchdog system_server_wtf SYSTEM_TOMBSTONE SYSTEM_TOMBSTONE_PROTO SYSTEM_TOMBSTONE_PROTO_WITH_HEADERS; do
        settings put global "dropbox:$db_item" disabled 2>/dev/null
    done

    cmd settings put global netstats_enabled 0
    sm defragment abort 2>/dev/null
    sm idle-maint run 2>/dev/null
    wm tracing level critical 2>/dev/null
    wm tracing size 0 2>/dev/null
}

apply_optimizations || log "Some optimizations failed but continuing..."
log "System optimizations completed"

# =============================================
# PERMISSION MANAGEMENT FUNCTIONS (APPOPS)
# =============================================
revoke_permission() {
    local package_name="$1"
    local permission="$2"
    local user="$3"
    
    cmd appops set --user "$user" "$package_name" "$permission" ignore 2>/dev/null
}

disable_run_in_background() {
    revoke_permission "$1" "RUN_IN_BACKGROUND" "$2"
}

disable_network_leaks() {
    local network_permissions="CHANGE_NETWORK_STATE ACCESS_WIFI_STATE CHANGE_WIFI_STATE READ_SYNC_SETTINGS WRITE_SYNC_SETTINGS ACCESS_BACKGROUND_LOCATION BLUETOOTH_SCAN BLUETOOTH_ADVERTISE NEARBY_WIFI_DEVICES UWB_RANGING ACCESS_NETWORK_STATE BLUETOOTH_CONNECT"
    for perm in $network_permissions; do
        revoke_permission "$1" "$perm" "$2"
    done
}

disable_phone_leaks() {
    local phone_permissions="ANSWER_PHONE_CALLS READ_PHONE_STATE READ_PHONE_NUMBERS MODIFY_PHONE_STATE READ_PRIVILEGED_PHONE_STATE READ_CALL_LOG SEND_SMS WRITE_CALL_LOG READ_SMS WRITE_CALENDAR WRITE_CONTACTS ADD_VOICEMAIL PROCESS_OUTGOING_CALLS RECEIVE_SMS RECEIVE_WAP_PUSH MANAGE_OWN_CALLS"
    for perm in $phone_permissions; do
        revoke_permission "$1" "$perm" "$2"
    done
}

disable_sensor_permission() {
    local sensor_permissions="ACTIVITY_RECOGNITION BODY_SENSORS BODY_SENSORS_BACKGROUND SENSORS USE_BIOMETRIC"
    for perm in $sensor_permissions; do
        revoke_permission "$1" "$perm" "$2"
    done
}

set_appop_custom() {
    local pkg="$1"
    local op="$2"
    local val="$3"
    if appops get "$pkg" "$op" >/dev/null 2>&1; then
        appops set "$pkg" "$op" "$val" 2>/dev/null
    fi
}

process_user_apps() {
    local user="$1"
    log "=== Scanning User: $user ==="
    
    local tmp_dir="/data/local/tmp/blueangel_$user"
    mkdir -p "$tmp_dir"
    
    cmd package list packages --user "$user" 2>/dev/null | sed 's/package://' | sort > "$tmp_dir/all.txt"
    cmd package list packages --user "$user" -s 2>/dev/null | sed 's/package://' | sort > "$tmp_dir/sys.txt"
    cmd package list packages --user "$user" -3 2>/dev/null | sed 's/package://' | sort > "$tmp_dir/third.txt"
    
    comm -23 "$tmp_dir/all.txt" "$tmp_dir/sys.txt" | comm -23 - "$tmp_dir/third.txt" > "$tmp_dir/sysuser.txt"
    
    # Process System-User Apps
    while read -r package; do
        [ -n "$package" ] || continue
        disable_network_leaks "$package" "$user"
        disable_phone_leaks "$package" "$user"
        disable_sensor_permission "$package" "$user"
    done < "$tmp_dir/sysuser.txt"
    
    # Process Pure System Apps
    while read -r package; do
        [ -n "$package" ] || continue
        disable_sensor_permission "$package" "$user"
    done < "$tmp_dir/sys.txt"
    
    # Process Third-Party Apps
    while read -r package; do
        [ -n "$package" ] || continue
        disable_run_in_background "$package" "$user"
        disable_network_leaks "$package" "$user"
        disable_phone_leaks "$package" "$user"
        disable_sensor_permission "$package" "$user"
        
        # Additional AppOps optimizations from your snippet
        set_appop_custom "$package" FOREGROUND_SERVICE_SPECIAL_USE ignore
        set_appop_custom "$package" GET_ACCOUNTS ignore
        set_appop_custom "$package" INSTANT_APP_START_FOREGROUND ignore
        set_appop_custom "$package" INTERACT_ACROSS_PROFILES deny
        set_appop_custom "$package" LOADER_USAGE_STATS ignore
    done < "$tmp_dir/third.txt"
    
    rm -rf "$tmp_dir"
}

# Main execution loop for all users
log "=== BlueAngel-SE Tweak all User Apps ==="
for user in $(cmd package list users 2>/dev/null | awk -F'[{:]' '{print $2}' | grep -E '^[0-9]+$'); do
    log "Processing User: $user"
    process_user_apps "$user" || log "Failed to process user $user"
done

log "=== BlueAngel-SE Module Completed ==="
