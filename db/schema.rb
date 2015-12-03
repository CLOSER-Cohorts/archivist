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

ActiveRecord::Schema.define(version: 20151203122424) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cc_conditions", force: :cascade do |t|
    t.string   "literal"
    t.string   "logic"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cc_loops", force: :cascade do |t|
    t.string   "loop_var"
    t.string   "start_val"
    t.string   "end_val"
    t.string   "loop_while"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cc_questions", force: :cascade do |t|
    t.integer  "question_id"
    t.string   "question_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "cc_questions", ["question_type", "question_id"], name: "index_cc_questions_on_question_type_and_question_id", using: :btree

  create_table "cc_sequences", force: :cascade do |t|
    t.string   "literal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cc_statements", force: :cascade do |t|
    t.string   "literal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "code_lists", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "codes", force: :cascade do |t|
    t.string   "value"
    t.integer  "order"
    t.integer  "code_list_id"
    t.integer  "category_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "codes", ["category_id"], name: "index_codes_on_category_id", using: :btree
  add_index "codes", ["code_list_id"], name: "index_codes_on_code_list_id", using: :btree

  create_table "control_constructs", force: :cascade do |t|
    t.string   "label"
    t.integer  "construct_id"
    t.string   "construct_type"
    t.integer  "parent_id"
    t.integer  "position"
    t.integer  "branch"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "control_constructs", ["construct_type", "construct_id"], name: "index_control_constructs_on_construct_type_and_construct_id", using: :btree
  add_index "control_constructs", ["parent_id"], name: "index_control_constructs_on_parent_id", using: :btree

  create_table "instructions", force: :cascade do |t|
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "instruments", force: :cascade do |t|
    t.string   "agency"
    t.string   "version"
    t.string   "prefix"
    t.string   "label"
    t.string   "study"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "question_grids", force: :cascade do |t|
    t.string   "label"
    t.string   "literal"
    t.integer  "instruction_id"
    t.integer  "vertical_code_list_id"
    t.integer  "horizontal_code_list_id"
    t.integer  "roster_rows",             default: 0
    t.string   "roster_label"
    t.string   "corner_label"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "question_grids", ["horizontal_code_list_id"], name: "index_question_grids_on_horizontal_code_list_id", using: :btree
  add_index "question_grids", ["instruction_id"], name: "index_question_grids_on_instruction_id", using: :btree
  add_index "question_grids", ["vertical_code_list_id"], name: "index_question_grids_on_vertical_code_list_id", using: :btree

  create_table "question_items", force: :cascade do |t|
    t.string   "label"
    t.string   "literal"
    t.integer  "instruction_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "question_items", ["instruction_id"], name: "index_question_items_on_instruction_id", using: :btree

  create_table "rds_qs", force: :cascade do |t|
    t.integer  "response_domain_id"
    t.string   "response_domain_type"
    t.integer  "question_id"
    t.string   "question_type"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "rds_qs", ["question_type", "question_id"], name: "index_rds_qs_on_question_type_and_question_id", using: :btree
  add_index "rds_qs", ["response_domain_type", "response_domain_id"], name: "index_rds_qs_on_response_domain_type_and_response_domain_id", using: :btree

  create_table "response_domain_codes", force: :cascade do |t|
    t.integer  "code_list_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "response_domain_codes", ["code_list_id"], name: "index_response_domain_codes_on_code_list_id", using: :btree

  create_table "response_domain_datetimes", force: :cascade do |t|
    t.string   "datetime_type"
    t.string   "label"
    t.string   "format"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "response_domain_numerics", force: :cascade do |t|
    t.string   "numeric_type"
    t.string   "label"
    t.decimal  "min"
    t.decimal  "max"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "response_domain_texts", force: :cascade do |t|
    t.string   "label"
    t.integer  "maxlen"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "response_units", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "codes", "categories"
  add_foreign_key "codes", "code_lists"
  add_foreign_key "control_constructs", "control_constructs", column: "parent_id"
  add_foreign_key "question_grids", "code_lists", column: "horizontal_code_list_id"
  add_foreign_key "question_grids", "code_lists", column: "vertical_code_list_id"
  add_foreign_key "question_grids", "instructions"
  add_foreign_key "question_items", "instructions"
  add_foreign_key "response_domain_codes", "code_lists"
end
