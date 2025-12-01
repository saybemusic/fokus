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

ActiveRecord::Schema[7.1].define(version: 2025_12_01_133650) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "objectives", force: :cascade do |t|
    t.text "system_prompt"
    t.string "goal"
    t.text "resume"
    t.integer "time_global"
    t.integer "time_due"
    t.date "completed_at"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "completed", default: false
    t.index ["user_id"], name: "index_objectives_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.text "ressource_ia"
    t.boolean "completed", default: false
    t.integer "priority"
    t.date "completed_at"
    t.bigint "todo_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["todo_id"], name: "index_tasks_on_todo_id"
  end

  create_table "todos", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "completed", default: false
    t.date "due_date"
    t.date "completed_at"
    t.bigint "objective_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["objective_id"], name: "index_todos_on_objective_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "objectives", "users"
  add_foreign_key "tasks", "todos"
  add_foreign_key "todos", "objectives"
end
