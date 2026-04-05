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

ActiveRecord::Schema[8.1].define(version: 2026_04_04_232028) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "follows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "followed_id", null: false
    t.bigint "follower_id", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_follows_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "meal_comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "meal_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["meal_id", "created_at"], name: "index_meal_comments_on_meal_id_and_created_at"
    t.index ["meal_id"], name: "index_meal_comments_on_meal_id"
    t.index ["user_id"], name: "index_meal_comments_on_user_id"
  end

  create_table "meal_likes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "meal_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["meal_id"], name: "index_meal_likes_on_meal_id"
    t.index ["user_id", "meal_id"], name: "index_meal_likes_on_user_id_and_meal_id", unique: true
    t.index ["user_id"], name: "index_meal_likes_on_user_id"
  end

  create_table "meals", force: :cascade do |t|
    t.date "ate_on", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "notes"
    t.integer "occasion"
    t.decimal "rating", precision: 2, scale: 1, null: false
    t.integer "retry_in_days"
    t.integer "source", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "ate_on"], name: "index_meals_on_user_id_and_ate_on"
    t.index ["user_id", "name"], name: "index_meals_on_user_id_and_name"
    t.index ["user_id", "occasion", "ate_on"], name: "index_meals_on_user_id_and_occasion_and_ate_on"
    t.index ["user_id"], name: "index_meals_on_user_id"
  end

  create_table "recommendation_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_name", null: false
    t.string "meal_name", null: false
    t.jsonb "metadata", default: {}, null: false
    t.integer "occasion"
    t.string "source_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_name"], name: "index_recommendation_events_on_event_name"
    t.index ["occasion"], name: "index_recommendation_events_on_occasion"
    t.index ["source_type"], name: "index_recommendation_events_on_source_type"
    t.index ["user_id"], name: "index_recommendation_events_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "image_url"
    t.string "name"
    t.string "password_digest"
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "follows", "users", column: "followed_id"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "meal_comments", "meals"
  add_foreign_key "meal_comments", "users"
  add_foreign_key "meal_likes", "meals"
  add_foreign_key "meal_likes", "users"
  add_foreign_key "meals", "users"
  add_foreign_key "recommendation_events", "users"
end
