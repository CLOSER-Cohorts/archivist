class AddQuestionLabelConstraints < ActiveRecord::Migration[5.0]
  def change
    change_column_null :question_items, :label, false
    change_column_null :question_grids, :label, false

    add_index :question_grids, [:label, :instrument_id], unique: true unless index_exists?(:question_grids, [:label, :instrument_id], unique: true)
    add_index :question_items, [:label, :instrument_id], unique: true unless index_exists?(:question_items, [:label, :instrument_id], unique: true)
  end
end
