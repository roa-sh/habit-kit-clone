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

