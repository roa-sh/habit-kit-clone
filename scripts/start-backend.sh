#!/bin/bash
# Wrapper script to start Rails backend with proper Ruby environment

# Load rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Change to backend directory
cd /var/www/habitkit/habit-kit-clone/backend

# Load environment variables from .env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Start Rails server
exec bundle exec rails server -b 0.0.0.0 -p 3001 -e production

