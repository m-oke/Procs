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

ActiveRecord::Schema.define(version: 20150522035113) do

  create_table "answers", force: :cascade do |t|
    t.string   "student_id_number",     limit: 255
    t.integer  "question_id",           limit: 4
    t.string   "file_name",             limit: 255
    t.integer  "result",                limit: 4
    t.decimal  "run_time",                          precision: 10
    t.integer  "memory_usage",          limit: 4
    t.float    "plagiarism_percentage", limit: 24
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  create_table "lessons", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "questions", force: :cascade do |t|
    t.string   "title",              limit: 255
    t.integer  "class_id",           limit: 4
    t.string   "content",            limit: 255
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "input_description",  limit: 255
    t.string   "output_description", limit: 255
    t.integer  "run_time_limit",     limit: 4
    t.integer  "memory_usage_limit", limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "samples", force: :cascade do |t|
    t.integer  "question_id", limit: 4
    t.string   "input",       limit: 255
    t.string   "output",      limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "test_data", force: :cascade do |t|
    t.integer  "question_id", limit: 4
    t.string   "input",       limit: 255
    t.string   "output",      limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "user_lessons", force: :cascade do |t|
    t.string   "id_number",  limit: 255
    t.integer  "class_id",   limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", primary_key: "id_number", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "mail",       limit: 255
    t.string   "faculty",    limit: 255
    t.string   "department", limit: 255
    t.integer  "grade",      limit: 4
    t.integer  "role",       limit: 4
    t.boolean  "admin",      limit: 1
    t.string   "password",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
