class CreateCodes < ActiveRecord::Migration[4.2]
  def change
    create_table :codes do |t|
      t.string :value
      t.integer :order
      t.references :code_list, index: true, foreign_key: true
      t.references :catagory, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
