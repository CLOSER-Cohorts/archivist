class DeferAllConstraints < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE cc_questions
          DROP CONSTRAINT encapsulate_cc_questions_and_response_units;

          ALTER TABLE codes
          DROP CONSTRAINT encapsulate_codes_and_categories;

          ALTER TABLE codes
          DROP CONSTRAINT encapsulate_codes_and_codes_lists;

          ALTER TABLE question_grids
          DROP CONSTRAINT encapsulate_question_grids_and_horizontal_code_lists;

          ALTER TABLE question_grids
          DROP CONSTRAINT encapsulate_question_grids_and_instructions;

          ALTER TABLE question_grids
          DROP CONSTRAINT encapsulate_question_grids_and_vertical_code_lists;

          ALTER TABLE question_items
          DROP CONSTRAINT encapsulate_question_items_and_instructions;


          ALTER TABLE cc_questions
          ADD CONSTRAINT encapsulate_cc_questions_and_response_units
          FOREIGN KEY (response_unit_id, instrument_id)
          REFERENCES response_units(id, instrument_id)
          DEFERRABLE INITIALLY DEFERRED;

          ALTER TABLE codes
          ADD CONSTRAINT encapsulate_codes_and_categories
          FOREIGN KEY (category_id, instrument_id)
          REFERENCES categories(id, instrument_id)
          DEFERRABLE INITIALLY DEFERRED;

          ALTER TABLE codes
          ADD CONSTRAINT encapsulate_codes_and_codes_lists
          FOREIGN KEY (code_list_id, instrument_id)
          REFERENCES code_lists(id, instrument_id)
          DEFERRABLE INITIALLY DEFERRED;

          ALTER TABLE question_grids
          ADD CONSTRAINT encapsulate_question_grids_and_horizontal_code_lists
          FOREIGN KEY (horizontal_code_list_id, instrument_id)
          REFERENCES code_lists(id, instrument_id)
          DEFERRABLE INITIALLY DEFERRED;

          ALTER TABLE question_grids
          ADD CONSTRAINT encapsulate_question_grids_and_instructions
          FOREIGN KEY (instruction_id, instrument_id)
          REFERENCES instructions(id, instrument_id)
          DEFERRABLE INITIALLY DEFERRED;

          ALTER TABLE question_grids
          ADD CONSTRAINT encapsulate_question_grids_and_vertical_code_lists
          FOREIGN KEY (vertical_code_list_id, instrument_id)
          REFERENCES code_lists(id, instrument_id)
          DEFERRABLE INITIALLY DEFERRED;

          ALTER TABLE question_items
          ADD CONSTRAINT encapsulate_question_items_and_instructions
          FOREIGN KEY (instruction_id, instrument_id)
          REFERENCES instructions(id, instrument_id)
          DEFERRABLE INITIALLY DEFERRED;
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE cc_questions
          DROP CONSTRAINT encapsulate_cc_questions_and_response_units;

          ALTER TABLE codes
          DROP CONSTRAINT encapsulate_codes_and_categories;

          ALTER TABLE codes
          DROP CONSTRAINT encapsulate_codes_and_codes_lists;

          ALTER TABLE question_grids
          DROP CONSTRAINT encapsulate_question_grids_and_horizontal_code_lists;

          ALTER TABLE question_grids
          DROP CONSTRAINT encapsulate_question_grids_and_instructions;

          ALTER TABLE question_grids
          DROP CONSTRAINT encapsulate_question_grids_and_vertical_code_lists;

          ALTER TABLE question_items
          DROP CONSTRAINT encapsulate_question_items_and_instructions;


          ALTER TABLE cc_questions
          ADD CONSTRAINT encapsulate_cc_questions_and_response_units
          FOREIGN KEY (response_unit_id, instrument_id)
          REFERENCES response_units(id, instrument_id);

          ALTER TABLE codes
          ADD CONSTRAINT encapsulate_codes_and_categories
          FOREIGN KEY (category_id, instrument_id)
          REFERENCES categories(id, instrument_id);

          ALTER TABLE codes
          ADD CONSTRAINT encapsulate_codes_and_codes_lists
          FOREIGN KEY (code_list_id, instrument_id)
          REFERENCES code_lists(id, instrument_id);

          ALTER TABLE question_grids
          ADD CONSTRAINT encapsulate_question_grids_and_horizontal_code_lists
          FOREIGN KEY (horizontal_code_list_id, instrument_id)
          REFERENCES code_lists(id, instrument_id);

          ALTER TABLE question_grids
          ADD CONSTRAINT encapsulate_question_grids_and_instructions
          FOREIGN KEY (instruction_id, instrument_id)
          REFERENCES instructions(id, instrument_id);

          ALTER TABLE question_grids
          ADD CONSTRAINT encapsulate_question_grids_and_vertical_code_lists
          FOREIGN KEY (vertical_code_list_id, instrument_id)
          REFERENCES code_lists(id, instrument_id);

          ALTER TABLE question_items
          ADD CONSTRAINT encapsulate_question_items_and_instructions
          FOREIGN KEY (instruction_id, instrument_id)
          REFERENCES instructions(id, instrument_id);
        SQL
      end
    end
  end
end
