class AddResponseUnitToCcQuestions < ActiveRecord::Migration
  def change
    add_reference :cc_questions, :response_unit, index: true
  end
end
