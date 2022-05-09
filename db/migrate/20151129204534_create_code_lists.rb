class CreateCodeLists < ActiveRecord::Migration[4.2]
  def change
    create_table :code_lists do |t|
      t.string :label

      t.timestamps null: false
    end
  end
end
