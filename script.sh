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
log "System optimizations completed"

# Permission management functions
revoke_permission() {
    local package_name="$1"
    local permission="$2"
    local user="$3"
    
    log "Revoking $permission for: $package_name (User $user)"
    cmd appops set --user "$user" "$package_name" "$permission" ignore 2>/dev/null || log "Failed to revoke $permission for $package_name"
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

# Package processing function
process_user_apps() {
    local user="$1"
    log "=== Scanning User: $user ==="
    
    local tmp_dir="/data/local/tmp/blueangel_$user"
    mkdir -p "$tmp_dir"
    
    cmd package list packages --user "$user" 2>/dev/null | sed 's/package://' | sort > "$tmp_dir/all.txt"
    cmd package list packages --user "$user" -s 2>/dev/null | sed 's/package://' | sort > "$tmp_dir/sys.txt"
    cmd package list packages --user "$user" -3 2>/dev/null | sed 's/package://' | sort > "$tmp_dir/third.txt"
    
    comm -23 "$tmp_dir/all.txt" "$tmp_dir/sys.txt" | comm -23 - "$tmp_dir/third.txt" > "$tmp_dir/sysuser.txt"
    
    while read -r package; do
        [ -n "$package" ] || continue
        disable_network_leaks "$package" "$user"
        disable_phone_leaks "$package" "$user"
        disable_sensor_permission "$package" "$user"
    done < "$tmp_dir/sysuser.txt"
    
    while read -r package; do
        [ -n "$package" ] || continue
        disable_sensor_permission "$package" "$user"
    done < "$tmp_dir/sys.txt"
    
    while read -r package; do
        [ -n "$package" ] || continue
        disable_run_in_background "$package" "$user"
        disable_network_leaks "$package" "$user"
        disable_phone_leaks "$package" "$user"
        disable_sensor_permission "$package" "$user"
    done < "$tmp_dir/third.txt"
    
    rm -rf "$tmp_dir"
}

# Main execution loop
log "=== BlueAngel-SE Tweak all User Apps ==="
for user in $(cmd package list users 2>/dev/null | awk -F'[{:]' '{print $2}' | grep -E '^[0-9]+$'); do
    log "Processing User: $user"
    process_user_apps "$user" || log "Failed to process user $user"
done

log "=== BlueAngel-SE Module Completed ==="