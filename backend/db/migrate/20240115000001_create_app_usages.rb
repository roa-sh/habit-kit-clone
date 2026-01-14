class CreateAppUsages < ActiveRecord::Migration[7.0]
  def change
    create_table :app_usages do |t|
      t.string :package_name, null: false, index: true
      t.string :display_name
      t.bigint :total_time_ms, null: false, default: 0
      t.datetime :recorded_at, null: false, index: true

      t.timestamps
    end

    # Composite index for efficient queries
    add_index :app_usages, [:package_name, :recorded_at]
    add_index :app_usages, [:recorded_at, :total_time_ms]
  end
end
