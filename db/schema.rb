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

ActiveRecord::Schema[8.0].define(version: 2025_04_09_075145) do
  create_table "collections", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "flashcards", force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "front_content", null: false
    t.text "back_content", null: false
    t.string "flashcard_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_flashcards_on_user_id"
    t.check_constraint "flashcard_type IN ('manual','ai','edited_ai')", name: "flashcard_type_constraint"
  end

  create_table "flashcards_collections", force: :cascade do |t|
    t.integer "flashcard_id", null: false
    t.integer "collection_id", null: false
    t.index ["collection_id", "flashcard_id"], name: "index_flashcards_collections_on_collection_id_and_flashcard_id"
    t.index ["collection_id"], name: "index_flashcards_collections_on_collection_id"
    t.index ["flashcard_id", "collection_id"], name: "index_flashcards_collections_on_flashcard_id_and_collection_id", unique: true
    t.index ["flashcard_id"], name: "index_flashcards_collections_on_flashcard_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "stats", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "manual_flashcards_count", default: 0, null: false
    t.integer "ai_flashcards_count", default: 0, null: false
    t.integer "edited_ai_flashcards_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_stats_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "collections", "users", on_delete: :cascade
  add_foreign_key "flashcards", "users", on_delete: :cascade
  add_foreign_key "flashcards_collections", "collections", on_delete: :cascade
  add_foreign_key "flashcards_collections", "flashcards", on_delete: :cascade
  add_foreign_key "sessions", "users"
  add_foreign_key "stats", "users", on_delete: :cascade
end
