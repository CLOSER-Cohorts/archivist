class CreateCodeLists < ActiveRecord::Migration
  def change
    create_table :code_lists do |t|
      t.string :label

      t.timestamps null: false
    end
  end
end
