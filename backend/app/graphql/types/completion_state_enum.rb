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

