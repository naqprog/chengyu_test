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

ActiveRecord::Schema[7.0].define(version: 2023_12_20_133804) do
  create_table "bookmarks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "question_id", null: false
    t.boolean "favorite", default: false, null: false
    t.boolean "known", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_bookmarks_on_question_id"
    t.index ["user_id", "question_id"], name: "index_bookmarks_on_user_id_and_question_id", unique: true
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "questions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "chengyu_jianti", null: false
    t.string "chengyu_fanti", null: false
    t.string "pinyin", null: false
    t.text "mean", null: false
    t.text "note"
    t.string "other_answer_jianti"
    t.string "other_answer_fanti"
    t.string "other_answer_pinyin"
    t.integer "source", default: 0, null: false
    t.integer "level", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chengyu_fanti"], name: "index_questions_on_chengyu_fanti", unique: true
    t.index ["chengyu_jianti"], name: "index_questions_on_chengyu_jianti", unique: true
  end

  create_table "responses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "question_id", null: false
    t.integer "test_format", default: 0, null: false
    t.integer "test_kind", default: 0, null: false
    t.boolean "correct", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_responses_on_question_id"
    t.index ["user_id"], name: "index_responses_on_user_id"
  end

  create_table "settings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "letter_kind", default: 0, null: false
    t.integer "test_format", default: 0, null: false
    t.integer "test_kind", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_settings_on_user_id", unique: true
  end

  create_table "synonyms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "question_another_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_another_id"], name: "index_synonyms_on_question_another_id"
    t.index ["question_id", "question_another_id"], name: "index_synonyms_on_question_id_and_question_another_id", unique: true
    t.index ["question_id"], name: "index_synonyms_on_question_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bookmarks", "questions"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "responses", "questions"
  add_foreign_key "responses", "users"
  add_foreign_key "settings", "users"
  add_foreign_key "synonyms", "questions"
  add_foreign_key "synonyms", "questions", column: "question_another_id"
end
