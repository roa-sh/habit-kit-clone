module Mutations
  class DeleteHabit < BaseMutation
    description "Delete a habit"
    
    argument :external_id, String, required: true
    
    field :success, Boolean, null: false
    field :errors, [String], null: false
    
    def resolve(external_id:)
      habit = Habit.find_by(external_id: external_id)
      
      unless habit
        return { success: false, errors: ["Habit not found"] }
      end
      
      if habit.destroy
        { success: true, errors: [] }
      else
        { success: false, errors: habit.errors.full_messages }
      end
    end
  end
end

