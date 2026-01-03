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

