class AddUniqueLabelsWithinInstrument < ActiveRecord::Migration[5.0]
  def change
    add_index :control_constructs, [:label, :instrument_id], unique: true
    add_index :code_lists, [:label, :instrument_id], unique: true
    add_index :categories, [:label, :instrument_id], unique: true
    add_index :instructions, [:text, :instrument_id], unique: true
    add_index :question_grids, [:label, :instrument_id], unique: true
    add_index :question_items, [:label, :instrument_id], unique: true
  end
end
