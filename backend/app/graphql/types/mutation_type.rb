module Types
  class MutationType < Types::BaseObject
    description "The mutation root of the GraphQL schema"
    
    # Create Habit
    field :create_habit, mutation: Mutations::CreateHabit
    
    # Update Habit
    field :update_habit, mutation: Mutations::UpdateHabit
    
    # Delete Habit
    field :delete_habit, mutation: Mutations::DeleteHabit
    
    # Toggle Completion (simplified version)
    field :toggle_habit_completion, mutation: Mutations::ToggleHabitCompletion
    
    # Update Completion State (advanced version with state selection)
    field :update_habit_completion, mutation: Mutations::UpdateHabitCompletion
    
    # Update User Settings
    field :update_user_settings, mutation: Mutations::UpdateUserSettings
  end
end
