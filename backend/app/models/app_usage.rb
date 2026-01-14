class AppUsage < ApplicationRecord
  validates :package_name, presence: true
  validates :total_time_ms, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :recorded_at, presence: true

  # Scopes for querying
  scope :recent, -> { order(recorded_at: :desc) }
  scope :today, -> { where('recorded_at >= ?', Time.zone.now.beginning_of_day) }
  scope :this_week, -> { where('recorded_at >= ?', 1.week.ago) }
  scope :for_package, ->(package) { where(package_name: package) }

  # Convert milliseconds to human-readable format
  def time_in_minutes
    (total_time_ms / 60_000.0).round(2)
  end

  def time_in_hours
    (total_time_ms / 3_600_000.0).round(2)
  end

  # Get app name from package (basic cleanup)
  def app_name
    display_name.presence || package_name.split('.').last.titleize
  end
end
