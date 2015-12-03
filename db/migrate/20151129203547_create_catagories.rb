class CreateCatagories < ActiveRecord::Migration
  def change
    create_table :catagories do |t|
      t.string :label

      t.timestamps null: false
    end
  end
end
