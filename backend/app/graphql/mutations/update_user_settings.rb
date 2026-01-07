module Mutations
  class UpdateUserSettings < BaseMutation
    description "Update user settings for compact list display"
    
    argument :compact_days, Integer, required: false, description: "Number of days to show (1-7)"
    argument :show_habit_names, Boolean, required: false, description: "Show or hide habit names"
    
    field :user_settings, Types::UserSettingsType, null: true
    field :errors, [String], null: false
    
    def resolve(compact_days: nil, show_habit_names: nil)
      settings = UserSettings.current
      
      # Update only provided fields
      attributes = {}
      attributes[:compact_days] = compact_days if compact_days.present?
      attributes[:show_habit_names] = show_habit_names unless show_habit_names.nil?
      
      if settings.update(attributes)
        { user_settings: settings, errors: [] }
      else
        { user_settings: nil, errors: settings.errors.full_messages }
      end
    end
  end
end

