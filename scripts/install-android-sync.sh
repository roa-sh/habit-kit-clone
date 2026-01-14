#!/bin/bash

# Installation script for Android Usage Sync
# Run this on your Raspberry Pi to set up automatic syncing

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Android Usage Sync - Installation${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if running on Raspberry Pi
if [ ! -f /etc/rpi-issue ]; then
    echo -e "${YELLOW}Warning: This script is designed for Raspberry Pi${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo -e "${GREEN}Project root: $PROJECT_ROOT${NC}"

# Install dependencies
echo -e "\n${GREEN}[1/5] Installing dependencies...${NC}"
sudo apt-get update
sudo apt-get install -y adb python3 curl

# Create configuration file
echo -e "\n${GREEN}[2/5] Creating configuration file...${NC}"

if [ -f /etc/android-sync.conf ]; then
    echo -e "${YELLOW}Configuration file already exists. Backing up...${NC}"
    sudo cp /etc/android-sync.conf /etc/android-sync.conf.backup
fi

# Prompt for configuration
read -p "Enter your Android tablet's static IP (or press Enter to skip): " STATIC_IP
read -p "Enter your Android device hostname [default: android]: " DEVICE_NAME
DEVICE_NAME=${DEVICE_NAME:-android}

# Create config file
sudo tee /etc/android-sync.conf > /dev/null <<EOF
# Android Sync Configuration
# Generated on $(date)

# Your Android tablet's static IP (if configured)
ANDROID_STATIC_IP="${STATIC_IP}"

# Device hostname
ANDROID_DEVICE_NAME="${DEVICE_NAME}"

# Backend URL (adjust if needed)
BACKEND_URL="http://localhost:3000/api/usage"

# How many days of history to sync
DAYS_BACK=7
EOF

echo -e "${GREEN}✓ Configuration saved to /etc/android-sync.conf${NC}"

# Make sync script executable
echo -e "\n${GREEN}[3/5] Setting up sync script...${NC}"
chmod +x "$SCRIPT_DIR/sync-android-usage.sh"
echo -e "${GREEN}✓ Sync script is executable${NC}"

# Install systemd service and timer
echo -e "\n${GREEN}[4/5] Installing systemd service...${NC}"

# Update the ExecStart path in the service file
SERVICE_CONTENT=$(cat "$SCRIPT_DIR/systemd/android-sync.service" | sed "s|/home/pi/habit-kit-clone|$PROJECT_ROOT|g")
echo "$SERVICE_CONTENT" | sudo tee /etc/systemd/system/android-sync.service > /dev/null

sudo cp "$SCRIPT_DIR/systemd/android-sync.timer" /etc/systemd/system/android-sync.timer

sudo systemctl daemon-reload

echo -e "${GREEN}✓ Systemd files installed${NC}"

# Enable and start the timer
echo -e "\n${GREEN}[5/5] Enabling automatic sync...${NC}"
sudo systemctl enable android-sync.timer
sudo systemctl start android-sync.timer

echo -e "${GREEN}✓ Automatic sync enabled${NC}"

# Check status
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "\n${YELLOW}Timer Status:${NC}"
sudo systemctl status android-sync.timer --no-pager

echo -e "\n${GREEN}Next Steps:${NC}"
echo -e "1. Set up your Android tablet (see ANDROID_SYNC_GUIDE.md)"
echo -e "2. Test the connection: sudo systemctl start android-sync.service"
echo -e "3. Check logs: journalctl -u android-sync.service -f"
echo -e "\n${GREEN}Configuration file: ${NC}/etc/android-sync.conf"
echo -e "${GREEN}Sync script: ${NC}$SCRIPT_DIR/sync-android-usage.sh"
echo -e "${GREEN}Complete guide: ${NC}$SCRIPT_DIR/ANDROID_SYNC_GUIDE.md"

echo -e "\n${YELLOW}To test the sync now, run:${NC}"
echo -e "sudo systemctl start android-sync.service"
echo -e "journalctl -u android-sync.service -f"
