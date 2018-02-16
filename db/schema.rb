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

ActiveRecord::Schema.define(version: 20171212182936) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "instrument_id", null: false
    t.index ["id", "instrument_id"], name: "encapsulate_unique_for_categories", unique: true, using: :btree
    t.index ["instrument_id"], name: "index_categories_on_instrument_id", using: :btree
    t.index ["label", "instrument_id"], name: "index_categories_on_label_and_instrument_id", unique: true, using: :btree
    t.index ["label"], name: "index_categories_on_label", using: :btree
  end

  create_table "code_lists", force: :cascade do |t|
    t.string   "label",         null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "instrument_id", null: false
    t.index ["id", "instrument_id"], name: "encapsulate_unique_for_code_lists", unique: true, using: :btree
    t.index ["instrument_id"], name: "index_code_lists_on_instrument_id", using: :btree
    t.index ["label", "instrument_id"], name: "index_code_lists_on_label_and_instrument_id", unique: true, using: :btree
  end

  create_table "codes", force: :cascade do |t|
    t.string   "value"
    t.integer  "order"
    t.integer  "code_list_id",  null: false
    t.integer  "category_id",   null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "instrument_id", null: false
    t.index ["category_id"], name: "index_codes_on_category_id", using: :btree
    t.index ["code_list_id"], name: "index_codes_on_code_list_id", using: :btree
    t.index ["instrument_id"], name: "index_codes_on_instrument_id", using: :btree
  end

  create_table "conditions", force: :cascade do |t|
    t.string   "literal"
    t.string   "logic"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "instrument_id",                          null: false
    t.string   "construct_type", default: "CcCondition"
    t.index ["instrument_id"], name: "index_cc_conditions_on_instrument_id", using: :btree
  end

  create_table "control_constructs", force: :cascade do |t|
    t.string   "label"
    t.string   "construct_type", null: false
    t.integer  "construct_id",   null: false
    t.integer  "parent_id"
    t.integer  "position"
    t.integer  "branch"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "instrument_id",  null: false
    t.index ["construct_id", "construct_type", "instrument_id"], name: "encapsulate_unique_for_control_constructs", unique: true, using: :btree
    t.index ["construct_type", "construct_id"], name: "index_control_constructs_on_construct_type_and_construct_id", using: :btree
    t.index ["id", "instrument_id"], name: "encapsulate_unique_for_control_constructs_internally", unique: true, using: :btree
    t.index ["instrument_id"], name: "index_control_constructs_on_instrument_id", using: :btree
    t.index ["label", "instrument_id"], name: "index_control_constructs_on_label_and_instrument_id", unique: true, using: :btree
    t.index ["parent_id"], name: "index_control_constructs_on_parent_id", using: :btree
  end

  create_table "datasets", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "doi"
    t.string   "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "study"
  end

  create_table "documents", force: :cascade do |t|
    t.string   "filename"
    t.string   "content_type"
    t.binary   "file_contents"
    t.string   "md5_hash",      limit: 32
    t.string   "item_type"
    t.integer  "item_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["item_type", "item_id"], name: "index_documents_on_item_type_and_item_id", using: :btree
    t.index ["md5_hash"], name: "index_documents_on_md5_hash", unique: true, using: :btree
  end

  create_table "identifiers", force: :cascade do |t|
    t.string   "id_type"
    t.string   "value"
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id_type", "value"], name: "index_identifiers_on_id_type_and_value", unique: true, using: :btree
    t.index ["item_type", "item_id"], name: "index_identifiers_on_item_type_and_item_id", using: :btree
  end

  create_table "instructions", force: :cascade do |t|
    t.string   "text"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "instrument_id", null: false
    t.index ["id", "instrument_id"], name: "encapsulate_unique_for_instructions", unique: true, using: :btree
    t.index ["instrument_id"], name: "index_instructions_on_instrument_id", using: :btree
    t.index ["text", "instrument_id"], name: "index_instructions_on_text_and_instrument_id", unique: true, using: :btree
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

  create_table "instruments_datasets", force: :cascade do |t|
    t.integer  "instrument_id", null: false
    t.integer  "dataset_id",    null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["dataset_id"], name: "index_instruments_datasets_on_dataset_id", using: :btree
    t.index ["instrument_id"], name: "index_instruments_datasets_on_instrument_id", using: :btree
  end

  create_table "item_groups", force: :cascade do |t|
    t.integer  "group_type"
    t.string   "item_type"
    t.string   "label"
    t.string   "root_item_type"
    t.integer  "root_item_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["root_item_type", "root_item_id"], name: "index_item_groups_on_root_item_type_and_root_item_id", using: :btree
  end

  create_table "links", force: :cascade do |t|
    t.string   "target_type", null: false
    t.integer  "target_id",   null: false
    t.integer  "topic_id",    null: false
    t.integer  "x"
    t.integer  "y"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["target_id", "target_type", "topic_id", "x", "y"], name: "unique_linking", unique: true, using: :btree
    t.index ["target_type", "target_id"], name: "index_links_on_target_type_and_target_id", using: :btree
    t.index ["topic_id"], name: "index_links_on_topic_id", using: :btree
  end

  create_table "loops", force: :cascade do |t|
    t.string   "loop_var"
    t.string   "start_val"
    t.string   "end_val"
    t.string   "loop_while"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "instrument_id",                     null: false
    t.string   "construct_type", default: "CcLoop"
    t.index ["instrument_id"], name: "index_cc_loops_on_instrument_id", using: :btree
  end

  create_table "maps", force: :cascade do |t|
    t.string   "source_type", null: false
    t.integer  "source_id",   null: false
    t.integer  "variable_id", null: false
    t.integer  "x"
    t.integer  "y"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["source_id", "source_type", "variable_id", "x", "y"], name: "unique_mapping", unique: true, using: :btree
    t.index ["source_id", "variable_id", "x", "y"], name: "index_maps_on_source_id_and_variable_id_and_x_and_y", unique: true, where: "((source_type)::text = 'Question'::text)", using: :btree
    t.index ["source_id", "variable_id"], name: "index_maps_on_source_id_and_variable_id", unique: true, where: "((source_type)::text = 'Variable'::text)", using: :btree
    t.index ["source_type", "source_id"], name: "index_maps_on_source_type_and_source_id", using: :btree
    t.index ["variable_id"], name: "index_maps_on_variable_id", using: :btree
  end

  create_table "question_grids", force: :cascade do |t|
    t.string   "label",                                            null: false
    t.string   "literal"
    t.integer  "instruction_id"
    t.integer  "vertical_code_list_id"
    t.integer  "horizontal_code_list_id",                          null: false
    t.integer  "roster_rows",             default: 0
    t.string   "roster_label"
    t.string   "corner_label"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "instrument_id",                                    null: false
    t.string   "question_type",           default: "QuestionGrid"
    t.index ["horizontal_code_list_id"], name: "index_question_grids_on_horizontal_code_list_id", using: :btree
    t.index ["instruction_id"], name: "index_question_grids_on_instruction_id", using: :btree
    t.index ["instrument_id"], name: "index_question_grids_on_instrument_id", using: :btree
    t.index ["label", "instrument_id"], name: "index_question_grids_on_label_and_instrument_id", unique: true, using: :btree
    t.index ["vertical_code_list_id"], name: "index_question_grids_on_vertical_code_list_id", using: :btree
  end

  create_table "question_items", force: :cascade do |t|
    t.string   "label",                                   null: false
    t.string   "literal"
    t.integer  "instruction_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "instrument_id",                           null: false
    t.string   "question_type",  default: "QuestionItem"
    t.index ["instruction_id"], name: "index_question_items_on_instruction_id", using: :btree
    t.index ["instrument_id"], name: "index_question_items_on_instrument_id", using: :btree
    t.index ["label", "instrument_id"], name: "index_question_items_on_label_and_instrument_id", unique: true, using: :btree
  end

  create_table "questions", force: :cascade do |t|
    t.string   "question_type",                           null: false
    t.integer  "question_id",                             null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "response_unit_id",                        null: false
    t.integer  "instrument_id",                           null: false
    t.string   "construct_type",   default: "CcQuestion"
    t.index ["instrument_id"], name: "index_cc_questions_on_instrument_id", using: :btree
    t.index ["question_type", "question_id"], name: "index_cc_questions_on_question_type_and_question_id", using: :btree
    t.index ["response_unit_id"], name: "index_cc_questions_on_response_unit_id", using: :btree
  end

  create_table "rds_qs", force: :cascade do |t|
    t.string   "response_domain_type", null: false
    t.integer  "response_domain_id",   null: false
    t.string   "question_type",        null: false
    t.integer  "question_id",          null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "code_id"
    t.integer  "instrument_id",        null: false
    t.integer  "rd_order"
    t.index ["code_id"], name: "index_rds_qs_on_code_id", using: :btree
    t.index ["instrument_id"], name: "index_rds_qs_on_instrument_id", using: :btree
    t.index ["question_id", "question_type", "rd_order"], name: "unique_for_rd_order_within_question", unique: true, using: :btree
    t.index ["question_type", "question_id"], name: "index_rds_qs_on_question_type_and_question_id", using: :btree
    t.index ["response_domain_type", "response_domain_id"], name: "index_rds_qs_on_response_domain_type_and_response_domain_id", using: :btree
  end

  create_table "response_domain_codes", force: :cascade do |t|
    t.integer  "code_list_id",                                        null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "response_domain_type", default: "ResponseDomainCode"
    t.integer  "instrument_id",                                       null: false
    t.integer  "min_responses",        default: 1,                    null: false
    t.integer  "max_responses",        default: 1,                    null: false
    t.index ["code_list_id"], name: "index_response_domain_codes_on_code_list_id", using: :btree
    t.index ["instrument_id"], name: "index_response_domain_codes_on_instrument_id", using: :btree
  end

  create_table "response_domain_datetimes", force: :cascade do |t|
    t.string   "datetime_type"
    t.string   "label"
    t.string   "format"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "instrument_id",                                           null: false
    t.string   "response_domain_type", default: "ResponseDomainDatetime"
    t.index ["instrument_id"], name: "index_response_domain_datetimes_on_instrument_id", using: :btree
  end

  create_table "response_domain_numerics", force: :cascade do |t|
    t.string   "numeric_type"
    t.string   "label"
    t.decimal  "min"
    t.decimal  "max"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "instrument_id",                                          null: false
    t.string   "response_domain_type", default: "ResponseDomainNumeric"
    t.index ["instrument_id"], name: "index_response_domain_numerics_on_instrument_id", using: :btree
  end

  create_table "response_domain_texts", force: :cascade do |t|
    t.string   "label"
    t.integer  "maxlen"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "instrument_id",                                       null: false
    t.string   "response_domain_type", default: "ResponseDomainText"
    t.index ["instrument_id"], name: "index_response_domain_texts_on_instrument_id", using: :btree
  end

  create_table "response_units", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "instrument_id", null: false
    t.index ["id", "instrument_id"], name: "encapsulate_unique_for_response_units", unique: true, using: :btree
    t.index ["instrument_id"], name: "index_response_units_on_instrument_id", using: :btree
  end

  create_table "sequences", force: :cascade do |t|
    t.string   "literal"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "instrument_id",                         null: false
    t.string   "construct_type", default: "CcSequence"
    t.index ["instrument_id"], name: "index_cc_sequences_on_instrument_id", using: :btree
  end

  create_table "statements", force: :cascade do |t|
    t.string   "literal"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "instrument_id",                          null: false
    t.string   "construct_type", default: "CcStatement"
    t.index ["instrument_id"], name: "index_cc_statements_on_instrument_id", using: :btree
  end

  create_table "streamlined_groupings", force: :cascade do |t|
    t.integer  "item_group_id", null: false
    t.integer  "item_id",       null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["item_group_id"], name: "index_streamlined_groupings_on_item_group_id", using: :btree
  end

  create_table "topics", force: :cascade do |t|
    t.string   "name",        null: false
    t.integer  "parent_id"
    t.string   "code",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "description"
    t.index ["parent_id"], name: "index_topics_on_parent_id", using: :btree
  end

  create_table "user_groups", force: :cascade do |t|
    t.string   "group_type"
    t.string   "label"
    t.string   "study"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "first_name",             default: "", null: false
    t.string   "last_name",              default: "", null: false
    t.integer  "group_id",                            null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "role",                   default: 0,  null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts"
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "api_key"
    t.index ["api_key"], name: "index_users_on_api_key", unique: true, using: :btree
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["group_id"], name: "index_users_on_group_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end

  create_table "variables", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "label"
    t.string   "var_type",   null: false
    t.integer  "dataset_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dataset_id"], name: "index_variables_on_dataset_id", using: :btree
    t.index ["name", "dataset_id"], name: "index_variables_on_name_and_dataset_id", unique: true, using: :btree
  end

  add_foreign_key "codes", "categories"
  add_foreign_key "codes", "categories", name: "encapsulate_codes_and_categories"
  add_foreign_key "codes", "code_lists"
  add_foreign_key "codes", "code_lists", name: "encapsulate_codes_and_codes_lists"
  add_foreign_key "codes", "instruments"
  add_foreign_key "conditions", "control_constructs", column: "id", primary_key: "construct_id", name: "encapsulate_cc_conditions_and_control_constructs", on_delete: :cascade
  add_foreign_key "control_constructs", "control_constructs", column: "parent_id"
  add_foreign_key "control_constructs", "control_constructs", column: "parent_id", name: "encapsulate_control_constructs_to_its_self"
  add_foreign_key "control_constructs", "instruments"
  add_foreign_key "instruments_datasets", "datasets"
  add_foreign_key "instruments_datasets", "instruments"
  add_foreign_key "links", "topics"
  add_foreign_key "loops", "control_constructs", column: "id", primary_key: "construct_id", name: "encapsulate_cc_loops_and_control_constructs", on_delete: :cascade
  add_foreign_key "maps", "variables"
  add_foreign_key "question_grids", "code_lists", column: "horizontal_code_list_id", name: "encapsulate_question_grids_and_horizontal_code_lists"
  add_foreign_key "question_grids", "code_lists", column: "vertical_code_list_id", name: "encapsulate_question_grids_and_vertical_code_lists"
  add_foreign_key "question_grids", "instructions", name: "encapsulate_question_grids_and_instructions"
  add_foreign_key "question_items", "instructions", name: "encapsulate_question_items_and_instructions"
  add_foreign_key "questions", "control_constructs", column: "id", primary_key: "construct_id", name: "encapsulate_cc_questions_and_control_constructs", on_delete: :cascade
  add_foreign_key "questions", "response_units", name: "encapsulate_cc_questions_and_response_units"
  add_foreign_key "rds_qs", "instruments"
  add_foreign_key "response_domain_codes", "code_lists"
  add_foreign_key "response_domain_codes", "instruments"
  add_foreign_key "sequences", "control_constructs", column: "id", primary_key: "construct_id", name: "encapsulate_cc_sequences_and_control_constructs", on_delete: :cascade
  add_foreign_key "statements", "control_constructs", column: "id", primary_key: "construct_id", name: "encapsulate_cc_statements_and_control_constructs", on_delete: :cascade
  add_foreign_key "streamlined_groupings", "item_groups"
  add_foreign_key "topics", "topics", column: "parent_id"
  add_foreign_key "users", "user_groups", column: "group_id"
  add_foreign_key "variables", "datasets"
end
