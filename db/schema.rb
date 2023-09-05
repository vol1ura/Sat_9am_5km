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

ActiveRecord::Schema[7.0].define(version: 2023_09_05_143118) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "activities", force: :cascade do |t|
    t.date "date"
    t.text "description"
    t.boolean "published", default: false, null: false
    t.bigint "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_activities_on_event_id"
  end

  create_table "athletes", force: :cascade do |t|
    t.string "name"
    t.integer "parkrun_code"
    t.bigint "fiveverst_code"
    t.boolean "male"
    t.bigint "user_id"
    t.bigint "club_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parkzhrun_code"
    t.bigint "event_id"
    t.index ["club_id"], name: "index_athletes_on_club_id"
    t.index ["event_id"], name: "index_athletes_on_event_id"
    t.index ["fiveverst_code"], name: "index_athletes_on_fiveverst_code", unique: true
    t.index ["name"], name: "index_athletes_on_name", opclass: :gist_trgm_ops, using: :gist
    t.index ["parkrun_code"], name: "index_athletes_on_parkrun_code", unique: true
    t.index ["parkzhrun_code"], name: "index_athletes_on_parkzhrun_code", unique: true
    t.index ["user_id"], name: "index_athletes_on_user_id", unique: true
  end

  create_table "audits", force: :cascade do |t|
    t.bigint "auditable_id"
    t.string "auditable_type"
    t.bigint "associated_id"
    t.string "associated_type"
    t.bigint "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "badges", force: :cascade do |t|
    t.string "name", null: false
    t.text "conditions"
    t.string "picture_link", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "received_date"
    t.integer "kind", default: 0, null: false
    t.jsonb "info", default: "{}", null: false
    t.index ["info"], name: "index_badges_on_info", using: :gin
  end

  create_table "clubs", force: :cascade do |t|
    t.string "name", null: false
    t.index ["name"], name: "index_clubs_on_name", unique: true
  end

  create_table "contacts", force: :cascade do |t|
    t.string "link", null: false
    t.integer "contact_type", null: false
    t.bigint "event_id", null: false
    t.index ["event_id", "contact_type"], name: "index_contacts_on_event_id_and_contact_type", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code_name", null: false
    t.string "town", null: false
    t.string "place", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "main_picture_link"
    t.integer "visible_order"
    t.string "slogan"
    t.index ["code_name"], name: "index_events_on_code_name", unique: true
  end

  create_table "permissions", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "subject_id"
    t.string "subject_class"
    t.string "action"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "results", force: :cascade do |t|
    t.integer "position"
    t.time "total_time"
    t.bigint "activity_id", null: false
    t.bigint "athlete_id"
    t.boolean "informed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_results_on_activity_id"
    t.index ["athlete_id", "activity_id"], name: "index_results_on_athlete_id_and_activity_id", unique: true
  end

  create_table "trophies", force: :cascade do |t|
    t.bigint "badge_id", null: false
    t.bigint "athlete_id", null: false
    t.date "date"
    t.jsonb "info", default: "{}", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_trophies_on_athlete_id"
    t.index ["badge_id", "athlete_id"], name: "index_trophies_on_badge_id_and_athlete_id", unique: true
    t.index ["info"], name: "index_trophies_on_info", using: :gin
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "role"
    t.string "note"
    t.bigint "telegram_id"
    t.string "telegram_user"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["telegram_id"], name: "index_users_on_telegram_id", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "volunteering_positions", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.integer "rank", null: false
    t.integer "role", null: false
    t.integer "number", null: false
    t.index ["event_id", "role"], name: "index_volunteering_positions_on_event_id_and_role", unique: true
  end

  create_table "volunteers", force: :cascade do |t|
    t.integer "role", null: false
    t.bigint "activity_id", null: false
    t.bigint "athlete_id", null: false
    t.boolean "informed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id", "athlete_id"], name: "index_volunteers_on_activity_id_and_athlete_id", unique: true
    t.index ["athlete_id"], name: "index_volunteers_on_athlete_id"
  end

  add_foreign_key "activities", "events"
  add_foreign_key "athletes", "clubs", on_delete: :nullify
  add_foreign_key "athletes", "events", on_delete: :nullify
  add_foreign_key "athletes", "users", on_delete: :nullify
  add_foreign_key "contacts", "events"
  add_foreign_key "permissions", "users"
  add_foreign_key "results", "activities"
  add_foreign_key "results", "athletes", on_delete: :nullify
  add_foreign_key "trophies", "athletes"
  add_foreign_key "trophies", "badges"
  add_foreign_key "volunteering_positions", "events"
  add_foreign_key "volunteers", "activities"
  add_foreign_key "volunteers", "athletes"
end
