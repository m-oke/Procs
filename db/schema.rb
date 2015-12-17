# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151214073219) do

  create_table "answers", force: :cascade do |t|
    t.integer  "student_id",                  limit: 4,                 null: false
    t.integer  "question_id",                 limit: 4,                 null: false
    t.string   "file_name",                   limit: 255,               null: false
    t.string   "result",                      limit: 255,               null: false
    t.string   "language",                    limit: 255,               null: false
    t.float    "run_time",                    limit: 24,  default: 0.0
    t.integer  "memory_usage",                limit: 4,   default: 0
    t.integer  "cpu_usage",                   limit: 4,   default: 0
    t.float    "local_plagiarism_percentage", limit: 24,  default: 0.0
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "lesson_id",                   limit: 4
    t.integer  "question_version",            limit: 4
    t.integer  "test_passed",                 limit: 4,   default: 0,   null: false
    t.integer  "test_count",                  limit: 4,   default: 0,   null: false
    t.integer  "lesson_question_id",          limit: 4,                 null: false
  end

  create_table "internet_check_results", force: :cascade do |t|
    t.integer  "answer_id",  limit: 4,     null: false
    t.string   "title",      limit: 255
    t.string   "link",       limit: 255
    t.text     "content",    limit: 65535
    t.integer  "repeat",     limit: 4
    t.string   "key_word",   limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "lesson_questions", force: :cascade do |t|
    t.integer  "lesson_id",   limit: 4,                 null: false
    t.integer  "question_id", limit: 4,                 null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "is_deleted",  limit: 1, default: false
  end

  create_table "lessons", force: :cascade do |t|
    t.string   "name",        limit: 255,   null: false
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "lesson_code", limit: 255,   null: false
  end

  create_table "local_check_results", force: :cascade do |t|
    t.integer  "answer_id",                  limit: 4,                 null: false
    t.float    "check_result",               limit: 24,  default: 0.0
    t.string   "target_name",                limit: 255
    t.string   "compare_name",               limit: 255
    t.string   "target_line",                limit: 255
    t.string   "compare_line",               limit: 255
    t.string   "compare_path",               limit: 255
    t.integer  "compare_user_id",            limit: 4
    t.integer  "compare_lesson_question_id", limit: 4
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  create_table "question_keywords", force: :cascade do |t|
    t.integer  "question_id", limit: 4,                   null: false
    t.string   "keyword",     limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "is_deleted",  limit: 1,   default: false
  end

  create_table "questions", force: :cascade do |t|
    t.string   "title",              limit: 255,                   null: false
    t.text     "content",            limit: 65535
    t.text     "input_description",  limit: 65535
    t.text     "output_description", limit: 65535
    t.integer  "run_time_limit",     limit: 4,     default: 60000
    t.integer  "memory_usage_limit", limit: 4,     default: 512
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "version",            limit: 4,     default: 1
    t.integer  "author",             limit: 4,                     null: false
    t.boolean  "is_public",          limit: 1,                     null: false
    t.boolean  "is_deleted",         limit: 1,     default: false, null: false
  end

  create_table "samples", force: :cascade do |t|
    t.integer  "question_id", limit: 4,                     null: false
    t.text     "input",       limit: 65535,                 null: false
    t.text     "output",      limit: 65535,                 null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "is_deleted",  limit: 1,     default: false, null: false
  end

  create_table "test_data", force: :cascade do |t|
    t.integer  "question_id",      limit: 4
    t.string   "input",            limit: 1024,                 null: false
    t.string   "output",           limit: 1024,                 null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "input_storename",  limit: 255
    t.string   "output_storename", limit: 255
    t.boolean  "is_deleted",       limit: 1,    default: false, null: false
  end

  create_table "user_lessons", force: :cascade do |t|
    t.integer  "user_id",    limit: 4,                 null: false
    t.integer  "lesson_id",  limit: 4,                 null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "is_teacher", limit: 1, default: false, null: false
    t.boolean  "is_deleted", limit: 1, default: false, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "student_number",         limit: 255
    t.string   "name",                   limit: 255
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "nickname",               limit: 255,              null: false
    t.integer  "roles_mask",             limit: 4,   default: 8
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
