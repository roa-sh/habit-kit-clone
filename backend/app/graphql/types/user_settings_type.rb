module Types
  class UserSettingsType < Types::BaseObject
    description "User preferences for the habit tracker"
    
    field :id, ID, null: false
    field :external_id, String, null: false
    field :compact_days, Integer, null: false, description: "Number of days to show in compact list (1-7)"
    field :show_habit_names, Boolean, null: false, description: "Whether to show habit names in the list"
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

