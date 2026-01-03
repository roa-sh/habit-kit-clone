class Habit < ApplicationRecord
  # Constants
  STREAK_GOALS = ['none', 'daily', 'weekly', 'monthly'].freeze
  
  # Completion states enum (stored in JSON, but validated)
  COMPLETION_STATES = ['not_started', 'in_progress', 'completed', 'skipped', 'failed'].freeze
  
  # Validations
  validates :external_id, presence: true, uniqueness: true
  validates :name, presence: true, length: { minimum: 1, maximum: 100 }
  validates :color, presence: true, format: { with: /\A#[0-9A-Fa-f]{6}\z/ }
  validates :streak_goal, inclusion: { in: STREAK_GOALS }
  validates :emoji, presence: true
  
  # Callbacks
  before_validation :set_defaults, on: :create
  after_save :update_streaks
  
  # Scopes
  scope :ordered, -> { order(created_at: :desc) }
  scope :active, -> { where("updated_at >= ?", 30.days.ago) }
  
  # Instance Methods
  
  # Get completion state for a specific date
  def state_on(date)
    date_string = date.to_s
    completion = completions.find { |c| c['date'] == date_string }
    completion ? completion['state'] : 'not_started'
  end
  
  # Check if habit is completed on a specific date
  def completed_on?(date)
    state_on(date) == 'completed'
  end
  
  # Update completion state for a specific date
  # IMPORTANT: Uses Time.current for timestamp awareness
  def update_completion(date, state, notes: nil)
    raise ArgumentError, "Invalid state: #{state}" unless COMPLETION_STATES.include?(state)
    
    date_string = date.to_s
    existing_completion = completions.find { |c| c['date'] == date_string }
    
    if existing_completion
      existing_completion['state'] = state
      existing_completion['completed_at'] = Time.current.iso8601
      existing_completion['notes'] = notes if notes
    else
      completions << {
        'date' => date_string,
        'state' => state,
        'completed_at' => Time.current.iso8601,
        'notes' => notes
      }
    end
    
    save
  end
  
  # Toggle between completed and not_started
  def toggle_completion(date)
    current_state = state_on(date)
    new_state = current_state == 'completed' ? 'not_started' : 'completed'
    update_completion(date, new_state)
  end
  
  # Get completion status for last N days (using Date.current)
  def last_n_days_status(n = 5)
    today = Date.current
    (0...n).reverse_each.map do |i|
      date = today - i.days
      {
        date: date.to_s,
        state: state_on(date),
        completed: completed_on?(date)
      }
    end
  end
  
  # Calculate current streak (using Date.current)
  def calculate_current_streak
    return 0 if completions.empty?
    
    completed_dates = completions
      .select { |c| c['state'] == 'completed' }
      .map { |c| Date.parse(c['date']) }
      .sort
      .reverse
    
    return 0 if completed_dates.empty?
    
    today = Date.current
    return 0 if completed_dates.first < today - 1.day
    
    streak = 0
    expected_date = today
    
    completed_dates.each do |date|
      break if date < expected_date - 1.day
      streak += 1 if date >= expected_date - 1.day
      expected_date = date - 1.day
    end
    
    streak
  end
  
  # Calculate longest streak ever
  def calculate_longest_streak
    return 0 if completions.empty?
    
    completed_dates = completions
      .select { |c| c['state'] == 'completed' }
      .map { |c| Date.parse(c['date']) }
      .sort
    
    return 0 if completed_dates.empty?
    
    max_streak = 1
    current_streak = 1
    
    completed_dates.each_cons(2) do |prev_date, curr_date|
      if curr_date == prev_date + 1.day
        current_streak += 1
        max_streak = [max_streak, current_streak].max
      else
        current_streak = 1
      end
    end
    
    max_streak
  end
  
  # Get completion data for a specific month
  def month_completions(year, month)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    
    (start_date..end_date).map do |date|
      {
        date: date.to_s,
        state: state_on(date),
        completed: completed_on?(date)
      }
    end
  end
  
  # Get statistics
  def stats
    completed_count = completions.count { |c| c['state'] == 'completed' }
    skipped_count = completions.count { |c| c['state'] == 'skipped' }
    failed_count = completions.count { |c| c['state'] == 'failed' }
    
    {
      total_completions: completed_count,
      total_skipped: skipped_count,
      total_failed: failed_count,
      current_streak: current_streak,
      longest_streak: longest_streak
    }
  end
  
  private
  
  def set_defaults
    self.external_id ||= SecureRandom.uuid
    self.completions ||= []
    self.current_streak ||= 0
    self.longest_streak ||= 0
  end
  
  def update_streaks
    self.current_streak = calculate_current_streak
    self.longest_streak = [self.longest_streak, calculate_current_streak].max
    update_columns(current_streak: current_streak, longest_streak: longest_streak) if changed?
  end
end

