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

