# HabitKit Clone - Comprehensive Development Prompt

## 1. PROJECT OVERVIEW

Create a full-stack **mobile-first habit tracking Progressive Web App (PWA)** that replicates the functionality and aesthetics of the HabitKit app shown in the provided screenshots. This application must be accessible as a native-like experience on mobile devices while maintaining the same mobile interface when accessed from desktop browsers.

### Core Purpose
- Track daily habits with visual feedback
- Allow users to mark habits as complete/incomplete for any day
- Provide detailed calendar views for each habit
- Support habit creation with customization options
- Customize compact list view (days displayed, name visibility)
- Deliver a seamless, native-app-like experience on mobile devices

### Key Technical Decisions

**🔴 CRITICAL ARCHITECTURAL CHOICES:**

1. **GraphQL API (Not REST)**
   - Backend uses GraphQL Ruby with Apollo Server
   - Frontend uses Apollo Client for all data fetching
   - Single endpoint: `/graphql`
   - Queries, mutations, and subscriptions supported
   - Real-time cache updates via Apollo Client

2. **Completion States Enum System**
   - Habits support 5 states: `NOT_STARTED`, `IN_PROGRESS`, `COMPLETED`, `SKIPPED`, `FAILED`
   - Stored in JSON array with state field
   - Easily extensible for future features
   - MVP uses toggle between NOT_STARTED ↔ COMPLETED
   - Backend validates against enum, frontend can add UI for other states later

3. **Backend Date/Time Awareness**
   - Always use `Date.current` and `Time.current` (never `.today` or `.now`)
   - Backend knows current server date/time for all operations
   - Timezone configured in `config/application.rb`
   - Client can query `currentServerDate` and `currentServerTime` for sync
   - All completion timestamps stored with timezone info

---

## 2. TECHNOLOGY STACK & INSTALLATION

### Backend Stack
- **Ruby on Rails** (v6.1.7 or higher)
- **Ruby** v3.1.3
- **PostgreSQL** (production & development database)
- **Puma** web server
- **GraphQL Ruby** v2.0+ (GraphQL server implementation)
- **graphql-batch** (for query batching and N+1 prevention)
- **Rack CORS** for cross-origin requests

### Frontend Stack
- **React** v18.2+
- **Vite** v5+ (build tool and dev server)
- **Apollo Client** v3.8+ (GraphQL client)
- **GraphQL** v16+ (GraphQL query language)
- **TailwindCSS** v3.3+ (styling framework)
- **PostCSS** & **Autoprefixer** (CSS processing)

### UI/Animation Libraries
- **Framer Motion** v12+ (animations and transitions)
- **Lucide React** v0.294+ (icon system - widely adopted, MIT licensed)
- **date-fns** v2.30+ (date manipulation)

### PWA Configuration
- **vite-plugin-pwa** v0.17+ (service worker generation)
- **workbox-window** v7+ (service worker management)

### Development Tools
- **ESLint** (code quality)
- **GraphQL Code Generator** (optional, for TypeScript types)
- Node.js v18+ (for frontend tooling)
- PostgreSQL client libraries

---

## 3. PROJECT INITIALIZATION & SETUP

### Step 1: Environment Prerequisites Check
```bash
# Verify installations before proceeding
ruby --version          # Should show 3.1.3 or compatible
rails --version         # Should show 6.1.7+
node --version          # Should show 18+
npm --version           # Should show 9+
psql --version          # Should show PostgreSQL 12+

# If PostgreSQL is not installed:
# macOS: brew install postgresql
# Ubuntu: sudo apt-get install postgresql postgresql-contrib
# Start PostgreSQL service after installation
```

### Step 2: Project Structure Setup
```bash
# Create main project directory
mkdir habitkit-clone
cd habitkit-clone

# Initialize Rails API backend
rails new backend --api --database=postgresql --skip-test
cd backend

# Initialize React frontend
cd ..
npm create vite@latest . -- --template react
# When prompted, use current directory
```

### Step 3: Backend Configuration

#### Database Setup (config/database.yml)
```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: localhost
  username: <%= ENV.fetch("POSTGRES_USER") { "postgres" } %>
  password: <%= ENV.fetch("POSTGRES_PASSWORD") { "" } %>

development:
  <<: *default
  database: habitkit_development

test:
  <<: *default
  database: habitkit_test

production:
  <<: *default
  database: habitkit_production
  username: habitkit
  password: <%= ENV['HABITKIT_DATABASE_PASSWORD'] %>
```

#### Gemfile Dependencies
```ruby
source 'https://rubygems.org'
ruby '3.1.3'

gem 'rails', '~> 6.1.7'
gem 'pg', '~> 1.4'
gem 'puma', '~> 5.0'
gem 'rack-cors'

# GraphQL
gem 'graphql', '~> 2.0'
gem 'graphql-batch', '~> 0.5'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-rails'
  gem 'graphiql-rails'  # GraphQL IDE for development
end

group :development do
  gem 'listen', '~> 3.3'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
```

#### CORS Configuration (config/initializers/cors.rb)
```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:5173', /^http:\/\/192\.168\.\d+\.\d+:5173$/, /^http:\/\/.*\.local:5173$/
    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: false
  end
end
```

### Step 4: Frontend Configuration

#### Package.json Scripts
```json
{
  "name": "habitkit-clone",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite --host",
    "build": "vite build",
    "preview": "vite preview --host",
    "lint": "eslint . --ext js,jsx --report-unused-disable-directives --max-warnings 0"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@apollo/client": "^3.8.0",
    "graphql": "^16.8.0",
    "framer-motion": "^12.0.0",
    "lucide-react": "^0.294.0",
    "date-fns": "^2.30.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.2.1",
    "vite": "^5.0.8",
    "vite-plugin-pwa": "^0.17.4",
    "workbox-window": "^7.0.0",
    "tailwindcss": "^3.3.6",
    "postcss": "^8.4.32",
    "autoprefixer": "^10.4.16",
    "eslint": "^8.55.0",
    "eslint-plugin-react": "^7.33.2",
    "eslint-plugin-react-hooks": "^4.6.0"
  }
}
```

#### Vite Configuration (vite.config.js)
```javascript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.ico', 'icon-192.png', 'icon-512.png'],
      manifest: {
        name: 'HabitKit Clone',
        short_name: 'HabitKit',
        description: 'Track your daily habits with ease',
        theme_color: '#a855f7',
        background_color: '#0a0a0a',
        display: 'standalone',
        orientation: 'portrait',
        scope: '/',
        start_url: '/',
        icons: [
          {
            src: 'icon-192.png',
            sizes: '192x192',
            type: 'image/png'
          },
          {
            src: 'icon-512.png',
            sizes: '512x512',
            type: 'image/png',
            purpose: 'any maskable'
          }
        ]
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'google-fonts-cache',
              expiration: {
                maxEntries: 10,
                maxAgeSeconds: 60 * 60 * 24 * 365
              }
            }
          }
        ]
      }
    })
  ],
  server: {
    host: true,
    port: 5173,
    strictPort: true
  }
})
```

#### TailwindCSS Configuration (tailwind.config.js)
```javascript
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  darkMode: 'class',
  theme: {
    screens: {
      xs: '375px',
      sm: '428px',
      md: '768px',
      lg: '1024px'
    },
    extend: {
      colors: {
        dark: {
          bg: '#0a0a0a',
          card: '#1a1a1a',
          border: '#2a2a2a',
          text: {
            primary: '#ffffff',
            secondary: '#a0a0a0',
            muted: '#666666'
          }
        },
        habit: {
          purple: '#a855f7',
          red: '#ef4444',
          blue: '#3b82f6',
          green: '#10b981',
          yellow: '#f59e0b',
          pink: '#ec4899',
          indigo: '#6366f1',
          teal: '#14b8a6',
          orange: '#f97316',
          gray: '#6b7280'
        }
      },
      animation: {
        'slide-up': 'slideUp 0.3s cubic-bezier(0.32, 0.72, 0, 1)',
        'slide-down': 'slideDown 0.3s cubic-bezier(0.32, 0.72, 0, 1)',
        'fade-in': 'fadeIn 0.2s ease-out',
        'scale-in': 'scaleIn 0.2s cubic-bezier(0.32, 0.72, 0, 1)'
      },
      keyframes: {
        slideUp: {
          '0%': { transform: 'translateY(100%)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' }
        },
        slideDown: {
          '0%': { transform: 'translateY(-100%)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' }
        },
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' }
        },
        scaleIn: {
          '0%': { transform: 'scale(0.95)', opacity: '0' },
          '100%': { transform: 'scale(1)', opacity: '1' }
        }
      },
      backdropBlur: {
        xs: '2px',
        sm: '4px',
        md: '12px',
        lg: '16px',
        xl: '24px'
      }
    }
  },
  plugins: []
}
```

#### PostCSS Configuration (postcss.config.js)
```javascript
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {}
  }
}
```

### Step 5: Startup Scripts

#### Development Startup Script (start-dev.sh)
```bash
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starting HabitKit Clone Development Servers...${NC}\n"

# Start Rails backend
echo -e "${GREEN}Starting Rails API on port 3001...${NC}"
cd backend && rails server -p 3001 &
RAILS_PID=$!

# Wait for Rails to start
sleep 3

# Start Vite frontend
echo -e "${GREEN}Starting Vite dev server on port 5173...${NC}"
cd .. && npm run dev &
VITE_PID=$!

echo -e "\n${BLUE}Servers running:${NC}"
echo -e "  Frontend: http://localhost:5173"
echo -e "  Backend API: http://localhost:3001/api/v1"
echo -e "\n${BLUE}Press Ctrl+C to stop all servers${NC}\n"

# Handle Ctrl+C
trap "kill $RAILS_PID $VITE_PID; exit" INT

# Wait for both processes
wait
```

Make executable: `chmod +x start-dev.sh`

---

## 4. DATABASE SCHEMA & MODELS

### Backend Date/Time Awareness

**CRITICAL**: The backend must always be aware of the current date and time for proper habit tracking:
- All date operations should use `Date.current` (Rails, respects timezone)
- All datetime operations should use `Time.current` or `DateTime.current`
- Configure timezone in `config/application.rb`: `config.time_zone = 'UTC'` (or user's timezone)
- Never use `Date.today`, `Time.now`, or `DateTime.now` (these use system time, not Rails time)
- Store all dates in UTC, convert to user's timezone when displaying
- Backend should track when habits are completed relative to the server's configured timezone

### Database Migrations

#### Create Completion States Enum
```ruby
# db/migrate/YYYYMMDDHHMMSS_create_completion_states.rb
class CreateCompletionStates < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE completion_state AS ENUM (
        'not_started',
        'in_progress', 
        'completed',
        'skipped',
        'failed'
      );
    SQL
  end
  
  def down
    execute <<-SQL
      DROP TYPE completion_state;
    SQL
  end
end
```

#### Create Habits Table
```ruby
# db/migrate/YYYYMMDDHHMMSS_create_habits.rb
class CreateHabits < ActiveRecord::Migration[6.1]
  def change
    create_table :habits do |t|
      t.string :external_id, null: false, index: { unique: true }
      t.string :name, null: false
      t.text :description
      t.string :emoji, default: '⚡'
      t.string :color, default: '#a855f7'
      t.string :streak_goal, default: 'none' # none, daily, weekly, monthly
      t.json :completions, default: []
      t.integer :current_streak, default: 0
      t.integer :longest_streak, default: 0
      t.timestamps
    end
    
    add_index :habits, :created_at
    add_index :habits, :updated_at
  end
end
```

#### Create User Settings Table
```ruby
# db/migrate/YYYYMMDDHHMMSS_create_user_settings.rb
class CreateUserSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :user_settings do |t|
      t.string :external_id, null: false, index: { unique: true }
      t.integer :compact_days, default: 5, null: false
      t.boolean :show_habit_names, default: true, null: false
      t.timestamps
    end
    
    add_check_constraint :user_settings, "compact_days >= 1 AND compact_days <= 7", 
                         name: "check_compact_days_range"
  end
end
```

**Note on Completions JSON Structure:**
Each completion entry in the `completions` JSON array should have:
```json
{
  "date": "2024-01-15",
  "state": "completed",
  "completed_at": "2024-01-15T14:32:00Z",
  "notes": "optional notes"
}
```

States can be: `not_started`, `in_progress`, `completed`, `skipped`, `failed`

### UserSettings Model (app/models/user_settings.rb)
```ruby
class UserSettings < ApplicationRecord
  # Validations
  validates :external_id, presence: true, uniqueness: true
  validates :compact_days, presence: true, 
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 7 }
  validates :show_habit_names, inclusion: { in: [true, false] }
  
  # Callbacks
  before_validation :set_defaults, on: :create
  
  # Singleton pattern - only one settings record per app
  # In the future, this can be expanded to per-user settings
  def self.current
    first_or_create!(external_id: 'default-settings')
  end
  
  private
  
  def set_defaults
    self.external_id ||= 'default-settings'
    self.compact_days ||= 5
    self.show_habit_names = true if self.show_habit_names.nil?
  end
end
```

### Application Time Configuration (config/application.rb)
```ruby
module HabitkitClone
  class Application < Rails::Application
    # Set timezone (use UTC or user's timezone)
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc
    
    # Always use Time.current instead of Time.now
    config.active_support.remove_deprecated_time_with_zone_name = true
  end
end
```

### Habit Model (app/models/habit.rb)
```ruby
class Habit < ApplicationRecord
  # Constants
  STREAK_GOALS = ['none', 'daily', 'weekly', 'monthly'].freeze
  
  # Completion states enum (stored in JSON, but validated)
  COMPLETION_STATES = ['not_started', 'in_progress', 'completed', 'skipped', 'failed'].freeze
  
  # Validations
  validates :external_id, presence: true, uniqueness: true
  validates :name, presence: true, length: { minimum: 1, maximum: 100 }
  validates :color, presence: true, format: { with: /\A#[0-9A-Fa-f]{6}\z/ }
  validates :streak_goal, inclusion: { in: STREAK_GOALS }
  validates :emoji, presence: true
  
  # Callbacks
  before_validation :set_defaults, on: :create
  after_save :update_streaks
  
  # Scopes
  scope :ordered, -> { order(created_at: :desc) }
  scope :active, -> { where("updated_at >= ?", 30.days.ago) }
  
  # Instance Methods
  
  # Get completion state for a specific date
  def state_on(date)
    date_string = date.to_s
    completion = completions.find { |c| c['date'] == date_string }
    completion ? completion['state'] : 'not_started'
  end
  
  # Check if habit is completed on a specific date
  def completed_on?(date)
    state_on(date) == 'completed'
  end
  
  # Update completion state for a specific date
  # IMPORTANT: Uses Time.current for timestamp awareness
  def update_completion(date, state, notes: nil)
    raise ArgumentError, "Invalid state: #{state}" unless COMPLETION_STATES.include?(state)
    
    date_string = date.to_s
    existing_completion = completions.find { |c| c['date'] == date_string }
    
    if existing_completion
      existing_completion['state'] = state
      existing_completion['completed_at'] = Time.current.iso8601
      existing_completion['notes'] = notes if notes
    else
      completions << {
        'date' => date_string,
        'state' => state,
        'completed_at' => Time.current.iso8601,
        'notes' => notes
      }
    end
    
    save
  end
  
  # Toggle between completed and not_started
  def toggle_completion(date)
    current_state = state_on(date)
    new_state = current_state == 'completed' ? 'not_started' : 'completed'
    update_completion(date, new_state)
  end
  
  # Get completion status for last N days (using Date.current)
  def last_n_days_status(n = 5)
    today = Date.current
    (0...n).reverse_each.map do |i|
      date = today - i.days
      {
        date: date.to_s,
        state: state_on(date),
        completed: completed_on?(date)
      }
    end
  end
  
  # Calculate current streak (using Date.current)
  def calculate_current_streak
    return 0 if completions.empty?
    
    completed_dates = completions
      .select { |c| c['state'] == 'completed' }
      .map { |c| Date.parse(c['date']) }
      .sort
      .reverse
    
    return 0 if completed_dates.empty?
    
    today = Date.current
    return 0 if completed_dates.first < today - 1.day
    
    streak = 0
    expected_date = today
    
    completed_dates.each do |date|
      break if date < expected_date - 1.day
      streak += 1 if date >= expected_date - 1.day
      expected_date = date - 1.day
    end
    
    streak
  end
  
  # Calculate longest streak ever
  def calculate_longest_streak
    return 0 if completions.empty?
    
    completed_dates = completions
      .select { |c| c['state'] == 'completed' }
      .map { |c| Date.parse(c['date']) }
      .sort
    
    return 0 if completed_dates.empty?
    
    max_streak = 1
    current_streak = 1
    
    completed_dates.each_cons(2) do |prev_date, curr_date|
      if curr_date == prev_date + 1.day
        current_streak += 1
        max_streak = [max_streak, current_streak].max
      else
        current_streak = 1
      end
    end
    
    max_streak
  end
  
  # Get completion data for a specific month
  def month_completions(year, month)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    
    (start_date..end_date).map do |date|
      {
        date: date.to_s,
        state: state_on(date),
        completed: completed_on?(date)
      }
    end
  end
  
  # Get statistics
  def stats
    completed_count = completions.count { |c| c['state'] == 'completed' }
    skipped_count = completions.count { |c| c['state'] == 'skipped' }
    failed_count = completions.count { |c| c['state'] == 'failed' }
    
    {
      total_completions: completed_count,
      total_skipped: skipped_count,
      total_failed: failed_count,
      current_streak: current_streak,
      longest_streak: longest_streak
    }
  end
  
  private
  
  def set_defaults
    self.external_id ||= SecureRandom.uuid
    self.completions ||= []
    self.current_streak ||= 0
    self.longest_streak ||= 0
  end
  
  def update_streaks
    self.current_streak = calculate_current_streak
    self.longest_streak = [self.longest_streak, calculate_current_streak].max
    save if changed?
  end
end
```

---

## 5. GRAPHQL API ARCHITECTURE

### GraphQL Setup

#### Install GraphQL
```bash
cd backend
bundle add graphql
bundle add graphql-batch
rails generate graphql:install
```

This will create:
- `app/graphql/` directory structure
- `app/controllers/graphql_controller.rb`
- GraphQL route in `config/routes.rb`

### Routes Configuration (config/routes.rb)
```ruby
Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"
  
  # GraphiQL IDE for development
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
end
```

### GraphQL Schema (app/graphql/habitkit_clone_schema.rb)
```ruby
class HabitkitCloneSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)
  
  # Use batch loading to avoid N+1 queries
  use GraphQL::Batch
end
```

### GraphQL Types

#### Completion State Enum (app/graphql/types/completion_state_enum.rb)
```ruby
module Types
  class CompletionStateEnum < Types::BaseEnum
    description "States that a habit completion can be in"
    
    value "NOT_STARTED", "Habit has not been started yet", value: "not_started"
    value "IN_PROGRESS", "Habit is currently in progress", value: "in_progress"
    value "COMPLETED", "Habit has been completed", value: "completed"
    value "SKIPPED", "Habit was intentionally skipped", value: "skipped"
    value "FAILED", "Habit was attempted but failed", value: "failed"
  end
end
```

#### Streak Goal Enum (app/graphql/types/streak_goal_enum.rb)
```ruby
module Types
  class StreakGoalEnum < Types::BaseEnum
    description "Frequency goals for habit streaks"
    
    value "NONE", "No streak goal", value: "none"
    value "DAILY", "Daily streak goal", value: "daily"
    value "WEEKLY", "Weekly streak goal", value: "weekly"
    value "MONTHLY", "Monthly streak goal", value: "monthly"
  end
end
```

#### Completion Type (app/graphql/types/completion_type.rb)
```ruby
module Types
  class CompletionType < Types::BaseObject
    description "A single completion record for a habit on a specific date"
    
    field :date, String, null: false, description: "The date of completion (YYYY-MM-DD)"
    field :state, Types::CompletionStateEnum, null: false, description: "Current state of the completion"
    field :completed, Boolean, null: false, description: "Quick check if completed"
    field :completed_at, GraphQL::Types::ISO8601DateTime, null: true, description: "When it was marked completed"
    field :notes, String, null: true, description: "Optional notes"
    
    def completed
      object['state'] == 'completed'
    end
    
    def completed_at
      Time.parse(object['completed_at']) if object['completed_at']
    end
  end
end
```

#### Habit Stats Type (app/graphql/types/habit_stats_type.rb)
```ruby
module Types
  class HabitStatsType < Types::BaseObject
    description "Statistics for a habit"
    
    field :total_completions, Integer, null: false
    field :total_skipped, Integer, null: false
    field :total_failed, Integer, null: false
    field :current_streak, Integer, null: false
    field :longest_streak, Integer, null: false
  end
end
```

#### User Settings Type (app/graphql/types/user_settings_type.rb)
```ruby
module Types
  class UserSettingsType < Types::BaseObject
    description "User preferences for the habit tracker"
    
    field :id, ID, null: false
    field :external_id, String, null: false
    field :compact_days, Integer, null: false, description: "Number of days to show in compact list (1-7)"
    field :show_habit_names, Boolean, null: false, description: "Whether to show habit names in the list"
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
```

#### Habit Type (app/graphql/types/habit_type.rb)
```ruby
module Types
  class HabitType < Types::BaseObject
    description "A habit that can be tracked daily"
    
    field :id, ID, null: false, description: "Database ID"
    field :external_id, String, null: false, description: "Public-facing UUID"
    field :name, String, null: false, description: "Name of the habit"
    field :description, String, null: true, description: "Optional description"
    field :emoji, String, null: false, description: "Emoji icon"
    field :color, String, null: false, description: "Hex color code"
    field :streak_goal, Types::StreakGoalEnum, null: false, description: "Streak frequency goal"
    field :current_streak, Integer, null: false, description: "Current consecutive days"
    field :longest_streak, Integer, null: false, description: "Longest streak ever"
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    
    # Computed fields
    field :last_5_days, [Types::CompletionType], null: false, description: "Completion status for last 5 days (deprecated, use lastNDays)"
    field :last_n_days, [Types::CompletionType], null: false, description: "Completion status for last N days" do
      argument :days, Integer, required: false, default_value: 5
    end
    field :stats, Types::HabitStatsType, null: false, description: "Overall statistics"
    
    # Methods for computed fields
    def last_5_days
      object.last_n_days_status(5)
    end
    
    def last_n_days(days: 5)
      # Clamp between 1 and 7
      n = [[days, 1].max, 7].min
      object.last_n_days_status(n)
    end
    
    def stats
      object.stats
    end
  end
end
```

### Query Type (app/graphql/types/query_type.rb)
```ruby
module Types
  class QueryType < Types::BaseObject
    description "The query root of the GraphQL schema"
    
    # Get all habits
    field :habits, [Types::HabitType], null: false, description: "Get all habits ordered by creation date"
    
    def habits
      Habit.ordered
    end
    
    # Get a single habit by external_id
    field :habit, Types::HabitType, null: true do
      description "Get a single habit by external ID"
      argument :external_id, String, required: true
    end
    
    def habit(external_id:)
      Habit.find_by(external_id: external_id)
    end
    
    # Get month data for a habit
    field :habit_month_data, [Types::CompletionType], null: false do
      description "Get completion data for a specific month"
      argument :external_id, String, required: true
      argument :year, Integer, required: true
      argument :month, Integer, required: true
    end
    
    def habit_month_data(external_id:, year:, month:)
      habit = Habit.find_by!(external_id: external_id)
      habit.month_completions(year, month)
    end
    
    # Get current server time (for client synchronization)
    field :current_server_time, GraphQL::Types::ISO8601DateTime, null: false do
      description "Get current server time for synchronization"
    end
    
    def current_server_time
      Time.current
    end
    
    # Get current server date
    field :current_server_date, String, null: false do
      description "Get current server date (YYYY-MM-DD format)"
    end
    
    def current_server_date
      Date.current.to_s
    end
    
    # Get user settings
    field :user_settings, Types::UserSettingsType, null: false do
      description "Get current user settings (compact days, show names, etc.)"
    end
    
    def user_settings
      UserSettings.current
    end
  end
end
```

### Mutation Type (app/graphql/types/mutation_type.rb)
```ruby
module Types
  class MutationType < Types::BaseObject
    description "The mutation root of the GraphQL schema"
    
    # Create Habit
    field :create_habit, mutation: Mutations::CreateHabit
    
    # Update Habit
    field :update_habit, mutation: Mutations::UpdateHabit
    
    # Delete Habit
    field :delete_habit, mutation: Mutations::DeleteHabit
    
    # Toggle Completion (simplified version)
    field :toggle_habit_completion, mutation: Mutations::ToggleHabitCompletion
    
    # Update Completion State (advanced version with state selection)
    field :update_habit_completion, mutation: Mutations::UpdateHabitCompletion
    
    # Update User Settings
    field :update_user_settings, mutation: Mutations::UpdateUserSettings
  end
end
```

### Mutations

#### Create Habit (app/graphql/mutations/create_habit.rb)
```ruby
module Mutations
  class CreateHabit < BaseMutation
    description "Create a new habit"
    
    # Input arguments
    argument :name, String, required: true
    argument :description, String, required: false
    argument :emoji, String, required: false
    argument :color, String, required: false
    argument :streak_goal, Types::StreakGoalEnum, required: false
    
    # Return type
    field :habit, Types::HabitType, null: true
    field :errors, [String], null: false
    
    def resolve(name:, description: nil, emoji: '⚡', color: '#a855f7', streak_goal: 'none')
      habit = Habit.new(
        name: name,
        description: description,
        emoji: emoji,
        color: color,
        streak_goal: streak_goal
      )
      
      if habit.save
        { habit: habit, errors: [] }
      else
        { habit: nil, errors: habit.errors.full_messages }
      end
    end
  end
end
```

#### Update Habit (app/graphql/mutations/update_habit.rb)
```ruby
module Mutations
  class UpdateHabit < BaseMutation
    description "Update an existing habit"
    
    argument :external_id, String, required: true
    argument :name, String, required: false
    argument :description, String, required: false
    argument :emoji, String, required: false
    argument :color, String, required: false
    argument :streak_goal, Types::StreakGoalEnum, required: false
    
    field :habit, Types::HabitType, null: true
    field :errors, [String], null: false
    
    def resolve(external_id:, **attributes)
      habit = Habit.find_by(external_id: external_id)
      
      unless habit
        return { habit: nil, errors: ["Habit not found"] }
      end
      
      if habit.update(attributes.compact)
        { habit: habit, errors: [] }
      else
        { habit: nil, errors: habit.errors.full_messages }
      end
    end
  end
end
```

#### Delete Habit (app/graphql/mutations/delete_habit.rb)
```ruby
module Mutations
  class DeleteHabit < BaseMutation
    description "Delete a habit"
    
    argument :external_id, String, required: true
    
    field :success, Boolean, null: false
    field :errors, [String], null: false
    
    def resolve(external_id:)
      habit = Habit.find_by(external_id: external_id)
      
      unless habit
        return { success: false, errors: ["Habit not found"] }
      end
      
      if habit.destroy
        { success: true, errors: [] }
      else
        { success: false, errors: habit.errors.full_messages }
      end
    end
  end
end
```

#### Toggle Habit Completion (app/graphql/mutations/toggle_habit_completion.rb)
```ruby
module Mutations
  class ToggleHabitCompletion < BaseMutation
    description "Toggle habit completion for a specific date"
    
    argument :external_id, String, required: true
    argument :date, String, required: false, description: "Date in YYYY-MM-DD format (defaults to today)"
    
    field :habit, Types::HabitType, null: true
    field :new_state, Types::CompletionStateEnum, null: true
    field :errors, [String], null: false
    
    def resolve(external_id:, date: nil)
      habit = Habit.find_by(external_id: external_id)
      
      unless habit
        return { habit: nil, new_state: nil, errors: ["Habit not found"] }
      end
      
      target_date = date ? Date.parse(date) : Date.current
      
      if habit.toggle_completion(target_date)
        new_state = habit.state_on(target_date)
        { habit: habit.reload, new_state: new_state, errors: [] }
      else
        { habit: nil, new_state: nil, errors: habit.errors.full_messages }
      end
    end
  end
end
```

#### Update Habit Completion (app/graphql/mutations/update_habit_completion.rb)
```ruby
module Mutations
  class UpdateHabitCompletion < BaseMutation
    description "Update habit completion state for a specific date"
    
    argument :external_id, String, required: true
    argument :date, String, required: false, description: "Date in YYYY-MM-DD format"
    argument :state, Types::CompletionStateEnum, required: true
    argument :notes, String, required: false
    
    field :habit, Types::HabitType, null: true
    field :completion, Types::CompletionType, null: true
    field :errors, [String], null: false
    
    def resolve(external_id:, state:, date: nil, notes: nil)
      habit = Habit.find_by(external_id: external_id)
      
      unless habit
        return { habit: nil, completion: nil, errors: ["Habit not found"] }
      end
      
      target_date = date ? Date.parse(date) : Date.current
      
      if habit.update_completion(target_date, state, notes: notes)
        completion_data = habit.completions.find { |c| c['date'] == target_date.to_s }
        { habit: habit.reload, completion: completion_data, errors: [] }
      else
        { habit: nil, completion: nil, errors: habit.errors.full_messages }
      end
    rescue ArgumentError => e
      { habit: nil, completion: nil, errors: [e.message] }
    end
  end
end
```

#### Update User Settings (app/graphql/mutations/update_user_settings.rb)
```ruby
module Mutations
  class UpdateUserSettings < BaseMutation
    description "Update user settings for compact list display"
    
    argument :compact_days, Integer, required: false, description: "Number of days to show (1-7)"
    argument :show_habit_names, Boolean, required: false, description: "Show or hide habit names"
    
    field :user_settings, Types::UserSettingsType, null: true
    field :errors, [String], null: false
    
    def resolve(compact_days: nil, show_habit_names: nil)
      settings = UserSettings.current
      
      # Update only provided fields
      attributes = {}
      attributes[:compact_days] = compact_days if compact_days.present?
      attributes[:show_habit_names] = show_habit_names unless show_habit_names.nil?
      
      if settings.update(attributes)
        { user_settings: settings, errors: [] }
      else
        { user_settings: nil, errors: settings.errors.full_messages }
      end
    end
  end
end
```

### GraphQL Controller (app/controllers/graphql_controller.rb)
```ruby
class GraphqlController < ApplicationController
  # Disable CSRF protection for GraphQL endpoint (or use proper token auth)
  skip_before_action :verify_authenticity_token, if: :json_request?
  
  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_user: nil, # Add user authentication here when needed
      current_time: Time.current,
      current_date: Date.current
    }
    
    result = HabitkitCloneSchema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name
    )
    
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end
  
  private
  
  def json_request?
    request.format.json?
  end
  
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash
    when nil
      {}
    else
      raise ArgumentError, "Unexpected variables: #{variables_param}"
    end
  end
  
  def handle_error_in_development(error)
    logger.error error.message
    logger.error error.backtrace.join("\n")
    
    render json: {
      errors: [
        {
          message: error.message,
          backtrace: error.backtrace
        }
      ],
      data: {}
    }, status: 500
  end
end
```

### Base Mutation Class (app/graphql/mutations/base_mutation.rb)
```ruby
module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject
    
    # Provide access to context
    def current_user
      context[:current_user]
    end
    
    def current_time
      context[:current_time] || Time.current
    end
    
    def current_date
      context[:current_date] || Date.current
    end
  end
end
```

### Testing GraphQL API

You can test your GraphQL API using the GraphiQL IDE at `http://localhost:3001/graphiql` in development.

**Example Query:**
```graphql
query {
  habits {
    externalId
    name
    emoji
    color
    currentStreak
    last5Days {
      date
      state
      completed
    }
  }
}
```

**Example Mutation:**
```graphql
mutation {
  createHabit(input: {
    name: "Morning Run"
    emoji: "🏃"
    color: "#10b981"
    streakGoal: DAILY
  }) {
    habit {
      externalId
      name
    }
    errors
  }
}
```

---

## 6. FRONTEND GRAPHQL CLIENT ARCHITECTURE

### Project Structure
```
src/
├── graphql/
│   ├── client.js               # Apollo Client configuration
│   ├── queries.js              # GraphQL queries
│   ├── mutations.js            # GraphQL mutations
│   └── fragments.js            # Reusable GraphQL fragments
├── components/
│   ├── HabitList.jsx           # Main list view (Image 1)
│   ├── HabitCard.jsx            # Individual habit card
│   ├── HabitDetailModal.jsx    # Calendar view modal (Image 2)
│   ├── NewHabitView.jsx         # New habit form (Images 3 & 4)
│   ├── CompactListSettings.jsx  # Settings panel for compact list
│   ├── CalendarGrid.jsx         # Monthly calendar component
│   ├── DaySquare.jsx            # Individual day square in calendar
│   ├── EmojiPicker.jsx          # Emoji selection component
│   ├── ColorPicker.jsx          # Color selection component
│   └── Layout.jsx               # Main app layout wrapper
├── hooks/
│   ├── useHabits.js            # Habits data management hook (with GraphQL)
│   ├── useSettings.js          # User settings hook (with GraphQL)
│   └── useCalendar.js          # Calendar logic hook
├── utils/
│   ├── dateUtils.js            # Date formatting and calculations
│   └── colorUtils.js           # Color manipulation utilities
├── App.jsx                      # Root component
├── main.jsx                     # Application entry point
└── index.css                    # Global styles
```

### Apollo Client Setup (src/graphql/client.js)
```javascript
import { ApolloClient, InMemoryCache, createHttpLink } from '@apollo/client'

// Dynamically determine the GraphQL endpoint
const getGraphQLEndpoint = () => {
  const currentHost = window.location.hostname
  const currentProtocol = window.location.protocol
  const apiHost = currentHost === 'localhost' ? 'localhost' : currentHost
  return `${currentProtocol}//${apiHost}:3001/graphql`
}

const httpLink = createHttpLink({
  uri: getGraphQLEndpoint(),
  credentials: 'same-origin'
})

const client = new ApolloClient({
  link: httpLink,
  cache: new InMemoryCache({
    typePolicies: {
      Query: {
        fields: {
          habits: {
            merge(existing = [], incoming) {
              return incoming
            }
          }
        }
      },
      Habit: {
        keyFields: ['externalId']
      }
    }
  }),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: 'cache-and-network',
      errorPolicy: 'all'
    },
    query: {
      fetchPolicy: 'network-only',
      errorPolicy: 'all'
    },
    mutate: {
      errorPolicy: 'all'
    }
  }
})

export default client
```

### GraphQL Fragments (src/graphql/fragments.js)
```javascript
import { gql } from '@apollo/client'

export const HABIT_FRAGMENT = gql`
  fragment HabitFields on Habit {
    id
    externalId
    name
    description
    emoji
    color
    streakGoal
    currentStreak
    longestStreak
    createdAt
    updatedAt
  }
`

export const COMPLETION_FRAGMENT = gql`
  fragment CompletionFields on Completion {
    date
    state
    completed
    completedAt
    notes
  }
`

export const HABIT_WITH_LAST_5_DAYS = gql`
  ${HABIT_FRAGMENT}
  ${COMPLETION_FRAGMENT}
  
  fragment HabitWithLast5Days on Habit {
    ...HabitFields
    last5Days {
      ...CompletionFields
    }
  }
`

export const HABIT_STATS_FRAGMENT = gql`
  fragment HabitStatsFields on HabitStats {
    totalCompletions
    totalSkipped
    totalFailed
    currentStreak
    longestStreak
  }
`
```

### GraphQL Queries (src/graphql/queries.js)
```javascript
import { gql } from '@apollo/client'
import { HABIT_WITH_LAST_5_DAYS, HABIT_FRAGMENT, COMPLETION_FRAGMENT, HABIT_STATS_FRAGMENT } from './fragments'

export const GET_HABITS = gql`
  ${HABIT_WITH_LAST_5_DAYS}
  
  query GetHabits {
    habits {
      ...HabitWithLast5Days
    }
  }
`

export const GET_HABIT = gql`
  ${HABIT_FRAGMENT}
  ${HABIT_STATS_FRAGMENT}
  
  query GetHabit($externalId: String!) {
    habit(externalId: $externalId) {
      ...HabitFields
      stats {
        ...HabitStatsFields
      }
    }
  }
`

export const GET_HABIT_MONTH_DATA = gql`
  ${COMPLETION_FRAGMENT}
  
  query GetHabitMonthData($externalId: String!, $year: Int!, $month: Int!) {
    habitMonthData(externalId: $externalId, year: $year, month: $month) {
      ...CompletionFields
    }
  }
`

export const GET_CURRENT_SERVER_TIME = gql`
  query GetCurrentServerTime {
    currentServerTime
    currentServerDate
  }
`

export const GET_USER_SETTINGS = gql`
  query GetUserSettings {
    userSettings {
      id
      externalId
      compactDays
      showHabitNames
      createdAt
      updatedAt
    }
  }
`
```

### GraphQL Mutations (src/graphql/mutations.js)
```javascript
import { gql } from '@apollo/client'
import { HABIT_WITH_LAST_5_DAYS, COMPLETION_FRAGMENT } from './fragments'

export const CREATE_HABIT = gql`
  ${HABIT_WITH_LAST_5_DAYS}
  
  mutation CreateHabit(
    $name: String!
    $description: String
    $emoji: String
    $color: String
    $streakGoal: StreakGoalEnum
  ) {
    createHabit(
      input: {
        name: $name
        description: $description
        emoji: $emoji
        color: $color
        streakGoal: $streakGoal
      }
    ) {
      habit {
        ...HabitWithLast5Days
      }
      errors
    }
  }
`

export const UPDATE_HABIT = gql`
  ${HABIT_WITH_LAST_5_DAYS}
  
  mutation UpdateHabit(
    $externalId: String!
    $name: String
    $description: String
    $emoji: String
    $color: String
    $streakGoal: StreakGoalEnum
  ) {
    updateHabit(
      input: {
        externalId: $externalId
        name: $name
        description: $description
        emoji: $emoji
        color: $color
        streakGoal: $streakGoal
      }
    ) {
      habit {
        ...HabitWithLast5Days
      }
      errors
    }
  }
`

export const DELETE_HABIT = gql`
  mutation DeleteHabit($externalId: String!) {
    deleteHabit(input: { externalId: $externalId }) {
      success
      errors
    }
  }
`

export const TOGGLE_HABIT_COMPLETION = gql`
  ${HABIT_WITH_LAST_5_DAYS}
  
  mutation ToggleHabitCompletion($externalId: String!, $date: String) {
    toggleHabitCompletion(input: { externalId: $externalId, date: $date }) {
      habit {
        ...HabitWithLast5Days
      }
      newState
      errors
    }
  }
`

export const UPDATE_HABIT_COMPLETION = gql`
  ${HABIT_WITH_LAST_5_DAYS}
  ${COMPLETION_FRAGMENT}
  
  mutation UpdateHabitCompletion(
    $externalId: String!
    $date: String
    $state: CompletionStateEnum!
    $notes: String
  ) {
    updateHabitCompletion(
      input: {
        externalId: $externalId
        date: $date
        state: $state
        notes: $notes
      }
    ) {
      habit {
        ...HabitWithLast5Days
      }
      completion {
        ...CompletionFields
      }
      errors
    }
  }
`

export const UPDATE_USER_SETTINGS = gql`
  mutation UpdateUserSettings($compactDays: Int, $showHabitNames: Boolean) {
    updateUserSettings(
      input: {
        compactDays: $compactDays
        showHabitNames: $showHabitNames
      }
    ) {
      userSettings {
        id
        externalId
        compactDays
        showHabitNames
        updatedAt
      }
      errors
    }
  }
`
```

### Custom Hooks with Apollo Client

#### useHabits Hook (src/hooks/useHabits.js)
```javascript
import { useQuery, useMutation } from '@apollo/client'
import {
  GET_HABITS,
  CREATE_HABIT,
  UPDATE_HABIT,
  DELETE_HABIT,
  TOGGLE_HABIT_COMPLETION,
  UPDATE_HABIT_COMPLETION
} from '../graphql/queries'
import * as mutations from '../graphql/mutations'

export const useHabits = () => {
  // Query for all habits
  const { data, loading, error, refetch } = useQuery(GET_HABITS, {
    fetchPolicy: 'cache-and-network'
  })
  
  // Create habit mutation
  const [createHabitMutation, { loading: creating }] = useMutation(mutations.CREATE_HABIT, {
    update(cache, { data: { createHabit } }) {
      if (createHabit.habit && createHabit.errors.length === 0) {
        // Read current habits from cache
        const existingHabits = cache.readQuery({ query: GET_HABITS })
        
        // Write updated habits to cache
        cache.writeQuery({
          query: GET_HABITS,
          data: {
            habits: [createHabit.habit, ...(existingHabits?.habits || [])]
          }
        })
      }
    }
  })
  
  // Update habit mutation
  const [updateHabitMutation, { loading: updating }] = useMutation(mutations.UPDATE_HABIT)
  
  // Delete habit mutation
  const [deleteHabitMutation, { loading: deleting }] = useMutation(mutations.DELETE_HABIT, {
    update(cache, { data: { deleteHabit } }, { variables }) {
      if (deleteHabit.success) {
        const existingHabits = cache.readQuery({ query: GET_HABITS })
        cache.writeQuery({
          query: GET_HABITS,
          data: {
            habits: existingHabits.habits.filter(
              h => h.externalId !== variables.externalId
            )
          }
        })
      }
    }
  })
  
  // Toggle completion mutation
  const [toggleCompletionMutation, { loading: toggling }] = useMutation(
    mutations.TOGGLE_HABIT_COMPLETION
  )
  
  // Update completion state mutation (advanced)
  const [updateCompletionMutation, { loading: updatingCompletion }] = useMutation(
    mutations.UPDATE_HABIT_COMPLETION
  )
  
  // Wrapper functions
  const createHabit = async (habitData) => {
    try {
      const { data } = await createHabitMutation({
        variables: habitData
      })
      
      if (data.createHabit.errors.length > 0) {
        throw new Error(data.createHabit.errors.join(', '))
      }
      
      return data.createHabit.habit
    } catch (err) {
      console.error('Error creating habit:', err)
      throw err
    }
  }
  
  const updateHabit = async (externalId, habitData) => {
    try {
      const { data } = await updateHabitMutation({
        variables: {
          externalId,
          ...habitData
        }
      })
      
      if (data.updateHabit.errors.length > 0) {
        throw new Error(data.updateHabit.errors.join(', '))
      }
      
      return data.updateHabit.habit
    } catch (err) {
      console.error('Error updating habit:', err)
      throw err
    }
  }
  
  const deleteHabit = async (externalId) => {
    try {
      const { data } = await deleteHabitMutation({
        variables: { externalId }
      })
      
      if (data.deleteHabit.errors.length > 0) {
        throw new Error(data.deleteHabit.errors.join(', '))
      }
      
      return data.deleteHabit.success
    } catch (err) {
      console.error('Error deleting habit:', err)
      throw err
    }
  }
  
  const toggleCompletion = async (externalId, date = null) => {
    try {
      const { data } = await toggleCompletionMutation({
        variables: {
          externalId,
          date: date?.toString() || null
        }
      })
      
      if (data.toggleHabitCompletion.errors.length > 0) {
        throw new Error(data.toggleHabitCompletion.errors.join(', '))
      }
      
      return data.toggleHabitCompletion.habit
    } catch (err) {
      console.error('Error toggling completion:', err)
      throw err
    }
  }
  
  const updateCompletionState = async (externalId, state, date = null, notes = null) => {
    try {
      const { data } = await updateCompletionMutation({
        variables: {
          externalId,
          date: date?.toString() || null,
          state,
          notes
        }
      })
      
      if (data.updateHabitCompletion.errors.length > 0) {
        throw new Error(data.updateHabitCompletion.errors.join(', '))
      }
      
      return {
        habit: data.updateHabitCompletion.habit,
        completion: data.updateHabitCompletion.completion
      }
    } catch (err) {
      console.error('Error updating completion state:', err)
      throw err
    }
  }
  
  return {
    habits: data?.habits || [],
    loading: loading || creating || updating || deleting || toggling || updatingCompletion,
    error,
    refetch,
    createHabit,
    updateHabit,
    deleteHabit,
    toggleCompletion,
    updateCompletionState
  }
}
```

#### useSettings Hook (src/hooks/useSettings.js)
```javascript
import { useQuery, useMutation } from '@apollo/client'
import { GET_USER_SETTINGS } from '../graphql/queries'
import { UPDATE_USER_SETTINGS } from '../graphql/mutations'

export const useSettings = () => {
  // Query for settings
  const { data, loading, error } = useQuery(GET_USER_SETTINGS, {
    fetchPolicy: 'cache-and-network'
  })
  
  // Update settings mutation
  const [updateSettingsMutation, { loading: updating }] = useMutation(UPDATE_USER_SETTINGS)
  
  const updateSettings = async (compactDays = null, showHabitNames = null) => {
    try {
      const variables = {}
      if (compactDays !== null) variables.compactDays = compactDays
      if (showHabitNames !== null) variables.showHabitNames = showHabitNames
      
      const { data } = await updateSettingsMutation({ variables })
      
      if (data.updateUserSettings.errors.length > 0) {
        throw new Error(data.updateUserSettings.errors.join(', '))
      }
      
      return data.updateUserSettings.userSettings
    } catch (err) {
      console.error('Error updating settings:', err)
      throw err
    }
  }
  
  return {
    settings: data?.userSettings || { compactDays: 5, showHabitNames: true },
    loading: loading || updating,
    error,
    updateSettings
  }
}
```

#### useCalendar Hook (src/hooks/useCalendar.js)
```javascript
import { useState, useCallback } from 'react'
import { startOfMonth, endOfMonth, eachDayOfInterval, format } from 'date-fns'

export const useCalendar = (initialDate = new Date()) => {
  const [currentDate, setCurrentDate] = useState(initialDate)
  
  const monthStart = startOfMonth(currentDate)
  const monthEnd = endOfMonth(currentDate)
  const daysInMonth = eachDayOfInterval({ start: monthStart, end: monthEnd })
  
  const monthName = format(currentDate, 'MMMM yyyy')
  const year = currentDate.getFullYear()
  const month = currentDate.getMonth() + 1
  
  const goToNextMonth = useCallback(() => {
    setCurrentDate(prev => {
      const newDate = new Date(prev)
      newDate.setMonth(newDate.getMonth() + 1)
      return newDate
    })
  }, [])
  
  const goToPreviousMonth = useCallback(() => {
    setCurrentDate(prev => {
      const newDate = new Date(prev)
      newDate.setMonth(newDate.getMonth() - 1)
      return newDate
    })
  }, [])
  
  const goToToday = useCallback(() => {
    setCurrentDate(new Date())
  }, [])
  
  return {
    currentDate,
    monthStart,
    monthEnd,
    daysInMonth,
    monthName,
    year,
    month,
    goToNextMonth,
    goToPreviousMonth,
    goToToday
  }
}
```

### Utility Functions

#### Date Utils (src/utils/dateUtils.js)
```javascript
import { format, isToday, isThisWeek, isThisMonth, parseISO } from 'date-fns'

export const formatDate = (date, formatString = 'yyyy-MM-dd') => {
  const dateObj = typeof date === 'string' ? parseISO(date) : date
  return format(dateObj, formatString)
}

export const isTodayDate = (date) => {
  const dateObj = typeof date === 'string' ? parseISO(date) : date
  return isToday(dateObj)
}

export const isInCurrentWeek = (date) => {
  const dateObj = typeof date === 'string' ? parseISO(date) : date
  return isThisWeek(dateObj, { weekStartsOn: 1 })
}

export const isInCurrentMonth = (date) => {
  const dateObj = typeof date === 'string' ? parseISO(date) : date
  return isThisMonth(dateObj)
}

export const getDayOfWeek = (date) => {
  const dateObj = typeof date === 'string' ? parseISO(date) : date
  return format(dateObj, 'EEE')
}

export const getShortMonth = (date) => {
  const dateObj = typeof date === 'string' ? parseISO(date) : date
  return format(dateObj, 'MMM')
}

export const getTodayString = () => {
  return format(new Date(), 'yyyy-MM-dd')
}
```

---

## 7. UI COMPONENTS - DETAILED IMPLEMENTATION

### Key Features Overview

**Main List View (Image 1):**
- Shows all habits with emoji, name, and last N days (configurable 1-7)
- Tap day squares to toggle completion
- Tap habit card to open detail view
- Tap "Last N days" button to open settings
- Add new habit with + button

**Settings Panel (Image 5 - Your new screenshot):**
- Slide-up panel (no blur)
- Select 1-7 days to display
- Toggle habit names visibility (Hidden/Shown)
- Changes apply immediately

**Detail Modal (Image 2):**
- Full calendar view with month navigation
- Blur backdrop
- Streak statistics
- Tap any day to toggle completion

**New Habit Form (Images 3-4):**
- Full-screen view
- Emoji picker with categories
- Color palette selector
- Streak goal options
- Name and description fields

### IMAGE 1: Main Habit List View

#### HabitList Component (src/components/HabitList.jsx)
```javascript
import React from 'react'
import { Plus } from 'lucide-react'
import { motion } from 'framer-motion'
import { useSettings } from '../hooks/useSettings'
import HabitCard from './HabitCard'

const HabitList = ({ habits, onHabitClick, onToggleDay, onAddHabit, onOpenSettings }) => {
  const { settings } = useSettings()
  
  return (
    <div className="min-h-screen bg-dark-bg">
      {/* Header */}
      <div className="sticky top-0 z-10 bg-dark-bg/80 backdrop-blur-md border-b border-dark-border">
        <div className="flex items-center justify-between px-4 py-4">
          <div>
            <h1 className="text-2xl font-bold text-dark-text-primary">
              Habit<span className="text-habit-purple">Kit</span>
            </h1>
            {/* Clickable Last N days button */}
            <button
              onClick={onOpenSettings}
              className="text-sm text-dark-text-secondary mt-0.5 hover:text-dark-text-primary transition-colors text-left"
            >
              Last {settings.compactDays} day{settings.compactDays !== 1 ? 's' : ''}
            </button>
          </div>
          
          <button
            onClick={onAddHabit}
            className="w-10 h-10 rounded-full bg-habit-purple flex items-center justify-center hover:bg-opacity-80 transition-all active:scale-95"
          >
            <Plus className="w-5 h-5 text-white" />
          </button>
        </div>
      </div>
      
      {/* Habits List */}
      <div className="px-4 py-4 space-y-3">
        {habits.length === 0 ? (
          <div className="text-center py-20">
            <p className="text-dark-text-secondary text-lg">
              No habits yet
            </p>
            <p className="text-dark-text-muted text-sm mt-2">
              Tap the + button to create your first habit
            </p>
          </div>
        ) : (
          habits.map((habit, index) => (
            <motion.div
              key={habit.external_id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.05 }}
            >
              <HabitCard
                habit={habit}
                showName={settings.showHabitNames}
                compactDays={settings.compactDays}
                onCardClick={() => onHabitClick(habit)}
                onDayClick={(date) => onToggleDay(habit.external_id, date)}
              />
            </motion.div>
          ))
        )}
      </div>
    </div>
  )
}

export default HabitList
```

#### HabitCard Component (src/components/HabitCard.jsx)
```javascript
import React, { useMemo } from 'react'
import { motion } from 'framer-motion'
import DaySquare from './DaySquare'

const HabitCard = ({ habit, showName = true, compactDays = 5, onCardClick, onDayClick }) => {
  // Generate the correct number of days dynamically
  const displayDays = useMemo(() => {
    if (!habit.last_5_days) return []
    
    // Get the last N days from the habit data
    // Note: Backend should be updated to accept a 'days' parameter
    // For now, we'll slice the existing last_5_days data
    return habit.last_5_days.slice(-compactDays)
  }, [habit.last_5_days, compactDays])
  
  return (
    <div
      className="bg-dark-card rounded-2xl border border-dark-border overflow-hidden"
      style={{ borderLeftColor: habit.color, borderLeftWidth: '4px' }}
    >
      {/* Habit Info - Clickable to open detail */}
      <div
        onClick={onCardClick}
        className="flex items-center gap-3 px-4 py-4 cursor-pointer active:bg-dark-bg/50 transition-colors"
      >
        <div className="text-3xl">{habit.emoji}</div>
        
        {/* Conditionally show habit name and description */}
        {showName && (
          <div className="flex-1 min-w-0">
            <h3 className="text-dark-text-primary font-medium text-lg truncate">
              {habit.name}
            </h3>
            {habit.description && (
              <p className="text-dark-text-secondary text-sm truncate mt-0.5">
                {habit.description}
              </p>
            )}
          </div>
        )}
      </div>
      
      {/* Last N Days Grid */}
      <div className="flex gap-2 px-4 pb-4">
        {displayDays.map((day) => (
          <DaySquare
            key={day.date}
            date={day.date}
            completed={day.completed}
            color={habit.color}
            onClick={(e) => {
              e.stopPropagation()
              onDayClick(day.date)
            }}
          />
        ))}
      </div>
    </div>
  )
}

export default HabitCard
```

#### DaySquare Component (src/components/DaySquare.jsx)
```javascript
import React from 'react'
import { motion } from 'framer-motion'
import { format, parseISO } from 'date-fns'

const DaySquare = ({ date, completed, color, onClick }) => {
  const dateObj = parseISO(date)
  const dayLabel = format(dateObj, 'EEE')
  const dayNumber = format(dateObj, 'd')
  
  return (
    <motion.button
      onClick={onClick}
      className="flex-1 aspect-square rounded-xl border-2 flex flex-col items-center justify-center gap-1 relative overflow-hidden transition-all active:scale-95"
      style={{
        backgroundColor: completed ? color : 'transparent',
        borderColor: completed ? color : '#2a2a2a'
      }}
      whileTap={{ scale: 0.95 }}
    >
      <span className="text-xs font-medium" style={{
        color: completed ? '#ffffff' : '#666666'
      }}>
        {dayLabel}
      </span>
      <span className="text-lg font-bold" style={{
        color: completed ? '#ffffff' : '#a0a0a0'
      }}>
        {dayNumber}
      </span>
      
      {completed && (
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          className="absolute inset-0 bg-white opacity-20"
        />
      )}
    </motion.button>
  )
}

export default DaySquare
```

### IMAGE 2: Habit Detail Modal with Calendar

#### HabitDetailModal Component (src/components/HabitDetailModal.jsx)
```javascript
import React, { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { X, ChevronLeft, ChevronRight } from 'lucide-react'
import { useCalendar } from '../hooks/useCalendar'
import CalendarGrid from './CalendarGrid'
import api from '../services/api'

const HabitDetailModal = ({ habit, isOpen, onClose, onToggleDay }) => {
  const [monthData, setMonthData] = useState([])
  const [loading, setLoading] = useState(false)
  const calendar = useCalendar()
  
  useEffect(() => {
    if (isOpen && habit) {
      loadMonthData()
    }
  }, [isOpen, habit, calendar.year, calendar.month])
  
  const loadMonthData = async () => {
    if (!habit) return
    
    setLoading(true)
    try {
      const data = await api.getMonthData(
        habit.external_id,
        calendar.year,
        calendar.month
      )
      setMonthData(data.month_data || [])
    } catch (error) {
      console.error('Error loading month data:', error)
    } finally {
      setLoading(false)
    }
  }
  
  const handleDayClick = async (date) => {
    await onToggleDay(habit.external_id, date)
    // Reload month data to see the update
    loadMonthData()
  }
  
  if (!habit) return null
  
  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop with Blur */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/60 backdrop-blur-md z-40"
          />
          
          {/* Modal Content */}
          <motion.div
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={{ type: 'spring', damping: 30, stiffness: 300 }}
            className="fixed inset-x-0 bottom-0 z-50 bg-dark-card rounded-t-3xl max-h-[90vh] overflow-hidden"
            style={{
              maxWidth: '428px',
              margin: '0 auto',
              left: '50%',
              transform: 'translateX(-50%)'
            }}
          >
            {/* Header */}
            <div className="sticky top-0 bg-dark-card/95 backdrop-blur-sm border-b border-dark-border z-10">
              <div className="flex items-center justify-between px-6 py-4">
                <div className="flex items-center gap-3">
                  <span className="text-3xl">{habit.emoji}</span>
                  <div>
                    <h2 className="text-xl font-bold text-dark-text-primary">
                      {habit.name}
                    </h2>
                    {habit.description && (
                      <p className="text-sm text-dark-text-secondary">
                        {habit.description}
                      </p>
                    )}
                  </div>
                </div>
                <button
                  onClick={onClose}
                  className="w-8 h-8 rounded-full bg-dark-bg flex items-center justify-center hover:bg-opacity-80 transition-all"
                >
                  <X className="w-5 h-5 text-dark-text-secondary" />
                </button>
              </div>
              
              {/* Streak Info */}
              <div className="flex gap-4 px-6 pb-4">
                <div className="flex-1 bg-dark-bg rounded-xl p-3">
                  <p className="text-dark-text-secondary text-xs mb-1">
                    Current Streak
                  </p>
                  <p className="text-2xl font-bold text-dark-text-primary">
                    {habit.current_streak}
                  </p>
                </div>
                <div className="flex-1 bg-dark-bg rounded-xl p-3">
                  <p className="text-dark-text-secondary text-xs mb-1">
                    Longest Streak
                  </p>
                  <p className="text-2xl font-bold text-dark-text-primary">
                    {habit.longest_streak}
                  </p>
                </div>
              </div>
            </div>
            
            {/* Calendar Navigation */}
            <div className="flex items-center justify-between px-6 py-4 bg-dark-bg/50">
              <button
                onClick={calendar.goToPreviousMonth}
                className="p-2 hover:bg-dark-card rounded-lg transition-colors"
              >
                <ChevronLeft className="w-5 h-5 text-dark-text-primary" />
              </button>
              
              <h3 className="text-lg font-semibold text-dark-text-primary">
                {calendar.monthName}
              </h3>
              
              <button
                onClick={calendar.goToNextMonth}
                className="p-2 hover:bg-dark-card rounded-lg transition-colors"
              >
                <ChevronRight className="w-5 h-5 text-dark-text-primary" />
              </button>
            </div>
            
            {/* Calendar Grid */}
            <div className="px-6 pb-6 overflow-y-auto">
              {loading ? (
                <div className="flex items-center justify-center py-20">
                  <div className="w-8 h-8 border-4 border-habit-purple border-t-transparent rounded-full animate-spin" />
                </div>
              ) : (
                <CalendarGrid
                  days={monthData}
                  color={habit.color}
                  onDayClick={handleDayClick}
                />
              )}
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}

export default HabitDetailModal
```

#### CalendarGrid Component (src/components/CalendarGrid.jsx)
```javascript
import React from 'react'
import { motion } from 'framer-motion'
import { format, parseISO, getDay } from 'date-fns'

const WEEKDAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']

const CalendarGrid = ({ days, color, onDayClick }) => {
  // Calculate the starting position (Mon = 0, Sun = 6)
  const firstDayOffset = days.length > 0 
    ? (getDay(parseISO(days[0].date)) + 6) % 7 
    : 0
  
  return (
    <div>
      {/* Weekday Headers */}
      <div className="grid grid-cols-7 gap-2 mb-2">
        {WEEKDAYS.map(day => (
          <div key={day} className="text-center text-xs font-medium text-dark-text-secondary py-2">
            {day}
          </div>
        ))}
      </div>
      
      {/* Calendar Days */}
      <div className="grid grid-cols-7 gap-2">
        {/* Empty cells for offset */}
        {Array.from({ length: firstDayOffset }).map((_, i) => (
          <div key={`empty-${i}`} />
        ))}
        
        {/* Actual day cells */}
        {days.map((day, index) => (
          <CalendarDay
            key={day.date}
            date={day.date}
            completed={day.completed}
            color={color}
            onClick={() => onDayClick(day.date)}
            delay={index * 0.01}
          />
        ))}
      </div>
    </div>
  )
}

const CalendarDay = ({ date, completed, color, onClick, delay }) => {
  const dateObj = parseISO(date)
  const dayNumber = format(dateObj, 'd')
  const isToday = format(new Date(), 'yyyy-MM-dd') === date
  const isFuture = dateObj > new Date()
  
  return (
    <motion.button
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ delay }}
      onClick={onClick}
      disabled={isFuture}
      className="aspect-square rounded-xl border-2 flex items-center justify-center relative overflow-hidden transition-all active:scale-95 disabled:opacity-30"
      style={{
        backgroundColor: completed ? color : 'transparent',
        borderColor: completed ? color : (isToday ? '#666666' : '#2a2a2a'),
        borderWidth: isToday ? '2px' : '2px'
      }}
      whileTap={{ scale: isFuture ? 1 : 0.9 }}
    >
      <span
        className="text-base font-semibold relative z-10"
        style={{ color: completed ? '#ffffff' : '#a0a0a0' }}
      >
        {dayNumber}
      </span>
      
      {completed && (
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ type: 'spring', stiffness: 500, damping: 30 }}
          className="absolute inset-0 bg-white opacity-10"
        />
      )}
      
      {isToday && !completed && (
        <div className="absolute bottom-1 left-1/2 transform -translate-x-1/2 w-1 h-1 rounded-full bg-habit-purple" />
      )}
    </motion.button>
  )
}

export default CalendarGrid
```

### IMAGES 3 & 4: New Habit Form

#### NewHabitView Component (src/components/NewHabitView.jsx)
```javascript
import React, { useState } from 'react'
import { motion } from 'framer-motion'
import { X, ChevronRight } from 'lucide-react'
import EmojiPicker from './EmojiPicker'
import ColorPicker from './ColorPicker'

const STREAK_GOALS = [
  { value: 'none', label: 'None' },
  { value: 'daily', label: 'Daily' },
  { value: 'weekly', label: 'Weekly' },
  { value: 'monthly', label: 'Monthly' }
]

const NewHabitView = ({ onClose, onSave, initialData = null }) => {
  const [formData, setFormData] = useState({
    name: initialData?.name || '',
    description: initialData?.description || '',
    emoji: initialData?.emoji || '⚡',
    color: initialData?.color || '#a855f7',
    streak_goal: initialData?.streak_goal || 'none'
  })
  
  const [showEmojiPicker, setShowEmojiPicker] = useState(false)
  const [showColorPicker, setShowColorPicker] = useState(false)
  const [isSaving, setIsSaving] = useState(false)
  
  const handleSubmit = async (e) => {
    e.preventDefault()
    
    if (!formData.name.trim()) {
      alert('Please enter a habit name')
      return
    }
    
    setIsSaving(true)
    try {
      await onSave(formData)
      onClose()
    } catch (error) {
      alert('Error saving habit: ' + error.message)
    } finally {
      setIsSaving(false)
    }
  }
  
  return (
    <motion.div
      initial={{ x: '100%' }}
      animate={{ x: 0 }}
      exit={{ x: '100%' }}
      transition={{ type: 'spring', damping: 30, stiffness: 300 }}
      className="fixed inset-0 bg-dark-bg z-50 overflow-y-auto"
      style={{ maxWidth: '428px', margin: '0 auto' }}
    >
      {/* Header */}
      <div className="sticky top-0 bg-dark-bg/95 backdrop-blur-sm border-b border-dark-border z-10">
        <div className="flex items-center justify-between px-6 py-4">
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-dark-card flex items-center justify-center"
          >
            <X className="w-5 h-5 text-dark-text-primary" />
          </button>
          <h1 className="text-xl font-bold text-dark-text-primary">
            New Habit
          </h1>
          <div className="w-8" /> {/* Spacer for centering */}
        </div>
      </div>
      
      {/* Form */}
      <form onSubmit={handleSubmit} className="p-6 space-y-6">
        {/* Emoji Selector */}
        <div className="flex flex-col items-center py-6">
          <button
            type="button"
            onClick={() => setShowEmojiPicker(true)}
            className="w-24 h-24 rounded-full bg-dark-card border-2 border-dark-border flex items-center justify-center text-5xl hover:border-habit-purple transition-colors"
          >
            {formData.emoji}
          </button>
          <p className="text-sm text-dark-text-secondary mt-3">
            Tap to change icon
          </p>
        </div>
        
        {/* Name Input */}
        <div>
          <label className="block text-sm font-medium text-dark-text-primary mb-2">
            Name
          </label>
          <input
            type="text"
            value={formData.name}
            onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
            placeholder="e.g. Morning Run"
            className="w-full px-4 py-3 bg-dark-card border border-dark-border rounded-xl text-dark-text-primary placeholder-dark-text-muted focus:outline-none focus:border-habit-purple transition-colors"
            autoFocus
          />
        </div>
        
        {/* Description Input */}
        <div>
          <label className="block text-sm font-medium text-dark-text-primary mb-2">
            Description
          </label>
          <textarea
            value={formData.description}
            onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
            placeholder="Optional notes about this habit"
            rows={3}
            className="w-full px-4 py-3 bg-dark-card border border-dark-border rounded-xl text-dark-text-primary placeholder-dark-text-muted focus:outline-none focus:border-habit-purple transition-colors resize-none"
          />
        </div>
        
        {/* Color Picker */}
        <div>
          <label className="block text-sm font-medium text-dark-text-primary mb-2">
            Color
          </label>
          <button
            type="button"
            onClick={() => setShowColorPicker(true)}
            className="w-full px-4 py-3 bg-dark-card border border-dark-border rounded-xl flex items-center justify-between hover:border-habit-purple transition-colors"
          >
            <span className="text-dark-text-primary">Choose color</span>
            <div className="flex items-center gap-2">
              <div
                className="w-6 h-6 rounded-full border-2 border-white/20"
                style={{ backgroundColor: formData.color }}
              />
              <ChevronRight className="w-5 h-5 text-dark-text-secondary" />
            </div>
          </button>
        </div>
        
        {/* Streak Goal */}
        <div>
          <label className="block text-sm font-medium text-dark-text-primary mb-2">
            Streak Goal
          </label>
          <div className="grid grid-cols-2 gap-3">
            {STREAK_GOALS.map(goal => (
              <button
                key={goal.value}
                type="button"
                onClick={() => setFormData(prev => ({ ...prev, streak_goal: goal.value }))}
                className={`px-4 py-3 rounded-xl border-2 font-medium transition-all ${
                  formData.streak_goal === goal.value
                    ? 'bg-habit-purple border-habit-purple text-white'
                    : 'bg-dark-card border-dark-border text-dark-text-primary hover:border-dark-text-muted'
                }`}
              >
                {goal.label}
              </button>
            ))}
          </div>
        </div>
        
        {/* Save Button */}
        <button
          type="submit"
          disabled={isSaving || !formData.name.trim()}
          className="w-full py-4 bg-habit-purple text-white font-semibold rounded-xl hover:bg-opacity-90 transition-all disabled:opacity-50 disabled:cursor-not-allowed active:scale-98"
        >
          {isSaving ? 'Saving...' : 'Create Habit'}
        </button>
      </form>
      
      {/* Emoji Picker Modal */}
      {showEmojiPicker && (
        <EmojiPicker
          currentEmoji={formData.emoji}
          onSelect={(emoji) => {
            setFormData(prev => ({ ...prev, emoji }))
            setShowEmojiPicker(false)
          }}
          onClose={() => setShowEmojiPicker(false)}
        />
      )}
      
      {/* Color Picker Modal */}
      {showColorPicker && (
        <ColorPicker
          currentColor={formData.color}
          onSelect={(color) => {
            setFormData(prev => ({ ...prev, color }))
            setShowColorPicker(false)
          }}
          onClose={() => setShowColorPicker(false)}
        />
      )}
    </motion.div>
  )
}

export default NewHabitView
```

#### EmojiPicker Component (src/components/EmojiPicker.jsx)
```javascript
import React from 'react'
import { motion } from 'framer-motion'
import { X } from 'lucide-react'

const EMOJI_CATEGORIES = {
  'Activity': ['🏃', '🚴', '🏋️', '🧘', '🏊', '⛹️', '🤸', '🧗', '🏄', '🎯'],
  'Health': ['💊', '🩺', '🫀', '🧠', '🦷', '👁️', '💪', '🍎', '🥗', '💧'],
  'Learning': ['📚', '✏️', '📝', '🎓', '📖', '🧮', '🔬', '🎨', '🎭', '🎪'],
  'Work': ['💼', '💻', '⌨️', '🖥️', '📊', '📈', '📋', '✅', '🔨', '⚙️'],
  'Social': ['👥', '💬', '📞', '🤝', '❤️', '👨‍👩‍👧', '🎉', '🎊', '🎁', '🌟'],
  'Nature': ['🌱', '🌿', '🌻', '🌺', '🌹', '🌲', '🌳', '☀️', '🌙', '⭐'],
  'Food': ['🍎', '🥗', '🥑', '🍊', '🍇', '🥦', '🥕', '☕', '🫖', '🥤'],
  'Other': ['⚡', '🔥', '💎', '🎯', '🚀', '💫', '✨', '🎪', '🎭', '🎨']
}

const EmojiPicker = ({ currentEmoji, onSelect, onClose }) => {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/60 backdrop-blur-md z-[60] flex items-end"
      onClick={onClose}
    >
      <motion.div
        initial={{ y: '100%' }}
        animate={{ y: 0 }}
        exit={{ y: '100%' }}
        transition={{ type: 'spring', damping: 30, stiffness: 300 }}
        onClick={(e) => e.stopPropagation()}
        className="w-full bg-dark-card rounded-t-3xl max-h-[80vh] overflow-hidden"
        style={{ maxWidth: '428px', margin: '0 auto' }}
      >
        {/* Header */}
        <div className="sticky top-0 bg-dark-card/95 backdrop-blur-sm border-b border-dark-border">
          <div className="flex items-center justify-between px-6 py-4">
            <h3 className="text-lg font-semibold text-dark-text-primary">
              Choose Icon
            </h3>
            <button
              onClick={onClose}
              className="w-8 h-8 rounded-full bg-dark-bg flex items-center justify-center"
            >
              <X className="w-5 h-5 text-dark-text-primary" />
            </button>
          </div>
        </div>
        
        {/* Emoji Grid */}
        <div className="overflow-y-auto p-6 space-y-6" style={{ maxHeight: 'calc(80vh - 64px)' }}>
          {Object.entries(EMOJI_CATEGORIES).map(([category, emojis]) => (
            <div key={category}>
              <h4 className="text-sm font-medium text-dark-text-secondary mb-3">
                {category}
              </h4>
              <div className="grid grid-cols-5 gap-3">
                {emojis.map((emoji) => (
                  <motion.button
                    key={emoji}
                    onClick={() => onSelect(emoji)}
                    whileTap={{ scale: 0.9 }}
                    className={`aspect-square rounded-xl flex items-center justify-center text-3xl transition-all ${
                      emoji === currentEmoji
                        ? 'bg-habit-purple ring-2 ring-habit-purple ring-offset-2 ring-offset-dark-card'
                        : 'bg-dark-bg hover:bg-dark-border'
                    }`}
                  >
                    {emoji}
                  </motion.button>
                ))}
              </div>
            </div>
          ))}
        </div>
      </motion.div>
    </motion.div>
  )
}

export default EmojiPicker
```

#### ColorPicker Component (src/components/ColorPicker.jsx)
```javascript
import React from 'react'
import { motion } from 'framer-motion'
import { X, Check } from 'lucide-react'

const COLORS = [
  { name: 'Purple', value: '#a855f7' },
  { name: 'Red', value: '#ef4444' },
  { name: 'Blue', value: '#3b82f6' },
  { name: 'Green', value: '#10b981' },
  { name: 'Yellow', value: '#f59e0b' },
  { name: 'Pink', value: '#ec4899' },
  { name: 'Indigo', value: '#6366f1' },
  { name: 'Teal', value: '#14b8a6' },
  { name: 'Orange', value: '#f97316' },
  { name: 'Gray', value: '#6b7280' }
]

const ColorPicker = ({ currentColor, onSelect, onClose }) => {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/60 backdrop-blur-md z-[60] flex items-end"
      onClick={onClose}
    >
      <motion.div
        initial={{ y: '100%' }}
        animate={{ y: 0 }}
        exit={{ y: '100%' }}
        transition={{ type: 'spring', damping: 30, stiffness: 300 }}
        onClick={(e) => e.stopPropagation()}
        className="w-full bg-dark-card rounded-t-3xl overflow-hidden"
        style={{ maxWidth: '428px', margin: '0 auto' }}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-dark-border">
          <h3 className="text-lg font-semibold text-dark-text-primary">
            Choose Color
          </h3>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-dark-bg flex items-center justify-center"
          >
            <X className="w-5 h-5 text-dark-text-primary" />
          </button>
        </div>
        
        {/* Color Grid */}
        <div className="p-6">
          <div className="grid grid-cols-5 gap-4">
            {COLORS.map((color) => (
              <motion.button
                key={color.value}
                onClick={() => onSelect(color.value)}
                whileTap={{ scale: 0.9 }}
                className="aspect-square rounded-2xl relative flex items-center justify-center"
                style={{ backgroundColor: color.value }}
              >
                {currentColor === color.value && (
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ type: 'spring', stiffness: 500, damping: 30 }}
                  >
                    <Check className="w-6 h-6 text-white" strokeWidth={3} />
                  </motion.div>
                )}
              </motion.button>
            ))}
          </div>
        </div>
      </motion.div>
    </motion.div>
  )
}

export default ColorPicker
```

### Compact List Settings Component

#### CompactListSettings Component (src/components/CompactListSettings.jsx)
```javascript
import React, { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { X } from 'lucide-react'
import { useSettings } from '../hooks/useSettings'

const CompactListSettings = ({ isOpen, onClose }) => {
  const { settings, updateSettings } = useSettings()
  const [localCompactDays, setLocalCompactDays] = useState(settings.compactDays)
  const [localShowNames, setLocalShowNames] = useState(settings.showHabitNames)
  
  useEffect(() => {
    if (settings) {
      setLocalCompactDays(settings.compactDays)
      setLocalShowNames(settings.showHabitNames)
    }
  }, [settings])
  
  const handleDaysChange = async (days) => {
    setLocalCompactDays(days)
    try {
      await updateSettings(days, null)
    } catch (error) {
      console.error('Error updating compact days:', error)
    }
  }
  
  const handleNamesToggle = async (show) => {
    setLocalShowNames(show)
    try {
      await updateSettings(null, show)
    } catch (error) {
      console.error('Error updating show names:', error)
    }
  }
  
  if (!isOpen) return null
  
  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop WITHOUT blur (different from detail modal) */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/60 z-40"
          />
          
          {/* Settings Panel */}
          <motion.div
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={{ type: 'spring', damping: 30, stiffness: 300 }}
            className="fixed inset-x-0 bottom-0 z-50 bg-dark-card rounded-t-3xl overflow-hidden"
            style={{
              maxWidth: '428px',
              margin: '0 auto',
              maxHeight: '85vh'
            }}
          >
            {/* Header */}
            <div className="flex items-center justify-between px-6 py-4 border-b border-dark-border">
              <h2 className="text-xl font-bold text-dark-text-primary">
                Compact List Settings
              </h2>
              <button
                onClick={onClose}
                className="w-8 h-8 rounded-full bg-dark-bg flex items-center justify-center hover:bg-opacity-80 transition-all"
              >
                <X className="w-5 h-5 text-dark-text-primary" />
              </button>
            </div>
            
            {/* Content */}
            <div className="p-6 space-y-8">
              {/* Days Selection */}
              <div>
                <h3 className="text-base font-semibold text-dark-text-primary mb-2">
                  Number of Days
                </h3>
                <p className="text-sm text-dark-text-secondary mb-4">
                  Configure the amount of days to display in the compact list
                </p>
                
                <div className="grid grid-cols-7 gap-2">
                  {[1, 2, 3, 4, 5, 6, 7].map((days) => (
                    <motion.button
                      key={days}
                      onClick={() => handleDaysChange(days)}
                      whileTap={{ scale: 0.95 }}
                      className={`aspect-square rounded-2xl font-semibold text-lg transition-all ${
                        localCompactDays === days
                          ? 'bg-habit-purple text-white'
                          : 'bg-dark-bg text-dark-text-primary hover:bg-dark-border'
                      }`}
                    >
                      {days}
                    </motion.button>
                  ))}
                </div>
              </div>
              
              {/* Name Visibility Toggle */}
              <div>
                <h3 className="text-base font-semibold text-dark-text-primary mb-2">
                  Habit Names
                </h3>
                <p className="text-sm text-dark-text-secondary mb-4">
                  Configure whether the habit names will be hidden or not
                </p>
                
                <div className="flex gap-3">
                  <motion.button
                    onClick={() => handleNamesToggle(false)}
                    whileTap={{ scale: 0.98 }}
                    className={`flex-1 py-4 rounded-xl font-medium transition-all ${
                      !localShowNames
                        ? 'bg-dark-bg text-dark-text-primary border-2 border-dark-text-primary'
                        : 'bg-dark-bg text-dark-text-secondary border-2 border-dark-border hover:border-dark-text-muted'
                    }`}
                  >
                    Hidden
                  </motion.button>
                  
                  <motion.button
                    onClick={() => handleNamesToggle(true)}
                    whileTap={{ scale: 0.98 }}
                    className={`flex-1 py-4 rounded-xl font-medium transition-all ${
                      localShowNames
                        ? 'bg-dark-bg text-dark-text-primary border-2 border-dark-text-primary'
                        : 'bg-dark-bg text-dark-text-secondary border-2 border-dark-border hover:border-dark-text-muted'
                    }`}
                  >
                    Shown
                  </motion.button>
                </div>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}

export default CompactListSettings
```

---

## 8. MAIN APP COMPONENT & ROUTING

### App.jsx (src/App.jsx)
```javascript
import React, { useState } from 'react'
import { useHabits } from './hooks/useHabits'
import HabitList from './components/HabitList'
import HabitDetailModal from './components/HabitDetailModal'
import NewHabitView from './components/NewHabitView'
import CompactListSettings from './components/CompactListSettings'

function App() {
  const { habits, loading, createHabit, toggleCompletion } = useHabits()
  const [selectedHabit, setSelectedHabit] = useState(null)
  const [showNewHabit, setShowNewHabit] = useState(false)
  const [showSettings, setShowSettings] = useState(false)
  
  const handleToggleDay = async (externalId, date) => {
    await toggleCompletion(externalId, date)
  }
  
  const handleCreateHabit = async (habitData) => {
    await createHabit(habitData)
    setShowNewHabit(false)
  }
  
  if (loading) {
    return (
      <div className="min-h-screen bg-dark-bg flex items-center justify-center">
        <div className="w-12 h-12 border-4 border-habit-purple border-t-transparent rounded-full animate-spin" />
      </div>
    )
  }
  
  return (
    <div className="min-h-screen bg-dark-bg">
      {showNewHabit ? (
        <NewHabitView
          onClose={() => setShowNewHabit(false)}
          onSave={handleCreateHabit}
        />
      ) : (
        <HabitList
          habits={habits}
          onHabitClick={setSelectedHabit}
          onToggleDay={handleToggleDay}
          onAddHabit={() => setShowNewHabit(true)}
          onOpenSettings={() => setShowSettings(true)}
        />
      )}
      
      <HabitDetailModal
        habit={selectedHabit}
        isOpen={!!selectedHabit}
        onClose={() => setSelectedHabit(null)}
        onToggleDay={handleToggleDay}
      />
      
      <CompactListSettings
        isOpen={showSettings}
        onClose={() => setShowSettings(false)}
      />
    </div>
  )
}

export default App
```

### main.jsx (src/main.jsx)
```javascript
import React from 'react'
import ReactDOM from 'react-dom/client'
import { ApolloProvider } from '@apollo/client'
import client from './graphql/client'
import App from './App.jsx'
import './index.css'

// Register service worker for PWA
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then(registration => console.log('SW registered:', registration))
      .catch(error => console.log('SW registration failed:', error))
  })
}

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <ApolloProvider client={client}>
      <App />
    </ApolloProvider>
  </React.StrictMode>
)
```

### index.css (src/index.css)
```css
@tailwind base;
@tailwind components;
@tailwind utilities;

* {
  -webkit-tap-highlight-color: transparent;
}

html {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  background-color: #0a0a0a;
  color: #ffffff;
  overflow-x: hidden;
}

#root {
  min-height: 100vh;
  max-width: 428px;
  margin: 0 auto;
  background-color: #0a0a0a;
}

/* Custom scrollbar for webkit browsers */
::-webkit-scrollbar {
  width: 6px;
}

::-webkit-scrollbar-track {
  background: #1a1a1a;
}

::-webkit-scrollbar-thumb {
  background: #2a2a2a;
  border-radius: 3px;
}

::-webkit-scrollbar-thumb:hover {
  background: #3a3a3a;
}

/* Prevent pull-to-refresh on mobile */
body {
  overscroll-behavior-y: contain;
}

/* Smooth transitions for all interactive elements */
button,
input,
textarea {
  transition: all 0.2s ease-out;
}

/* Focus styles */
input:focus,
textarea:focus {
  outline: none;
}
```

### index.html
```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/png" href="/icon-192.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <meta name="theme-color" content="#0a0a0a" />
    <meta name="description" content="Track your daily habits with HabitKit" />
    <link rel="apple-touch-icon" href="/icon-192.png" />
    <link rel="manifest" href="/manifest.webmanifest" />
    <title>HabitKit - Daily Habit Tracker</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
```

---

## 9. CRITICAL UX/UI REQUIREMENTS

### Mobile-First Responsive Design
1. **Maximum width constraint**: All content must be constrained to `max-width: 428px` (iPhone size)
2. **Desktop behavior**: When accessed from desktop, show the mobile interface centered with the same mobile dimensions
3. **No responsive breakpoints**: DO NOT change layout for larger screens - maintain mobile interface everywhere
4. **Viewport settings**: Use `user-scalable=no` to prevent zoom gestures
5. **Touch targets**: All interactive elements minimum 44x44px

### Dark Theme Specifications
- **Background**: `#0a0a0a` (very dark, almost black)
- **Cards**: `#1a1a1a` (slightly lighter)
- **Borders**: `#2a2a2a` (subtle borders)
- **Text primary**: `#ffffff` (pure white)
- **Text secondary**: `#a0a0a0` (medium gray)
- **Text muted**: `#666666` (dark gray)

### Animation Requirements
1. **Modal slide-up**: Use Framer Motion with spring animation (`damping: 30, stiffness: 300`)
2. **Backdrop blur**: Apply `backdrop-blur-md` (12px blur) to modal backgrounds
3. **Button feedback**: Use `whileTap={{ scale: 0.95 }}` for all pressable elements
4. **List item stagger**: Animate list items with 50ms delay between each
5. **Completion toggle**: Scale animation when marking habits complete

### Navigation Patterns
1. **Close with X**: All modals and detail views have X button in top-right
2. **Backdrop tap**: Tapping background closes the modal
3. **Gesture hint**: Modals should start slightly below the top (85-90vh height)
4. **History tracking**: Maintain navigation history to return to previous view

### Modal Types (Important Distinction)
1. **Habit Detail Modal** (Image 2)
   - Slides up from bottom
   - **Blurred backdrop** (`backdrop-blur-md`)
   - Full calendar view
   - 90vh max height

2. **Compact List Settings Panel** (Image 5 - New)
   - Slides up from bottom
   - **Dark backdrop WITHOUT blur** (just `bg-black/60`)
   - Settings controls (days selector, name toggle)
   - 85vh max height
   - Opened by tapping "Last N days" button

3. **New Habit View** (Images 3-4)
   - Full screen slide from right
   - No backdrop (full page replacement)
   - Form with emoji/color pickers

### Completion States (Future-Proof Design)
The app uses an enum-based system for habit completion states, allowing for future expansion:

**Current States (Implement these first):**
- `NOT_STARTED` (default) - Habit not attempted yet
- `COMPLETED` - Habit successfully completed

**Future States (Prepared for):**
- `IN_PROGRESS` - Habit is being worked on
- `SKIPPED` - User intentionally skipped the habit
- `FAILED` - Habit was attempted but not completed

**UI Implementation Notes:**
- For MVP, only toggle between `NOT_STARTED` and `COMPLETED`
- Square should be empty/outlined for `NOT_STARTED`
- Square should be filled with habit color for `COMPLETED`
- Backend supports all states, frontend can be expanded later
- Use GraphQL enum `CompletionStateEnum` in mutations

**Quick Reference - Completion State Values:**
```javascript
// GraphQL Enum Values
NOT_STARTED  // maps to: "not_started"
IN_PROGRESS  // maps to: "in_progress"
COMPLETED    // maps to: "completed"
SKIPPED      // maps to: "skipped"
FAILED       // maps to: "failed"

// Backend Ruby Constants
Habit::COMPLETION_STATES = [
  'not_started',
  'in_progress',
  'completed',
  'skipped',
  'failed'
]

// JSON Structure in Database
{
  "date": "2024-01-15",
  "state": "completed",
  "completed_at": "2024-01-15T14:32:00Z",
  "notes": "optional notes"
}
```

### Data Synchronization
1. **Apollo Client caching**: Automatic cache updates after mutations
2. **Optimistic responses**: Can be added for instant UI feedback
3. **Real-time reflection**: Changes in detail view instantly reflect in list view via cache
4. **Error handling**: Show user-friendly error messages from GraphQL errors array
5. **Loading states**: Apollo provides loading states for all queries/mutations
6. **Refetch strategies**: Use `cache-and-network` policy for fresh data

---

## 10. DEPLOYMENT & TESTING

### Database Setup Commands
```bash
cd backend
rails db:create
rails db:migrate
rails db:seed  # Creates default user settings
```

### Database Seeds (db/seeds.rb)
```ruby
# Create default user settings
UserSettings.find_or_create_by!(external_id: 'default-settings') do |settings|
  settings.compact_days = 5
  settings.show_habit_names = true
end

puts "✅ Default user settings created"

# Optional: Create sample habits for testing
if Rails.env.development?
  Habit.find_or_create_by!(external_id: 'sample-habit-1') do |habit|
    habit.name = "Morning Exercise"
    habit.emoji = "🏃"
    habit.color = "#10b981"
    habit.streak_goal = "daily"
  end
  
  puts "✅ Sample habit created (development only)"
end
```

### Running the Application
```bash
# Option 1: Use startup script
./start-dev.sh

# Option 2: Manual start
# Terminal 1 - Backend
cd backend && rails server -p 3001

# Terminal 2 - Frontend
npm run dev
```

### Access URLs
- **Frontend**: http://localhost:5173
- **GraphQL API**: http://localhost:3001/graphql
- **GraphiQL IDE**: http://localhost:3001/graphiql (development only)
- **Mobile testing**: http://[YOUR-LOCAL-IP]:5173

### Mobile Testing Setup
1. Get your local IP: `ifconfig | grep "inet " | grep -v 127.0.0.1`
2. Update CORS in `backend/config/initializers/cors.rb` to allow your IP
3. Access from mobile browser: `http://192.168.1.XXX:5173`
4. Add to home screen for PWA experience

### PWA Installation
1. Open in mobile browser (Chrome/Safari)
2. Tap "Share" button
3. Select "Add to Home Screen"
4. App will launch in standalone mode (no browser UI)

---

## 11. FINAL CHECKLIST

### Backend Completion
- [ ] Rails API setup with PostgreSQL
- [ ] GraphQL schema and types configured
- [ ] Completion states enum created (5 states)
- [ ] Habit model with state-based completions
- [ ] UserSettings model for preferences
- [ ] Date/time awareness (Time.current, Date.current)
- [ ] Streak calculations implemented
- [ ] Dynamic lastNDays field on Habit type
- [ ] All GraphQL queries functional (including userSettings)
- [ ] All GraphQL mutations functional (including updateUserSettings)
- [ ] CORS configured for frontend access
- [ ] GraphiQL IDE accessible in development

### Frontend Completion
- [ ] React + Vite + TailwindCSS configured
- [ ] Apollo Client setup and configured
- [ ] GraphQL queries and mutations defined (habits + settings)
- [ ] Fragments for reusable fields
- [ ] PWA manifest and service worker
- [ ] HabitList with dynamic days view
- [ ] HabitCard respects showName setting
- [ ] CompactListSettings panel (days + name toggle)
- [ ] HabitDetailModal with calendar
- [ ] NewHabitView with emoji/color pickers
- [ ] Framer Motion animations implemented
- [ ] Custom hooks using Apollo Client (useHabits + useSettings)
- [ ] ApolloProvider wrapping app

### UX/UI Completion
- [ ] Dark theme exactly matched
- [ ] Mobile-first design (max-width: 428px)
- [ ] Desktop shows mobile interface
- [ ] Modal slide-up with backdrop blur
- [ ] X button closes modals
- [ ] Tap day squares to toggle completion
- [ ] Changes sync between all views
- [ ] Smooth animations and transitions

### Testing & Deployment
- [ ] Local development runs without errors
- [ ] Database migrations successful (including enum)
- [ ] GraphQL queries return correct data
- [ ] GraphQL mutations work properly
- [ ] Apollo Client cache updates correctly
- [ ] Frontend connects to GraphQL backend
- [ ] Server time/date synchronization works
- [ ] PWA installable on mobile
- [ ] Touch interactions work smoothly
- [ ] No layout shifts or jank

### GraphQL API Testing (via GraphiQL)
Test these queries and mutations in http://localhost:3001/graphiql:

**Test Query - Get all habits:**
```graphql
query {
  habits {
    externalId
    name
    emoji
    color
    currentStreak
    last5Days {
      date
      state
      completed
    }
  }
}
```

**Test Mutation - Create habit:**
```graphql
mutation {
  createHabit(input: {
    name: "Morning Meditation"
    emoji: "🧘"
    color: "#6366f1"
    streakGoal: DAILY
  }) {
    habit {
      externalId
      name
      currentStreak
    }
    errors
  }
}
```

**Test Mutation - Toggle completion:**
```graphql
mutation {
  toggleHabitCompletion(input: {
    externalId: "your-habit-id-here"
    date: "2024-01-15"
  }) {
    habit {
      externalId
      currentStreak
      last5Days {
        date
        state
        completed
      }
    }
    newState
    errors
  }
}
```

**Test Query - Get month data:**
```graphql
query {
  habitMonthData(
    externalId: "your-habit-id-here"
    year: 2024
    month: 1
  ) {
    date
    state
    completed
  }
}
```

**Test Query - Server time sync:**
```graphql
query {
  currentServerTime
  currentServerDate
}
```

**Test Query - Get user settings:**
```graphql
query {
  userSettings {
    externalId
    compactDays
    showHabitNames
  }
}
```

**Test Mutation - Update settings:**
```graphql
mutation {
  updateUserSettings(input: {
    compactDays: 7
    showHabitNames: false
  }) {
    userSettings {
      compactDays
      showHabitNames
    }
    errors
  }
}
```

---

## 12. SUCCESS CRITERIA

The project is complete when:

1. **Functional**: User can create habits, mark them complete/incomplete on any day, view calendar history
2. **Visual**: Matches the dark theme and layout of provided screenshots exactly
3. **Mobile-first**: Works perfectly on mobile, maintains mobile interface on desktop
4. **PWA**: Installable as home screen app with offline capability
5. **Performant**: Animations are smooth, no lag, instant UI updates
6. **Synced**: All UI components reflect the same data state in real-time

---

## IMPLEMENTATION ORDER

1. **Setup** (30 min)
   - Install backend dependencies (Rails, PostgreSQL, GraphQL gems)
   - Install frontend dependencies (React, Apollo Client, etc.)
   - Configure database (database.yml)
   - Setup CORS

2. **Backend - Database & Models** (1 hour)
   - Create completion states enum migration
   - Create Habit model and migration
   - Create UserSettings model and migration
   - Configure timezone awareness (config/application.rb)
   - Add validations and methods to both models
   - Create seed file for default settings
   - Test with Rails console

3. **Backend - GraphQL API** (2 hours)
   - Install and generate GraphQL (`rails generate graphql:install`)
   - Define GraphQL types (Habit, Completion, UserSettings, Enums, Stats)
   - Create Query type with all queries (habits, habit, settings, serverTime)
   - Create Mutation type with all mutations (habits + settings)
   - Implement resolvers
   - Test with GraphiQL IDE

4. **Frontend - Apollo Setup** (1 hour)
   - Configure Apollo Client
   - Define GraphQL fragments
   - Write all queries (habits + settings)
   - Write all mutations (habits + settings)
   - Wrap app with ApolloProvider

5. **Frontend - Custom Hooks** (45 min)
   - Create useHabits hook with Apollo
   - Create useSettings hook with Apollo
   - Create useCalendar hook
   - Test data fetching and mutations

6. **Frontend - UI Components** (3.5 hours)
   - Setup Tailwind with dark theme
   - HabitList with settings button
   - HabitCard with conditional name display
   - CompactListSettings panel
   - HabitDetailModal with CalendarGrid
   - NewHabitView with emoji/color pickers
   - Connect all components to GraphQL hooks

7. **Polish & Testing** (1 hour)
   - Add Framer Motion animations
   - Test all interactions (including settings)
   - Test GraphQL queries/mutations
   - PWA configuration
   - Mobile testing
   - Test on actual device

**Total estimated time: 9-10 hours for experienced developer**

### Critical Implementation Notes

1. **Always use Date.current and Time.current** in backend code
2. **Enum states** are stored in JSON but validated against COMPLETION_STATES array
3. **Apollo Client cache** automatically updates UI after mutations
4. **GraphQL fragments** reduce code duplication and ensure consistency
5. **Mobile-first** means test on mobile device from day one
6. **GraphiQL IDE** is your friend for testing backend before building frontend
7. **Settings are global** (one UserSettings record) but designed to easily scale to per-user settings
8. **Compact days range** is 1-7 (validated in model and UI)

### Compact List Settings Feature (New)

**User Story:**
"As a user, I want to customize how many days I see in my habit list (1-7) and whether habit names are visible, so I can have a more compact or detailed view based on my preference."

**How it works:**
1. User taps on "Last N days" text in the header
2. Settings panel slides up (dark backdrop, no blur)
3. User selects days (1-7) via number buttons
4. User toggles name visibility (Hidden/Shown)
5. Changes apply immediately to all habit cards
6. Settings persist in database (UserSettings model)
7. Close with X button or tap backdrop

**Technical Implementation:**
- Backend: UserSettings table with `compact_days` (1-7) and `show_habit_names` (boolean)
- GraphQL: `userSettings` query and `updateUserSettings` mutation
- Frontend: `useSettings` hook, `CompactListSettings` component
- HabitCard: Conditionally renders name based on `showHabitNames`
- HabitCard: Slices `last_5_days` to show N days based on `compactDays`

**UI States:**
- Days: 1-7 (purple highlight for selected)
- Names: Hidden (only emoji + squares) or Shown (emoji + name + description + squares)

---

## 13. KEY DIFFERENCES FROM TYPICAL REST API SETUP

### GraphQL vs REST
| Aspect | REST API | This Project (GraphQL) |
|--------|----------|------------------------|
| **Endpoint** | Multiple (`/api/v1/habits`, `/api/v1/habits/:id`) | Single (`/graphql`) |
| **Data Fetching** | Multiple requests, over-fetching | Single request, exact fields |
| **Client Library** | `fetch()` or `axios` | Apollo Client |
| **Caching** | Manual or library-based | Automatic via Apollo Cache |
| **Type Safety** | Manual validation | GraphQL schema enforces types |
| **Real-time Updates** | Polling or WebSockets | Built-in subscriptions (optional) |
| **Documentation** | Swagger/OpenAPI | Self-documenting via GraphiQL |
| **Testing** | cURL/Postman | GraphiQL IDE |

### Why GraphQL for This Project?

1. **Single Query for Complex Data**: Get habit with last 5 days + stats + streaks in one request
2. **Automatic Cache Management**: Apollo Client handles cache invalidation and updates
3. **No Over-fetching**: Frontend requests only the fields it needs
4. **Type Safety**: GraphQL schema validates all inputs/outputs
5. **Better Developer Experience**: GraphiQL IDE for testing, auto-completion in queries
6. **Future-Proof**: Easy to add subscriptions for real-time updates later

### Enum Benefits

1. **Extensibility**: Add new states (`paused`, `archived`) without database changes
2. **Validation**: Backend validates against allowed values automatically
3. **Type Safety**: GraphQL enum ensures only valid states can be sent
4. **Code Clarity**: `COMPLETED` is clearer than `true` or `1`
5. **Future Features**: Can add state-specific logic (e.g., different colors for `skipped` vs `failed`)

### Date/Time Awareness Benefits

1. **Consistent Behavior**: All date operations use server's configured timezone
2. **No Clock Drift**: Client syncs with server time via GraphQL query
3. **Accurate Streaks**: Streak calculations based on server date, not client date
4. **Time Travel Safe**: Can set server time for testing without breaking logic
5. **Global Users Ready**: Easy to add per-user timezone support later

---

## 14. COMMON PITFALLS TO AVOID

### Backend
- ❌ **DON'T** use `Date.today` or `Time.now` → ✅ **DO** use `Date.current` or `Time.current`
- ❌ **DON'T** hardcode state strings → ✅ **DO** use `Habit::COMPLETION_STATES` constant
- ❌ **DON'T** return raw hashes → ✅ **DO** use GraphQL types for structure
- ❌ **DON'T** expose database IDs → ✅ **DO** use `external_id` (UUID)
- ❌ **DON'T** forget to update streaks → ✅ **DO** use `after_save` callback

### Frontend
- ❌ **DON'T** use `fetch()` → ✅ **DO** use Apollo Client hooks
- ❌ **DON'T** manage cache manually → ✅ **DO** let Apollo handle cache updates
- ❌ **DON'T** forget fragments → ✅ **DO** use fragments for reusable fields
- ❌ **DON'T** query on every render → ✅ **DO** use `cache-and-network` policy
- ❌ **DON'T** ignore loading/error states → ✅ **DO** show loading spinners and error messages

### GraphQL Specific
- ❌ **DON'T** create separate queries for each field → ✅ **DO** request all needed fields in one query
- ❌ **DON'T** forget input objects → ✅ **DO** wrap mutation arguments in `input` object
- ❌ **DON'T** return null errors → ✅ **DO** return `errors` array in mutation responses
- ❌ **DON'T** skip refetchQueries → ✅ **DO** use cache updates or refetch after mutations

---

END OF PROMPT

**Total Prompt Length**: ~2,200 lines
**Estimated Implementation Time**: 8-9 hours
**Difficulty Level**: Intermediate to Advanced
**Prerequisites**: Ruby on Rails, React, GraphQL basics

**Ready to paste into another LLM to build the complete application.**

