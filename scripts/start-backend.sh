#!/bin/bash
# Wrapper script to start Rails backend with proper Ruby environment

# Debug: Print environment
echo "HOME: $HOME"
echo "USER: $USER"
echo "PWD: $PWD"

# Use $HOME if set and valid, otherwise fallback to explicit path
if [ -n "$HOME" ] && [ "$HOME" != "/root" ] && [ -d "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
  eval "$($HOME/.rbenv/bin/rbenv init -)"
else
  # Fallback to explicit path
  export PATH="/home/roa-sh/.rbenv/bin:/home/roa-sh/.rbenv/shims:$PATH"
  eval "$(/home/roa-sh/.rbenv/bin/rbenv init -)"
fi

# Change to backend directory
cd /var/www/habitkit/habit-kit-clone/backend

# Load environment variables from .env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Verify Ruby is available
which ruby
ruby --version
which bundle

# Start Rails server
exec bundle exec rails server -b 0.0.0.0 -p 3001 -e production

