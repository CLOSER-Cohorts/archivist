class AddInstrumentEncapsulation < ActiveRecord::Migration
  def change

    reversible do |dir|
      dir.up do

        add_column :cc_conditions,  :construct_type, :string, null: :false, default: 'CcCondition'
        add_column :cc_loops,       :construct_type, :string, null: :false, default: 'CcLoop'
        add_column :cc_questions,   :construct_type, :string, null: :false, default: 'CcQuestion'
        add_column :cc_sequences,   :construct_type, :string, null: :false, default: 'CcSequence'
        add_column :cc_statements,  :construct_type, :string, null: :false, default: 'CcStatement'

        add_column :response_domain_codes,      :response_domain_type, :string, null: :false, default: 'ResponseDomainCode'
        add_column :response_domain_datetimes,  :response_domain_type, :string, null: :false, default: 'ResponseDomainDatetime'
        add_column :response_domain_numerics,   :response_domain_type, :string, null: :false, default: 'ResponseDomainNumeric'
        add_column :response_domain_texts,      :response_domain_type, :string, null: :false, default: 'ResponseDomainText'

        add_column :question_grids,  :question_type, :string, null: :false, default: 'QuestionGrid'
        add_column :question_items,  :question_type, :string, null: :false, default: 'QuestionItem'

        add_reference :codes, :instrument, index: true, foreign_key: true, null: true
        add_reference :control_constructs, :instrument, index: true, foreign_key: true, null: true
        add_reference :rds_qs, :instrument, index: true, foreign_key: true, null: true
        add_reference :response_domain_codes, :instrument, index: true, foreign_key: true, null: true

        Code.includes(:category).find_each do |c|
          c.instrument_id = c.category.instrument_id
          c.save!
        end

        ControlConstruct.find_each do |cc|
          cc.instrument_id = cc.construct.instrument_id
          cc.save!
        end

        RdsQs.find_each do |rq|
          rq.instrument_id = rq.question.instrument_id
          rq.save!
        end

        ResponseDomainCode.includes(:code_list).find_each do |rdc|
          rdc.instrument_id = rdc.code_list.instrument_id
          rdc.save!
        end

        change_column :codes, :instrument_id, :integer, index: true, null: false
        change_column :control_constructs, :instrument_id, :integer, index: true, null: false
        change_column :rds_qs, :instrument_id, :integer, index: true, null: false
        change_column :response_domain_codes, :instrument_id, :integer, index: true, null: false

        remove_foreign_key :question_grids, column: :vertical_code_list_id
        remove_foreign_key :question_grids, column: :horizontal_code_list_id
        remove_foreign_key :question_grids, :instructions
        remove_foreign_key :question_items, :instructions

        execute <<-SQL
          ALTER TABLE categories
          ADD CONSTRAINT encapsulate_unique_for_categories
          UNIQUE (id, instrument_id);

          ALTER TABLE code_lists
          ADD CONSTRAINT encapsulate_unique_for_code_lists
          UNIQUE (id, instrument_id);

          ALTER TABLE instructions
          ADD CONSTRAINT encapsulate_unique_for_instructions
          UNIQUE (id, instrument_id);

          ALTER TABLE response_units
          ADD CONSTRAINT encapsulate_unique_for_response_units
          UNIQUE (id, instrument_id);

          ALTER TABLE control_constructs
          ADD CONSTRAINT encapsulate_unique_for_control_constructs
          UNIQUE (construct_id, construct_type, instrument_id);

          ALTER TABLE control_constructs
          ADD CONSTRAINT encapsulate_unique_for_control_constructs_internally
          UNIQUE (id, instrument_id);

          ALTER TABLE cc_questions
          ADD CONSTRAINT encapsulate_cc_questions_and_response_units
          FOREIGN KEY (response_unit_id, instrument_id)
          REFERENCES response_units (id, instrument_id);

          ALTER TABLE question_grids
          ADD CONSTRAINT encapsulate_question_grids_and_instructions
          FOREIGN KEY (instruction_id, instrument_id)
          REFERENCES instructions (id, instrument_id);

          ALTER TABLE question_grids
          ADD CONSTRAINT encapsulate_question_grids_and_vertical_code_lists
          FOREIGN KEY (vertical_code_list_id, instrument_id)
          REFERENCES code_lists (id, instrument_id);

          ALTER TABLE question_grids
          ADD CONSTRAINT encapsulate_question_grids_and_horizontal_code_lists
          FOREIGN KEY (horizontal_code_list_id, instrument_id)
          REFERENCES code_lists (id, instrument_id);

          ALTER TABLE question_items
          ADD CONSTRAINT encapsulate_question_items_and_instructions
          FOREIGN KEY (instruction_id, instrument_id)
          REFERENCES instructions (id, instrument_id);

          ALTER TABLE codes
          ADD CONSTRAINT encapsulate_codes_and_codes_lists
          FOREIGN KEY (code_list_id, instrument_id)
          REFERENCES code_lists (id, instrument_id);

          ALTER TABLE codes
          ADD CONSTRAINT encapsulate_codes_and_categories
          FOREIGN KEY (category_id, instrument_id)
          REFERENCES categories (id, instrument_id);

          ALTER TABLE cc_conditions
          ADD CONSTRAINT encapsulate_cc_conditions_and_control_constructs
          FOREIGN KEY (id, construct_type, instrument_id)
          REFERENCES control_constructs (construct_id, construct_type, instrument_id)
          ON DELETE CASCADE
          DEFERRABLE  INITIALLY DEFERRED;

          ALTER TABLE cc_loops
          ADD CONSTRAINT encapsulate_cc_loops_and_control_constructs
          FOREIGN KEY (id, construct_type, instrument_id)
          REFERENCES control_constructs (construct_id, construct_type, instrument_id)
          ON DELETE CASCADE
          DEFERRABLE  INITIALLY DEFERRED;

          ALTER TABLE cc_questions
          ADD CONSTRAINT encapsulate_cc_questions_and_control_constructs
          FOREIGN KEY (id, construct_type, instrument_id)
          REFERENCES control_constructs (construct_id, construct_type, instrument_id)
          ON DELETE CASCADE
          DEFERRABLE  INITIALLY DEFERRED;

          ALTER TABLE cc_sequences
          ADD CONSTRAINT encapsulate_cc_sequences_and_control_constructs
          FOREIGN KEY (id, construct_type, instrument_id)
          REFERENCES control_constructs (construct_id, construct_type, instrument_id)
          ON DELETE CASCADE
          DEFERRABLE  INITIALLY DEFERRED;

          ALTER TABLE cc_statements
          ADD CONSTRAINT encapsulate_cc_statements_and_control_constructs
          FOREIGN KEY (id, construct_type, instrument_id)
          REFERENCES control_constructs (construct_id, construct_type, instrument_id)
          ON DELETE CASCADE
          DEFERRABLE  INITIALLY DEFERRED;

          ALTER TABLE control_constructs
          ADD CONSTRAINT encapsulate_control_constructs_to_its_self
          FOREIGN KEY (parent_id, instrument_id)
          REFERENCES control_constructs (id, instrument_id)
          DEFERRABLE  INITIALLY DEFERRED;
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE cc_questions
          DROP CONSTRAINT encapsulate_cc_questions_and_response_units;

          ALTER TABLE question_grids
          DROP CONSTRAINT encapsulate_question_grids_and_instructions;

          ALTER TABLE question_grids
          DROP CONSTRAINT encapsulate_question_grids_and_vertical_code_lists;

          ALTER TABLE question_grids
          DROP CONSTRAINT encapsulate_question_grids_and_horizontal_code_lists;

          ALTER TABLE question_items
          DROP CONSTRAINT encapsulate_question_items_and_instructions;

          ALTER TABLE cc_conditions
          DROP CONSTRAINT encapsulate_cc_conditions_and_control_constructs;

          ALTER TABLE cc_loops
          DROP CONSTRAINT encapsulate_cc_loops_and_control_constructs;

          ALTER TABLE cc_questions
          DROP CONSTRAINT encapsulate_cc_questions_and_control_constructs;

          ALTER TABLE cc_sequences
          DROP CONSTRAINT encapsulate_cc_sequences_and_control_constructs;

          ALTER TABLE cc_statements
          DROP CONSTRAINT encapsulate_cc_statements_and_control_constructs;

          ALTER TABLE control_constructs
          DROP CONSTRAINT encapsulate_control_constructs_to_its_self;

          ALTER TABLE codes
          DROP CONSTRAINT encapsulate_codes_and_codes_lists;

          ALTER TABLE codes
          DROP CONSTRAINT encapsulate_codes_and_categories;

          ALTER TABLE categories
          DROP CONSTRAINT encapsulate_unique_for_categories;

          ALTER TABLE code_lists
          DROP CONSTRAINT encapsulate_unique_for_code_lists;

          ALTER TABLE instructions
          DROP CONSTRAINT encapsulate_unique_for_instructions;

          ALTER TABLE response_units
          DROP CONSTRAINT encapsulate_unique_for_response_units;

          ALTER TABLE control_constructs
          DROP CONSTRAINT encapsulate_unique_for_control_constructs;

          ALTER TABLE control_constructs
          DROP CONSTRAINT encapsulate_unique_for_control_constructs_internally;
        SQL

        add_foreign_key :question_items, :instructions
        add_foreign_key :question_grids, :instructions
        add_foreign_key :question_grids, :code_lists, column: :vertical_code_list_id
        add_foreign_key :question_grids, :code_lists, column: :horizontal_code_list_id

        remove_reference :codes, :instrument, index: true, foreign_key: true
        remove_reference :control_constructs, :instrument, index: true, foreign_key: true
        remove_reference :rds_qs, :instrument, index: true, foreign_key: true
        remove_reference :response_domain_codes, :instrument, index: true, foreign_key: true

        remove_column :cc_conditions,  :construct_type
        remove_column :cc_loops,       :construct_type
        remove_column :cc_questions,   :construct_type
        remove_column :cc_sequences,   :construct_type
        remove_column :cc_statements,  :construct_type

        remove_column :response_domain_codes,     :response_domain_type
        remove_column :response_domain_datetimes, :response_domain_type
        remove_column :response_domain_numerics,  :response_domain_type
        remove_column :response_domain_texts,     :response_domain_type

        remove_column :question_grids,  :question_type
        remove_column :question_items,  :question_type
      end
    end

  end
end
