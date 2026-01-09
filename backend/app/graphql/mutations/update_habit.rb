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
