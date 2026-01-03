# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_01_01_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "completion_state", ["not_started", "in_progress", "completed", "skipped", "failed"]

  create_table "habits", force: :cascade do |t|
    t.string "external_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "emoji", default: "⚡"
    t.string "color", default: "#a855f7"
    t.string "streak_goal", default: "none"
    t.json "completions", default: []
    t.integer "current_streak", default: 0
    t.integer "longest_streak", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_habits_on_created_at"
    t.index ["external_id"], name: "index_habits_on_external_id", unique: true
    t.index ["updated_at"], name: "index_habits_on_updated_at"
  end

  create_table "user_settings", force: :cascade do |t|
    t.string "external_id", null: false
    t.integer "compact_days", default: 5, null: false
    t.boolean "show_habit_names", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_user_settings_on_external_id", unique: true
    t.check_constraint "compact_days >= 1 AND compact_days <= 7", name: "check_compact_days_range"
  end

end
