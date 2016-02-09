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

ActiveRecord::Schema.define(version: 20160121070958) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "instrument_id", null: false
  end

  add_index "categories", ["instrument_id"], name: "index_categories_on_instrument_id", using: :btree
  add_index "categories", ["label"], name: "index_categories_on_label", using: :btree

  create_table "cc_conditions", force: :cascade do |t|
    t.string   "literal"
    t.string   "logic"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "instrument_id", null: false
  end

  add_index "cc_conditions", ["instrument_id"], name: "index_cc_conditions_on_instrument_id", using: :btree

  create_table "cc_loops", force: :cascade do |t|
    t.string   "loop_var"
    t.string   "start_val"
    t.string   "end_val"
    t.string   "loop_while"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "instrument_id", null: false
  end

  add_index "cc_loops", ["instrument_id"], name: "index_cc_loops_on_instrument_id", using: :btree

  create_table "cc_questions", force: :cascade do |t|
    t.integer  "question_id",      null: false
    t.string   "question_type",    null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "response_unit_id", null: false
    t.integer  "instrument_id",    null: false
  end

  add_index "cc_questions", ["instrument_id"], name: "index_cc_questions_on_instrument_id", using: :btree
  add_index "cc_questions", ["question_type", "question_id"], name: "index_cc_questions_on_question_type_and_question_id", using: :btree
  add_index "cc_questions", ["response_unit_id"], name: "index_cc_questions_on_response_unit_id", using: :btree

  create_table "cc_sequences", force: :cascade do |t|
    t.string   "literal"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "instrument_id", null: false
  end

  add_index "cc_sequences", ["instrument_id"], name: "index_cc_sequences_on_instrument_id", using: :btree

  create_table "cc_statements", force: :cascade do |t|
    t.string   "literal"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "instrument_id", null: false
  end

  add_index "cc_statements", ["instrument_id"], name: "index_cc_statements_on_instrument_id", using: :btree

  create_table "code_lists", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "instrument_id", null: false
  end

  add_index "code_lists", ["instrument_id"], name: "index_code_lists_on_instrument_id", using: :btree

  create_table "codes", force: :cascade do |t|
    t.string   "value"
    t.integer  "order"
    t.integer  "code_list_id", null: false
    t.integer  "category_id",  null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "codes", ["category_id"], name: "index_codes_on_category_id", using: :btree
  add_index "codes", ["code_list_id"], name: "index_codes_on_code_list_id", using: :btree

  create_table "control_constructs", force: :cascade do |t|
    t.string   "label"
    t.integer  "construct_id",   null: false
    t.string   "construct_type", null: false
    t.integer  "parent_id"
    t.integer  "position"
    t.integer  "branch"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "control_constructs", ["construct_type", "construct_id"], name: "index_control_constructs_on_construct_type_and_construct_id", using: :btree
  add_index "control_constructs", ["parent_id"], name: "index_control_constructs_on_parent_id", using: :btree

  create_table "datasets", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "doi"
    t.string   "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "instructions", force: :cascade do |t|
    t.string   "text"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "instrument_id", null: false
  end

  add_index "instructions", ["instrument_id"], name: "index_instructions_on_instrument_id", using: :btree

  create_table "instruments", force: :cascade do |t|
    t.string   "agency"
    t.string   "version"
    t.string   "prefix"
    t.string   "label"
    t.string   "study"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "instruments_datasets", force: :cascade do |t|
    t.integer  "instrument_id", null: false
    t.integer  "dataset_id",    null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "instruments_datasets", ["dataset_id"], name: "index_instruments_datasets_on_dataset_id", using: :btree
  add_index "instruments_datasets", ["instrument_id"], name: "index_instruments_datasets_on_instrument_id", using: :btree

  create_table "links", force: :cascade do |t|
    t.integer  "target_id",   null: false
    t.string   "target_type", null: false
    t.integer  "topic_id",    null: false
    t.integer  "x"
    t.integer  "y"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "links", ["target_id", "target_type", "topic_id", "x", "y"], name: "unique_linking", unique: true, using: :btree
  add_index "links", ["target_type", "target_id"], name: "index_links_on_target_type_and_target_id", using: :btree
  add_index "links", ["topic_id"], name: "index_links_on_topic_id", using: :btree

  create_table "maps", force: :cascade do |t|
    t.integer  "source_id",   null: false
    t.string   "source_type", null: false
    t.integer  "variable_id", null: false
    t.integer  "x"
    t.integer  "y"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "maps", ["source_id", "source_type", "variable_id", "x", "y"], name: "unique_mapping", unique: true, using: :btree
  add_index "maps", ["source_type", "source_id"], name: "index_maps_on_source_type_and_source_id", using: :btree
  add_index "maps", ["variable_id"], name: "index_maps_on_variable_id", using: :btree

  create_table "question_grids", force: :cascade do |t|
    t.string   "label"
    t.string   "literal"
    t.integer  "instruction_id"
    t.integer  "vertical_code_list_id",               null: false
    t.integer  "horizontal_code_list_id",             null: false
    t.integer  "roster_rows",             default: 0
    t.string   "roster_label"
    t.string   "corner_label"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "instrument_id",                       null: false
  end

  add_index "question_grids", ["horizontal_code_list_id"], name: "index_question_grids_on_horizontal_code_list_id", using: :btree
  add_index "question_grids", ["instruction_id"], name: "index_question_grids_on_instruction_id", using: :btree
  add_index "question_grids", ["instrument_id"], name: "index_question_grids_on_instrument_id", using: :btree
  add_index "question_grids", ["vertical_code_list_id"], name: "index_question_grids_on_vertical_code_list_id", using: :btree

  create_table "question_items", force: :cascade do |t|
    t.string   "label"
    t.string   "literal"
    t.integer  "instruction_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "instrument_id",  null: false
  end

  add_index "question_items", ["instruction_id"], name: "index_question_items_on_instruction_id", using: :btree
  add_index "question_items", ["instrument_id"], name: "index_question_items_on_instrument_id", using: :btree

  create_table "rds_qs", force: :cascade do |t|
    t.integer  "response_domain_id",   null: false
    t.string   "response_domain_type", null: false
    t.integer  "question_id",          null: false
    t.string   "question_type",        null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "code_id"
  end

  add_index "rds_qs", ["code_id"], name: "index_rds_qs_on_code_id", using: :btree
  add_index "rds_qs", ["question_type", "question_id"], name: "index_rds_qs_on_question_type_and_question_id", using: :btree
  add_index "rds_qs", ["response_domain_type", "response_domain_id"], name: "index_rds_qs_on_response_domain_type_and_response_domain_id", using: :btree

  create_table "response_domain_codes", force: :cascade do |t|
    t.integer  "code_list_id", null: false
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
    t.integer  "instrument_id", null: false
  end

  add_index "response_domain_datetimes", ["instrument_id"], name: "index_response_domain_datetimes_on_instrument_id", using: :btree

  create_table "response_domain_numerics", force: :cascade do |t|
    t.string   "numeric_type"
    t.string   "label"
    t.decimal  "min"
    t.decimal  "max"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "instrument_id", null: false
  end

  add_index "response_domain_numerics", ["instrument_id"], name: "index_response_domain_numerics_on_instrument_id", using: :btree

  create_table "response_domain_texts", force: :cascade do |t|
    t.string   "label"
    t.integer  "maxlen"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "instrument_id", null: false
  end

  add_index "response_domain_texts", ["instrument_id"], name: "index_response_domain_texts_on_instrument_id", using: :btree

  create_table "response_units", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "instrument_id", null: false
  end

  add_index "response_units", ["instrument_id"], name: "index_response_units_on_instrument_id", using: :btree

  create_table "topics", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "parent_id"
    t.string   "code",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "topics", ["parent_id"], name: "index_topics_on_parent_id", using: :btree

  create_table "variables", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "label"
    t.string   "var_type",   null: false
    t.integer  "dataset_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "variables", ["dataset_id"], name: "index_variables_on_dataset_id", using: :btree
  add_index "variables", ["name", "dataset_id"], name: "index_variables_on_name_and_dataset_id", unique: true, using: :btree

  add_foreign_key "codes", "categories"
  add_foreign_key "codes", "code_lists"
  add_foreign_key "control_constructs", "control_constructs", column: "parent_id"
  add_foreign_key "instruments_datasets", "datasets"
  add_foreign_key "instruments_datasets", "instruments"
  add_foreign_key "links", "topics"
  add_foreign_key "maps", "variables"
  add_foreign_key "question_grids", "code_lists", column: "horizontal_code_list_id"
  add_foreign_key "question_grids", "code_lists", column: "vertical_code_list_id"
  add_foreign_key "question_grids", "instructions"
  add_foreign_key "question_items", "instructions"
  add_foreign_key "response_domain_codes", "code_lists"
  add_foreign_key "topics", "topics", column: "parent_id"
  add_foreign_key "variables", "datasets"
end
