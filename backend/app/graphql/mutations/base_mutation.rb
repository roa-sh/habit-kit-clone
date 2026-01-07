module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject
    
    # Provide access to context
    def current_user
      context[:current_user]
    end
    
    def current_time
      context[:current_time] || Time.current
    end
    
    def current_date
      context[:current_date] || Date.current
    end
  end
end
