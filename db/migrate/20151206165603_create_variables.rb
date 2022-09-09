class CreateVariables < ActiveRecord::Migration[4.2]
  def change
    create_table :variables do |t|
      t.string :name, null: false
      t.string :label
      t.string :var_type, null: false
      t.references :dataset, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :variables, [:name, :dataset_id], unique: true
  end
end
