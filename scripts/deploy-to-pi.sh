#!/bin/bash
# HabitKit - Deployment Script for Raspberry Pi
# Deploys the application to /var/www/habitkit

set -e  # Exit on any error

APP_DIR="/var/www/habitkit/habit-kit-clone"
BACKEND_DIR="$APP_DIR/backend"
FRONTEND_DIR="$APP_DIR/frontend"

echo "🚀 HabitKit - Deployment Script"
echo "================================"
echo ""

# Check if app directory exists
if [ ! -d "$APP_DIR" ]; then
    echo "❌ Error: Application directory not found at $APP_DIR"
    echo "Please clone your repository first:"
    echo "  cd /var/www/habitkit"
    echo "  git clone <your-repo-url> habit-kit-clone"
    exit 1
fi

cd "$APP_DIR"

# Pull latest code
echo "📥 Pulling latest code from GitHub..."
git pull origin main

# Backend deployment
echo ""
echo "🔧 Deploying Backend..."
cd "$BACKEND_DIR"

# Create .env.production if it doesn't exist
if [ ! -f .env.production ]; then
    echo "🔐 Creating production environment file..."
    cat > .env.production << EOF
RAILS_ENV=production
SECRET_KEY_BASE=$(openssl rand -hex 64)
DATABASE_PASSWORD=habitkit_dev
EOF
    echo "✅ Created .env.production"
else
    echo "✅ .env.production already exists"
fi

# Install dependencies
echo "📦 Installing Ruby dependencies..."
bundle install --without development test

# Setup database
echo "🗄️  Setting up database..."
# Load environment variables from .env.production
export $(grep -v '^#' .env.production | xargs)

RAILS_ENV=production bundle exec rails db:create 2>/dev/null || true
RAILS_ENV=production bundle exec rails db:migrate
RAILS_ENV=production bundle exec rails db:seed 2>/dev/null || true

# Precompile assets (if any)
# RAILS_ENV=production bundle exec rails assets:precompile 2>/dev/null || true

# Frontend deployment
echo ""
echo "🎨 Deploying Frontend..."
cd "$FRONTEND_DIR"

# Install dependencies
echo "📦 Installing Node dependencies..."
npm ci --production=false

# Build production bundle
echo "🏗️  Building production bundle..."
npm run build

# Copy built files to nginx directory
echo "📋 Copying files to web server..."
sudo rm -rf /var/www/html/habitkit
sudo mkdir -p /var/www/html/habitkit
sudo cp -r dist/* /var/www/html/habitkit/

# Restart services
echo ""
echo "🔄 Restarting services..."
sudo systemctl restart habitkit-backend || echo "⚠️  Backend service not found (will create later)"
sudo systemctl restart nginx

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Frontend: http://localhost/"
echo "🔌 Backend: http://localhost:3001/graphql"
echo ""
