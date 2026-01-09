class CreateHabits < ActiveRecord::Migration[6.1]
  def change
    create_table :habits do |t|
      t.string :external_id, null: false, index: { unique: true }
      t.string :name, null: false
      t.text :description
      t.string :emoji, default: '⚡'
      t.string :color, default: '#a855f7'
      t.string :streak_goal, default: 'none' # none, daily, weekly, monthly
      t.json :completions, default: []
      t.integer :current_streak, default: 0
      t.integer :longest_streak, default: 0
      t.timestamps
    end
    
    add_index :habits, :created_at
    add_index :habits, :updated_at
  end
end
