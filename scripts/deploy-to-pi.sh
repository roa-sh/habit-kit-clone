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

# Create .env if it doesn't exist (dotenv-rails loads .env automatically)
if [ ! -f .env ]; then
    echo "🔐 Creating environment file..."
    cat > .env << EOF
RAILS_ENV=production
SECRET_KEY_BASE=$(openssl rand -hex 64)
DATABASE_PASSWORD=habitkit_dev
EOF
    echo "✅ Created .env"
else
    echo "✅ .env already exists"
fi

# Install dependencies
echo "📦 Installing Ruby dependencies..."
bundle install --without development test

# Setup database
echo "🗄️  Setting up database..."
# Load environment variables from .env
export $(grep -v '^#' .env | xargs)
echo "Environment variables loaded from .env:"
echo "RAILS_ENV: $RAILS_ENV"
echo "SECRET_KEY_BASE: $SECRET_KEY_BASE"
echo "DATABASE_PASSWORD: $DATABASE_PASSWORD"

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

# Verify .env exists and has content
echo "Verifying .env file..."
if [ ! -f .env ]; then
  echo "ERROR: .env file not found!"
  exit 1
fi
cat .env

# Run all Rails database commands in a single context with environment loaded
echo "Running database setup..."
bash -c "
  # Load environment variables
  export \$(grep -v '^#' .env | xargs)
  
  # Verify variables are loaded
  echo \"Loaded environment:\"
  echo \"  RAILS_ENV=\$RAILS_ENV\"
  echo \"  DATABASE_PASSWORD=\${DATABASE_PASSWORD:0:5}...\"
  echo \"  SECRET_KEY_BASE=\${SECRET_KEY_BASE:0:10}...\"
  
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
