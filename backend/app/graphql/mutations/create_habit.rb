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

