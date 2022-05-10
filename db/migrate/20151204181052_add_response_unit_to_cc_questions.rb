class AddResponseUnitToCcQuestions < ActiveRecord::Migration[4.2]
  def change
    add_reference :cc_questions, :response_unit, index: true
  end
end
