module Types
  class StreakGoalEnum < Types::BaseEnum
    description "Frequency goals for habit streaks"
    
    value "NONE", "No streak goal", value: "none"
    value "DAILY", "Daily streak goal", value: "daily"
    value "WEEKLY", "Weekly streak goal", value: "weekly"
    value "MONTHLY", "Monthly streak goal", value: "monthly"
  end
end

