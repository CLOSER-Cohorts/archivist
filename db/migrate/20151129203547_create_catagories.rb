class CreateCatagories < ActiveRecord::Migration[4.2]
  def change
    create_table :catagories do |t|
      t.string :label

      t.timestamps null: false
    end
  end
end
