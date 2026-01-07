#!/bin/bash
# Wrapper script to start Rails backend with proper Ruby environment

echo "=== Environment Debug ==="
echo "HOME: $HOME"
echo "USER: $USER"
echo "PATH (before rbenv): $PATH"

# Load rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
echo "PATH (after adding rbenv/bin): $PATH"

# Check if rbenv exists
if [ -f "$HOME/.rbenv/bin/rbenv" ]; then
  echo "✅ rbenv found at $HOME/.rbenv/bin/rbenv"
  eval "$(rbenv init -)"
  echo "PATH (after rbenv init): $PATH"
else
  echo "❌ rbenv NOT found at $HOME/.rbenv/bin/rbenv"
  exit 1
fi

# Change to backend directory
cd /var/www/habit-kit-clone/backend

# Load environment variables from .env
echo ""
echo "=== Loading Environment Variables ==="
if [ -f .env ]; then
  echo "✅ .env file found"
  export $(grep -v '^#' .env | xargs)
  echo "RAILS_ENV: $RAILS_ENV"
  echo "DATABASE_HOST: $DATABASE_HOST"
  echo "SECRET_KEY_BASE: ${SECRET_KEY_BASE:0:20}..."
  echo "DATABASE_PASSWORD: ${DATABASE_PASSWORD:0:5}..."
else
  echo "❌ .env file NOT found"
  exit 1
fi

# Verify Ruby is available
echo ""
echo "=== Ruby/Bundle Check ==="
echo "Ruby path: $(which ruby)"
echo "Ruby version: $(ruby --version)"
echo "Bundle path: $(which bundle)"
echo "Bundle version: $(bundle --version)"

# Start Rails server
echo ""
echo "=== Starting Rails Server ==="
echo "Command: bundle exec rails server -b 0.0.0.0 -p 3001 -e production"
echo ""
exec bundle exec rails server -b 0.0.0.0 -p 3001 -e production

