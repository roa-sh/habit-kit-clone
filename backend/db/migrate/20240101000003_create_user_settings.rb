class CreateUserSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :user_settings do |t|
      t.string :external_id, null: false, index: { unique: true }
      t.integer :compact_days, default: 5, null: false
      t.boolean :show_habit_names, default: true, null: false
      t.timestamps
    end
    
    add_check_constraint :user_settings, "compact_days >= 1 AND compact_days <= 7", 
                         name: "check_compact_days_range"
  end
end

