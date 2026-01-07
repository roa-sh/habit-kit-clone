#!/bin/bash
# HabitKit - Setup systemd services
# Creates and enables services for auto-start on boot

set -e

APP_DIR="/var/www/habitkit/habit-kit-clone"
USER=$(whoami)

echo "⚙️  HabitKit - Setting up systemd services"
echo "=========================================="
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
EnvironmentFile=$APP_DIR/backend/.env.production
Environment="RAILS_ENV=production"
Environment="PORT=3001"
ExecStart=/bin/bash -lc 'cd $APP_DIR/backend && bundle exec rails server -b 0.0.0.0 -p 3001 -e production'
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Create nginx configuration
echo "📝 Creating nginx configuration..."
sudo tee /etc/nginx/sites-available/habitkit > /dev/null <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/html/habitkit;
    index index.html;
    
    server_name _;
    
    # Frontend (React app)
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    # Backend API proxy
    location /graphql {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    
    location /graphiql {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

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
