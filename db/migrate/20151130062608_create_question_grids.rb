class CreateQuestionGrids < ActiveRecord::Migration[4.2]
  def change
    create_table :question_grids do |t|
      t.string :label
      t.string :literal
      t.references :instruction, index: true, foreign_key: true
      t.integer :vertical_code_list_id, index: true
      t.integer :horizontal_code_list_id, index: true
#      t.references :vertical_code_list, index: true, foreign_key: true
#      t.references :horizontal_code_list, index: true, foreign_key: true
      t.integer :roster_rows, default: 0
      t.string :roster_label
      t.string :corner_label

      t.timestamps null: false
    end
    add_foreign_key :question_grids, :code_lists, column: :vertical_code_list_id
    add_foreign_key :question_grids, :code_lists, column: :horizontal_code_list_id
  end
end
