#!/bin/bash
# HabitKit - Deployment Script for Raspberry Pi
# Deploys the application to /var/www/habit-kit-clone

set -e  # Exit on any error

# Initialize rbenv and node (needed for cron jobs)
export HOME=$(eval echo ~${SUDO_USER:-$USER})
export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:/usr/local/bin:/usr/bin:/bin:$PATH"
eval "$(rbenv init - bash)" 2>/dev/null || true

# Add node/npm to PATH if installed
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" 2>/dev/null || true

APP_DIR="/var/www/habit-kit-clone"
BACKEND_DIR="$APP_DIR/backend"
FRONTEND_DIR="$APP_DIR/frontend"

echo "🚀 HabitKit - Deployment Script"
echo "================================"
echo ""

# Check if app directory exists
if [ ! -d "$APP_DIR" ]; then
    echo "❌ Error: Application directory not found at $APP_DIR"
    echo "Please clone your repository first:"
    echo "  cd /var/www"
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

# Create .env if it doesn't exist (dotenv-rails loads .env automatically)
if [ ! -f .env ]; then
    echo "🔐 Creating environment file..."
    cat > .env << EOF
RAILS_ENV=production
SECRET_KEY_BASE=$(openssl rand -hex 64)
DATABASE_PASSWORD=habitkit_dev
DATABASE_HOST=127.0.0.1
EOF
    echo "✅ Created .env"
else
    echo "✅ .env already exists"
fi

# Make start script executable
chmod +x "$APP_DIR/scripts/start-backend.sh"

# Install dependencies
echo "📦 Installing Ruby dependencies..."
bundle install --without development test

# Setup database
echo "🗄️  Setting up database..."
# Load environment variables from .env
export $(grep -v '^#' .env | xargs)

# Setup PostgreSQL user and password
echo "Setting up PostgreSQL user..."
sudo -u postgres psql << EOF
-- Create user if it doesn't exist
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'habitkit') THEN
    CREATE USER habitkit WITH PASSWORD '$DATABASE_PASSWORD';
  ELSE
    ALTER USER habitkit WITH PASSWORD '$DATABASE_PASSWORD';
  END IF;
END
\$\$;

-- Grant privileges
ALTER USER habitkit CREATEDB;
EOF

# Verify .env exists
if [ ! -f .env ]; then
  echo "❌ ERROR: .env file not found!"
  exit 1
fi

# Run all Rails database commands in a single context with environment loaded
echo "Running database setup..."
bash -c "
  # Load environment variables
  export \$(grep -v '^#' .env | xargs)

  # Create database
  echo 'Creating database...'
  bundle exec rails db:create 2>/dev/null || true

  # Run migrations
  echo 'Running migrations...'
  bundle exec rails db:migrate

  # Seed database
  echo 'Seeding database...'
  bundle exec rails db:seed 2>/dev/null || true

  echo 'Database setup complete!'
"

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
sudo rm -rf /var/www/html/habit-kit-clone
sudo mkdir -p /var/www/html/habit-kit-clone
sudo cp -r dist/* /var/www/html/habit-kit-clone/
sudo chown -R www-data:www-data /var/www/html/habit-kit-clone
sudo chmod -R 755 /var/www/html/habit-kit-clone

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
