# Create default user settings
UserSettings.find_or_create_by!(external_id: 'default-settings') do |settings|
  settings.compact_days = 5
  settings.show_habit_names = true
end

puts "✅ Default user settings created"

# Optional: Create sample habits for testing
if Rails.env.development?
  Habit.find_or_create_by!(external_id: 'sample-habit-1') do |habit|
    habit.name = "Morning Exercise"
    habit.emoji = "🏃"
    habit.color = "#10b981"
    habit.streak_goal = "daily"
    habit.description = "30 minutes of cardio"
  end
  
  puts "✅ Sample habit created (development only)"
end

