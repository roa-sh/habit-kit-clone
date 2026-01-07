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
