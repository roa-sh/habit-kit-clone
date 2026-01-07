module Types
  class CompletionType < Types::BaseObject
    description "A single completion record for a habit on a specific date"
    
    field :date, String, null: false, description: "The date of completion (YYYY-MM-DD)"
    field :state, Types::CompletionStateEnum, null: false, description: "Current state of the completion"
    field :completed, Boolean, null: false, description: "Quick check if completed"
    field :completed_at, GraphQL::Types::ISO8601DateTime, null: true, description: "When it was marked completed"
    field :notes, String, null: true, description: "Optional notes"
    
    def completed
      object['state'] == 'completed' || object[:state] == 'completed'
    end
    
    def completed_at
      completed_at_str = object['completed_at'] || object[:completed_at]
      Time.parse(completed_at_str) if completed_at_str
    end
    
    def date
      object['date'] || object[:date]
    end
    
    def state
      object['state'] || object[:state]
    end
    
    def notes
      object['notes'] || object[:notes]
    end
  end
end

