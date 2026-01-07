#!/bin/bash
# HabitKit - Setup systemd services
# Creates and enables services for auto-start on boot

set -e

APP_DIR="/var/www/habit-kit-clone"
# Get the actual user (not root) even when run with sudo
if [ -n "$SUDO_USER" ]; then
  USER="$SUDO_USER"
else
  USER=$(whoami)
fi

echo "⚙️  HabitKit - Setting up systemd services"
echo "=========================================="
echo "User for services: $USER"
echo ""

# Create backend service
echo "📝 Creating backend service..."
sudo tee /etc/systemd/system/habitkit-backend.service > /dev/null <<EOF
[Unit]
Description=HabitKit Rails Backend
After=network.target postgresql.service
Requires=postgresql.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$APP_DIR/backend
ExecStart=/bin/bash $APP_DIR/scripts/start-backend.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Create nginx configuration
echo "📝 Creating nginx configuration..."
sudo cp $APP_DIR/config/nginx.conf /etc/nginx/sites-available/habitkit

# Enable nginx site
sudo ln -sf /etc/nginx/sites-available/habitkit /etc/nginx/sites-enabled/habitkit
sudo rm -f /etc/nginx/sites-enabled/default

# Reload systemd
echo "🔄 Reloading systemd..."
sudo systemctl daemon-reload

# Enable services
echo "✅ Enabling services..."
sudo systemctl enable habitkit-backend
sudo systemctl enable nginx

# Start services
echo "🚀 Starting services..."
sudo systemctl start habitkit-backend
sudo systemctl restart nginx

echo ""
echo "✅ Services configured and started!"
echo ""
echo "📊 Service status:"
sudo systemctl status habitkit-backend --no-pager | head -3
sudo systemctl status nginx --no-pager | head -3
echo ""
echo "📝 Useful commands:"
echo "  View backend logs: sudo journalctl -u habitkit-backend -f"
echo "  Restart backend:   sudo systemctl restart habitkit-backend"
echo "  Restart nginx:     sudo systemctl restart nginx"
echo ""
