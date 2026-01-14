#!/bin/bash

# Android Usage Data Sync Script
# Syncs app usage data from Android tablet to Rails backend via ADB

set -e

# Configuration
BACKEND_URL="${BACKEND_URL:-http://localhost:3000/api/usage}"
TABLET_NAME="${ANDROID_DEVICE_NAME:-android}"
STATIC_IP="${ANDROID_STATIC_IP:-}"
ADB_PORT="${ANDROID_ADB_PORT:-5555}"  # Default to 5555, but can be overridden
LOG_FILE="/tmp/android-sync.log"
DAYS_BACK="${DAYS_BACK:-1}"  # Only sync today's data for frequent updates

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
}

# Check if ADB is installed
check_adb() {
    if ! command -v adb &> /dev/null; then
        error "ADB not found. Installing..."
        sudo apt-get update && sudo apt-get install -y adb
    fi
    log "ADB found: $(adb --version | head -1)"
}

# Method 1: Try static IP if configured
try_static_ip() {
    if [ -n "$STATIC_IP" ]; then
        log "Attempting connection to static IP: $STATIC_IP:$ADB_PORT"
        adb connect "$STATIC_IP:$ADB_PORT" 2>&1 | tee -a "$LOG_FILE"
        sleep 2
        if adb devices | grep -q "$STATIC_IP:$ADB_PORT"; then
            log "✓ Connected via static IP"
            return 0
        fi
    fi
    return 1
}

# Method 2: Try mDNS hostname
try_mdns() {
    log "Attempting mDNS resolution for ${TABLET_NAME}.local"

    # Try to resolve hostname
    if command -v avahi-resolve &> /dev/null; then
        RESOLVED_IP=$(avahi-resolve -4 -n "${TABLET_NAME}.local" 2>/dev/null | awk '{print $2}')
    elif command -v getent &> /dev/null; then
        RESOLVED_IP=$(getent hosts "${TABLET_NAME}.local" 2>/dev/null | awk '{print $1}')
    else
        RESOLVED_IP=$(ping -c 1 "${TABLET_NAME}.local" 2>/dev/null | grep -oP '(?<=\()[\d.]+(?=\))')
    fi

    if [ -n "$RESOLVED_IP" ]; then
        log "Resolved ${TABLET_NAME}.local to $RESOLVED_IP"
        adb connect "$RESOLVED_IP:5555" 2>&1 | tee -a "$LOG_FILE"
        sleep 2
        if adb devices | grep -q "$RESOLVED_IP:5555"; then
            log "✓ Connected via mDNS"
            return 0
        fi
    fi
    return 1
}

# Method 3: Scan network for device
scan_network() {
    log "Scanning local network for Android device..."

    # Get local subnet
    LOCAL_IP=$(ip route get 1 | awk '{print $7;exit}')
    SUBNET=$(echo "$LOCAL_IP" | cut -d. -f1-3)

    log "Scanning subnet: ${SUBNET}.0/24"

    # Try common IPs first (faster)
    for i in $(seq 100 150); do
        IP="${SUBNET}.${i}"
        (adb connect "$IP:5555" &> /dev/null && echo "$IP") &
    done

    sleep 5

    # Check which device connected
    CONNECTED=$(adb devices | grep -oP '[\d.]+:5555' | head -1)
    if [ -n "$CONNECTED" ]; then
        log "✓ Found device at $CONNECTED"
        return 0
    fi

    return 1
}

# Method 4: Check if already connected
check_existing_connection() {
    log "Checking for existing ADB connection..."

    # Check if any device is already connected (not offline)
    CONNECTED=$(adb devices | grep -v "List" | grep "device$" | awk '{print $1}')

    if [ -n "$CONNECTED" ]; then
        log "✓ Found existing connection: $CONNECTED"
        return 0
    fi

    return 1
}

# Connect to Android device using multiple methods
connect_device() {
    log "=== Attempting to connect to Android device ==="

    # Kill old ADB server
    adb kill-server 2>/dev/null || true
    adb start-server 2>&1 | tee -a "$LOG_FILE"

    # Try each method in order
    check_existing_connection && return 0
    try_static_ip && return 0
    try_mdns && return 0
    scan_network && return 0

    error "Failed to connect to Android device using all methods"
    return 1
}

# Extract usage data from Android
extract_usage_data() {
    log "=== Extracting app usage data ==="

    # Calculate time range (in milliseconds since epoch)
    END_TIME=$(date +%s000)
    START_TIME=$(date -d "$DAYS_BACK days ago" +%s000 2>/dev/null || date -v-${DAYS_BACK}d +%s000)

    log "Querying usage from $(date -d "@$((START_TIME/1000))" 2>/dev/null || date -r $((START_TIME/1000))) to now"

    # Get usage stats (this requires UsageStats permission on the device)
    USAGE_DATA=$(adb shell "dumpsys usagestats" 2>&1)

    if [ $? -ne 0 ]; then
        error "Failed to extract usage data"
        return 1
    fi

    # Parse the data into JSON format
    # This is a simplified parser - you may need to adjust based on your Android version
    PARSED_DATA=$(echo "$USAGE_DATA" | python3 -c '
import sys
import json
import re
from datetime import datetime

data = sys.stdin.read()
apps = {}

# Parse usage stats (format varies by Android version)
# Look for patterns like: package=com.app.name timeUsed=12345
for line in data.split("\n"):
    if "package=" in line:
        pkg_match = re.search(r"package=([^\s]+)", line)
        time_match = re.search(r"totalTimeInForeground=\"(\d+)\"", line)

        if pkg_match and time_match:
            package = pkg_match.group(1)
            time_ms = int(time_match.group(1))

            if time_ms > 0:  # Only include apps that were used
                apps[package] = {
                    "package": package,
                    "totalTimeMs": time_ms,
                    "totalTimeMinutes": round(time_ms / 60000, 2)
                }

result = {
    "timestamp": datetime.now().isoformat(),
    "apps": list(apps.values()),
    "totalApps": len(apps)
}

print(json.dumps(result, indent=2))
' 2>/dev/null)

    if [ -z "$PARSED_DATA" ]; then
        warn "No usage data found or parsing failed"
        return 1
    fi

    log "Successfully extracted data for $(echo "$PARSED_DATA" | grep -o '"totalApps": [0-9]*' | grep -o '[0-9]*') apps"
    echo "$PARSED_DATA"
    return 0
}

# Send data to backend
send_to_backend() {
    local DATA="$1"

    log "=== Sending data to backend ==="
    log "Backend URL: $BACKEND_URL"

    # Save to temporary file
    TEMP_FILE=$(mktemp)
    echo "$DATA" > "$TEMP_FILE"

    # Send to backend API
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BACKEND_URL" \
        -H "Content-Type: application/json" \
        -d "@$TEMP_FILE" 2>&1)

    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)

    rm "$TEMP_FILE"

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        log "✓ Data successfully sent to backend (HTTP $HTTP_CODE)"
        return 0
    else
        error "Failed to send data to backend (HTTP $HTTP_CODE)"
        error "Response: $BODY"
        return 1
    fi
}

# Main execution
main() {
    log "=========================================="
    log "Android Usage Data Sync - Starting"
    log "=========================================="

    check_adb

    if ! connect_device; then
        error "Could not connect to device. Exiting."
        exit 1
    fi

    USAGE_DATA=$(extract_usage_data)

    if [ -n "$USAGE_DATA" ]; then
        log "Usage data extracted successfully"

        # Save locally as backup
        BACKUP_FILE="/tmp/android-usage-$(date +%Y%m%d-%H%M%S).json"
        echo "$USAGE_DATA" > "$BACKUP_FILE"
        log "Backup saved to: $BACKUP_FILE"

        # Send to backend
        if send_to_backend "$USAGE_DATA"; then
            log "✓ Sync completed successfully"
        else
            warn "Backend sync failed, but data is backed up locally"
        fi
    else
        error "Failed to extract usage data"
        exit 1
    fi

    log "=========================================="
    log "Sync completed"
    log "=========================================="
}

# Run main function
main
