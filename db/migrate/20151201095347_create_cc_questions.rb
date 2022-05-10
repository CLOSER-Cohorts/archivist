class CreateCcQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :cc_questions do |t|
      t.references :question, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
