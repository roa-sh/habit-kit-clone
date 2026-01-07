#!/bin/bash
# HabitKit - Raspberry Pi Setup Script
# This script installs all dependencies needed to run HabitKit on your Pi

set -e  # Exit on any error

echo "🥧 HabitKit - Raspberry Pi Setup"
echo "=================================="
echo ""

# Check if running on Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null; then
    echo "⚠️  Warning: This doesn't appear to be a Raspberry Pi"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update system
echo "📦 Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install Ruby dependencies
echo "💎 Installing Ruby and dependencies..."
sudo apt install -y \
    ruby-full \
    ruby-dev \
    build-essential \
    libpq-dev \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev

# Install Node.js and npm
echo "📗 Installing Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
else
    echo "✅ Node.js already installed: $(node --version)"
fi

# Install PostgreSQL
echo "🐘 Installing PostgreSQL..."
sudo apt install -y postgresql postgresql-contrib

# Start and enable PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create PostgreSQL user
echo "👤 Creating PostgreSQL user..."
sudo -u postgres psql -c "CREATE USER habitkit WITH PASSWORD 'habitkit_dev';" 2>/dev/null || echo "User already exists"
sudo -u postgres psql -c "ALTER USER habitkit CREATEDB;" 2>/dev/null || true

# Install Bundler
echo "💎 Installing Bundler..."
sudo gem install bundler

# Create app directory
echo "📁 Creating application directory..."
sudo mkdir -p /var/www/habitkit
sudo chown -R $USER:$USER /var/www/habitkit

# Install nginx (for serving frontend)
echo "🌐 Installing Nginx..."
sudo apt install -y nginx

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Clone your repository: cd /var/www/habitkit && git clone <your-repo>"
echo "2. Run the deployment script: ./scripts/deploy-to-pi.sh"
echo ""


