#!/bin/bash

# Quick test script for Android connection

set -e

TABLET_IP="${1:-192.168.40.150}"

echo "Testing Android connection..."
echo "Tablet IP: $TABLET_IP"
echo ""

# Kill old connections
echo "1. Killing old ADB server..."
adb kill-server
adb start-server

# Try to connect
echo ""
echo "2. Attempting to connect to $TABLET_IP:5555..."
adb connect "$TABLET_IP:5555"

sleep 2

# Check devices
echo ""
echo "3. Checking connected devices..."
adb devices -l

# Check if device is authorized
echo ""
if adb devices | grep -q "$TABLET_IP:5555.*device"; then
    echo "✅ SUCCESS! Device is connected and authorized"
    echo ""
    echo "Now try running the sync script:"
    echo "  export ANDROID_STATIC_IP=\"$TABLET_IP\""
    echo "  ./scripts/sync-android-usage.sh"
elif adb devices | grep -q "$TABLET_IP:5555.*unauthorized"; then
    echo "⚠️  Device is connected but UNAUTHORIZED"
    echo ""
    echo "Fix: Look at your tablet screen and tap 'Allow' on the USB debugging prompt"
    echo "     Check 'Always allow from this computer'"
else
    echo "❌ FAILED to connect"
    echo ""
    echo "Troubleshooting:"
    echo "1. Make sure tablet and Pi are on the same network"
    echo "2. Check tablet's IP: Settings → About → Status → IP address"
    echo "3. On tablet: Settings → Developer options → Wireless debugging (must be ON)"
    echo "4. Try pinging the tablet: ping $TABLET_IP"
fi
