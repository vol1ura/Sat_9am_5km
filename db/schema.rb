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

ActiveRecord::Schema[8.0].define(version: 2025_12_04_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"

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

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_id", "record_type", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.date "date", null: false
    t.text "description"
    t.boolean "published", default: false, null: false
    t.bigint "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.index ["event_id", "date"], name: "index_activities_on_event_id_and_date"
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
    t.bigint "runpark_code"
    t.jsonb "stats", default: {}, null: false
    t.bigint "going_to_event_id"
    t.jsonb "personal_bests", default: {}, null: false
    t.index ["club_id"], name: "index_athletes_on_club_id"
    t.index ["event_id"], name: "index_athletes_on_event_id"
    t.index ["fiveverst_code"], name: "index_athletes_on_fiveverst_code", unique: true
    t.index ["going_to_event_id"], name: "index_athletes_on_going_to_event_id"
    t.index ["name"], name: "index_athletes_on_name", opclass: :gist_trgm_ops, using: :gist
    t.index ["parkrun_code"], name: "index_athletes_on_parkrun_code", unique: true
    t.index ["parkzhrun_code"], name: "index_athletes_on_parkzhrun_code", unique: true
    t.index ["runpark_code"], name: "index_athletes_on_runpark_code", unique: true
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
    t.index ["auditable_id", "auditable_type", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "badges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "received_date"
    t.integer "kind", default: 0, null: false
    t.jsonb "info", default: {}, null: false
    t.jsonb "conditions_translations"
    t.jsonb "name_translations"
  end

  create_table "clubs", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "country_id", null: false
    t.text "description"
    t.index "lower((name)::text)", name: "index_clubs_on_lower_name", unique: true
    t.index ["country_id"], name: "index_clubs_on_country_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "link", null: false
    t.integer "contact_type", null: false
    t.bigint "event_id", null: false
    t.index ["event_id", "contact_type"], name: "index_contacts_on_event_id_and_contact_type", unique: true
  end

  create_table "countries", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_countries_on_code", unique: true, include: ["id"]
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
    t.integer "visible_order"
    t.string "slogan"
    t.bigint "country_id", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "timezone", default: "Europe/Moscow", null: false
    t.jsonb "live_results"
    t.index ["code_name"], name: "index_events_on_code_name", unique: true
    t.index ["country_id"], name: "index_events_on_country_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.bigint "athlete_id", null: false
    t.bigint "friend_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id", "friend_id"], name: "index_friendships_on_athlete_id_and_friend_id", unique: true
    t.index ["friend_id"], name: "index_friendships_on_friend_id"
  end

  create_table "newsletters", force: :cascade do |t|
    t.text "body", null: false
    t.string "picture_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.bigint "event_id"
    t.string "subject_class"
    t.string "action"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "pghero_query_stats", force: :cascade do |t|
    t.text "database"
    t.text "user"
    t.text "query"
    t.bigint "query_hash"
    t.float "total_time"
    t.bigint "calls"
    t.datetime "captured_at", precision: nil
    t.index ["database", "captured_at"], name: "index_pghero_query_stats_on_database_and_captured_at"
  end

  create_table "results", force: :cascade do |t|
    t.integer "position"
    t.time "total_time"
    t.bigint "activity_id", null: false
    t.bigint "athlete_id"
    t.boolean "informed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "personal_best", default: false, null: false
    t.boolean "first_run", default: false, null: false
    t.index ["activity_id"], name: "index_results_on_activity_id"
    t.index ["athlete_id", "activity_id"], name: "index_results_on_athlete_id_and_activity_id", unique: true
  end

  create_table "trophies", force: :cascade do |t|
    t.bigint "badge_id", null: false
    t.bigint "athlete_id", null: false
    t.date "date"
    t.jsonb "info", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_trophies_on_athlete_id"
    t.index ["badge_id", "athlete_id"], name: "index_trophies_on_badge_id_and_athlete_id", unique: true
    t.index ["info"], name: "index_trophies_on_info", using: :gin
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password"
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
    t.string "phone"
    t.string "auth_token"
    t.datetime "auth_token_expires_at"
    t.string "promotions", default: [], null: false, array: true
    t.string "emergency_contact_name"
    t.string "emergency_contact_phone"
    t.boolean "policy_accepted", default: false, null: false
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["promotions"], name: "index_users_on_promotions", using: :gin
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
    t.string "comment"
    t.index ["activity_id", "athlete_id"], name: "index_volunteers_on_activity_id_and_athlete_id", unique: true
    t.index ["athlete_id"], name: "index_volunteers_on_athlete_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "events"
  add_foreign_key "athletes", "clubs", on_delete: :nullify
  add_foreign_key "athletes", "events", column: "going_to_event_id", on_delete: :nullify
  add_foreign_key "athletes", "events", on_delete: :nullify
  add_foreign_key "athletes", "users", on_delete: :nullify
  add_foreign_key "clubs", "countries", on_delete: :cascade
  add_foreign_key "contacts", "events"
  add_foreign_key "events", "countries", on_delete: :cascade
  add_foreign_key "friendships", "athletes"
  add_foreign_key "friendships", "athletes", column: "friend_id"
  add_foreign_key "permissions", "users"
  add_foreign_key "results", "activities"
  add_foreign_key "results", "athletes", on_delete: :nullify
  add_foreign_key "trophies", "athletes"
  add_foreign_key "trophies", "badges"
  add_foreign_key "volunteering_positions", "events"
  add_foreign_key "volunteers", "activities"
  add_foreign_key "volunteers", "athletes"
end
