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

ActiveRecord::Schema[8.0].define(version: 2025_06_13_180633) do
  create_table "audio_files", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "vocabulary_id"
    t.bigint "phrase_id"
    t.bigint "example_id"
    t.bigint "example_token_id"
    t.string "audio_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.column "audio_type", "enum('vocab','phrase','example','example_token')", null: false
    t.index ["example_id"], name: "index_audio_files_on_example_id"
    t.index ["example_token_id"], name: "index_audio_files_on_example_token_id"
    t.index ["phrase_id"], name: "index_audio_files_on_phrase_id"
    t.index ["vocabulary_id"], name: "index_audio_files_on_vocabulary_id"
    t.check_constraint "((((`vocabulary_id` is not null) + (`phrase_id` is not null)) + (`example_id` is not null)) + (`example_token_id` is not null)) = 1", name: "check_audio_source"
  end

  create_table "chapters", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", null: false
    t.column "level", "enum('N3','N2','N1')", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "choices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.text "choice", null: false
    t.boolean "is_correct", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_choices_on_question_id"
  end

  create_table "example_tokens", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "example_id", null: false
    t.integer "token_index", null: false
    t.string "jp_token", null: false
    t.string "vn_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["example_id"], name: "index_example_tokens_on_example_id"
  end

  create_table "examples", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "vocabulary_id", null: false
    t.text "example_sentence", null: false
    t.text "meaning_sentence", null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vocabulary_id"], name: "index_examples_on_vocabulary_id"
  end

  create_table "jwt_denylist", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti"
  end

  create_table "lessons", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", null: false
    t.bigint "chapter_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_id"], name: "index_lessons_on_chapter_id"
  end

  create_table "meanings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "vocabulary_id", null: false
    t.text "meaning", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vocabulary_id"], name: "index_meanings_on_vocabulary_id"
  end

  create_table "phrases", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "vocabulary_id", null: false
    t.string "phrase", null: false
    t.string "main_word", null: false
    t.string "prefix"
    t.string "suffix"
    t.text "meaning", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "furigana"
    t.string "phrase_type"
    t.index ["vocabulary_id"], name: "index_phrases_on_vocabulary_id"
  end

  create_table "questions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "lesson_id", null: false
    t.bigint "vocabulary_id"
    t.bigint "phrase_id"
    t.bigint "example_id"
    t.text "question", null: false
    t.column "question_type", "enum('choice','fill_blank','sorting','matching')", null: false
    t.json "correct_answers"
    t.text "hidden_part"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["example_id"], name: "index_questions_on_example_id"
    t.index ["lesson_id"], name: "index_questions_on_lesson_id"
    t.index ["phrase_id"], name: "index_questions_on_phrase_id"
    t.index ["vocabulary_id"], name: "index_questions_on_vocabulary_id"
    t.check_constraint "(((`vocabulary_id` is not null) + (`phrase_id` is not null)) + (`example_id` is not null)) = 1", name: "check_question_source"
    t.check_constraint "(`question_type` = _utf8mb4'choice') or (`correct_answers` is not null)", name: "check_correct_answers"
  end

  create_table "test_answers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "test_attempt_id", null: false
    t.bigint "question_id", null: false
    t.text "answer_text"
    t.boolean "is_correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_test_answers_on_question_id"
    t.index ["test_attempt_id"], name: "index_test_answers_on_test_attempt_id"
  end

  create_table "test_attempts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "test_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time"
    t.integer "score"
    t.column "status", "enum('in_progress','completed','abandoned')", default: "in_progress", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "answered_count", default: 0, null: false
    t.boolean "auto_submitted", default: false
    t.index ["test_id"], name: "index_test_attempts_on_test_id"
    t.index ["user_id"], name: "index_test_attempts_on_user_id"
  end

  create_table "test_questions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "test_attempt_id", null: false
    t.bigint "question_id", null: false
    t.integer "score", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_test_questions_on_question_id"
    t.index ["test_attempt_id"], name: "index_test_questions_on_test_attempt_id"
  end

  create_table "tests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "lesson_id", null: false
    t.string "title", null: false
    t.integer "total_score", default: 100, null: false
    t.integer "pass_score", default: 75, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duration_minutes", default: 30, null: false
    t.index ["lesson_id"], name: "index_tests_on_lesson_id"
  end

  create_table "user_daily_activities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "activity_date", null: false
    t.column "level", "enum('N3','N2','N1')", null: false
    t.boolean "is_studied", default: false, null: false
    t.integer "point_earned", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "activity_date", "level"], name: "idx_on_user_id_activity_date_level_7d348e5895", unique: true
    t.index ["user_id"], name: "index_user_daily_activities_on_user_id"
  end

  create_table "user_exercise_statuses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "lesson_id", null: false
    t.string "exercise_type"
    t.boolean "done", default: false
    t.datetime "done_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_user_exercise_statuses_on_lesson_id"
    t.index ["user_id", "lesson_id", "exercise_type"], name: "index_user_lesson_exercise_unique", unique: true
    t.index ["user_id"], name: "index_user_exercise_statuses_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.date "dob", null: false
    t.string "phone"
    t.bigint "point", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vocabularies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "lesson_id", null: false
    t.string "kanji"
    t.string "hanviet"
    t.string "kana"
    t.string "word_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_vocabularies_on_lesson_id"
  end

  add_foreign_key "audio_files", "example_tokens"
  add_foreign_key "audio_files", "examples"
  add_foreign_key "audio_files", "phrases"
  add_foreign_key "audio_files", "vocabularies"
  add_foreign_key "choices", "questions"
  add_foreign_key "example_tokens", "examples"
  add_foreign_key "examples", "vocabularies"
  add_foreign_key "lessons", "chapters"
  add_foreign_key "meanings", "vocabularies"
  add_foreign_key "phrases", "vocabularies"
  add_foreign_key "questions", "examples"
  add_foreign_key "questions", "lessons"
  add_foreign_key "questions", "phrases"
  add_foreign_key "questions", "vocabularies"
  add_foreign_key "test_answers", "questions"
  add_foreign_key "test_answers", "test_attempts"
  add_foreign_key "test_attempts", "tests"
  add_foreign_key "test_attempts", "users"
  add_foreign_key "test_questions", "questions"
  add_foreign_key "test_questions", "test_attempts"
  add_foreign_key "tests", "lessons"
  add_foreign_key "user_daily_activities", "users"
  add_foreign_key "user_exercise_statuses", "lessons"
  add_foreign_key "user_exercise_statuses", "users"
  add_foreign_key "vocabularies", "lessons"
end
