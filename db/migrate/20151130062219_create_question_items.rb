class CreateQuestionItems < ActiveRecord::Migration
  def change
    create_table :question_items do |t|
      t.string :label
      t.string :literal
      t.references :instruction, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
