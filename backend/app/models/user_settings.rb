class UserSettings < ApplicationRecord
  # Validations
  validates :external_id, presence: true, uniqueness: true
  validates :compact_days, presence: true, 
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 7 }
  validates :show_habit_names, inclusion: { in: [true, false] }
  
  # Callbacks
  before_validation :set_defaults, on: :create
  
  # Singleton pattern - only one settings record per app
  # In the future, this can be expanded to per-user settings
  def self.current
    first_or_create!(external_id: 'default-settings')
  end
  
  private
  
  def set_defaults
    self.external_id ||= 'default-settings'
    self.compact_days ||= 5
    self.show_habit_names = true if self.show_habit_names.nil?
  end
end
