class AddInstrumentReferencesToEverythingButJunctions < ActiveRecord::Migration
  def change
    add_reference :categories, :instrument, index: true, null: false
    add_reference :code_lists, :instrument, index: true, null: false
    add_reference :response_domain_datetimes, :instrument, index: true, null: false
    add_reference :response_domain_numerics, :instrument, index: true, null: false
    add_reference :response_domain_texts, :instrument, index: true, null: false
    add_reference :cc_loops, :instrument, index: true, null: false
    add_reference :cc_sequences, :instrument, index: true, null: false
    add_reference :cc_statements, :instrument, index: true, null: false
    add_reference :cc_questions, :instrument, index: true, null: false
    add_reference :cc_conditions, :instrument, index: true, null: false
    add_reference :response_units, :instrument, index: true, null: false
    add_reference :instructions, :instrument, index: true, null: false
    add_reference :question_items, :instrument, index: true, null: false
    add_reference :question_grids, :instrument, index: true, null: false
  end
end
