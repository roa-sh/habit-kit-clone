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
