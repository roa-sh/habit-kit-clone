#!/bin/bash

# Script to update the sync frequency on Raspberry Pi

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Updating Android Sync to run every minute...${NC}"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Copy new timer
sudo cp "$SCRIPT_DIR/systemd/android-sync.timer" /etc/systemd/system/android-sync.timer

# Update config to sync only today's data
if [ -f /etc/android-sync.conf ]; then
    sudo sed -i 's/DAYS_BACK=.*/DAYS_BACK=1/' /etc/android-sync.conf
    echo -e "${GREEN}✓ Updated DAYS_BACK to 1 in /etc/android-sync.conf${NC}"
fi

# Reload systemd
sudo systemctl daemon-reload

# Restart the timer
sudo systemctl restart android-sync.timer

echo -e "${GREEN}✓ Sync frequency updated to every minute${NC}"
echo -e "\n${YELLOW}Check status:${NC}"
echo -e "sudo systemctl status android-sync.timer"
echo -e "\n${YELLOW}Watch live updates:${NC}"
echo -e "journalctl -u android-sync.service -f"
