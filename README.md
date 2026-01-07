# HabitKit Clone - Full Stack Habit Tracker

A mobile-first Progressive Web App for tracking daily habits, built with Rails GraphQL backend and React frontend.

## 🚀 Current Status

### ✅ Completed
- **Backend (Rails 7 + GraphQL + PostgreSQL)**
  - Database schema with completion states enum
  - Habit and UserSettings models with full validation
  - GraphQL schema with all types, queries, and mutations
  - Date/time awareness using `Date.current` and `Time.current`
  - Streak calculation logic
  - CORS configuration for frontend access
  - Server running on port 3001

- **Frontend (React + Vite + Apollo Client)**
  - Apollo Client configured with GraphQL endpoint
  - All GraphQL queries and mutations defined
  - Custom hooks (useHabits, useSettings, useCalendar)
  - TailwindCSS with dark theme configuration
  - PWA configuration with Vite plugin
  - Basic App component with habit display
  - Server running on port 5173

### 🔨 To Complete
The following components need to be created based on the detailed prompt:

1. **UI Components** (in `frontend/src/components/`):
   - `HabitList.jsx` - Main list view with header
   - `HabitCard.jsx` - Individual habit card
   - `DaySquare.jsx` - Day completion square
   - `HabitDetailModal.jsx` - Calendar modal view
   - `CalendarGrid.jsx` - Monthly calendar
   - `NewHabitView.jsx` - Habit creation form
   - `EmojiPicker.jsx` - Emoji selection modal
   - `ColorPicker.jsx` - Color selection modal
   - `CompactListSettings.jsx` - Settings panel

2. **Animations**: Add Framer Motion animations to all components

3. **PWA Assets**: Create icon-192.png and icon-512.png files

## 📦 Installation & Setup

### Prerequisites
- Ruby 3.1.3
- Rails 7.0+
- PostgreSQL 14+
- Node.js 18+
- npm 9+

### Backend Setup
```bash
cd backend
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server -p 3001
```

### Frontend Setup
```bash
cd frontend
npm install
npm run dev
```

## 🌐 Access URLs
- **Frontend**: http://localhost:5173
- **Backend GraphQL**: http://localhost:3001/graphql
- **GraphiQL IDE**: http://localhost:3001/graphiql (development only)

## 🔑 Key Features Implemented

### Backend
- **GraphQL API** with single `/graphql` endpoint
- **5 Completion States**: NOT_STARTED, IN_PROGRESS, COMPLETED, SKIPPED, FAILED
- **Timezone-aware**: All dates use `Date.current` and `Time.current`
- **Streak Tracking**: Automatic calculation of current and longest streaks
- **User Settings**: Configurable compact days (1-7) and name visibility

### Frontend
- **Apollo Client**: Automatic cache management
- **Dark Theme**: Custom Tailwind configuration
- **Mobile-First**: Max-width 428px (iPhone size)
- **PWA Ready**: Service worker and manifest configured

## 📝 GraphQL API Examples

### Create a Habit
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
      currentStreak
    }
    errors
  }
}
```

### Toggle Completion
```graphql
mutation {
  toggleHabitCompletion(input: {
    externalId: "your-habit-id"
    date: "2024-01-15"
  }) {
    habit {
      currentStreak
      last5Days {
        date
        completed
      }
    }
    errors
  }
}
```

### Update Settings
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

## 🎨 Design System

### Colors
- **Background**: `#0a0a0a`
- **Card**: `#1a1a1a`
- **Border**: `#2a2a2a`
- **Primary**: `#a855f7` (purple)
- **Text Primary**: `#ffffff`
- **Text Secondary**: `#a0a0a0`

### Habit Colors
Purple, Red, Blue, Green, Yellow, Pink, Indigo, Teal, Orange, Gray

## 🔧 Next Steps

To complete the full implementation as per the detailed prompt:

1. Create all remaining React components listed above
2. Add Framer Motion animations to modals and interactions
3. Create PWA icon assets (192x192 and 512x512)
4. Test mobile experience and PWA installation
5. Add gesture handling and touch interactions

## 📚 Tech Stack

**Backend:**
- Ruby on Rails 7.0
- PostgreSQL 14
- GraphQL Ruby 2.0
- GraphQL Batch

**Frontend:**
- React 18
- Vite 5
- Apollo Client 3.8
- TailwindCSS 3.3
- Framer Motion 12
- Lucide React (icons)
- date-fns 2.30

## 🐛 Troubleshooting

### PostgreSQL Not Running
```bash
brew services start postgresql@14
```

### Rails Server Won't Start
```bash
cd backend
bundle install
bin/rails db:migrate
```

### Frontend Build Errors
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
```

## 📄 License

This is a learning project based on the HabitKit app design.



