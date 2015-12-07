class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.references :source, polymorphic: true, index: true, null: false
      t.references :variable, index: true, foreign_key: true, null: false
      t.integer :x
      t.integer :y

      t.timestamps null: false
    end
    add_index :maps, [:source_id, :source_type, :variable_id, :x, :y], unique: true, name: 'unique_mapping'
  end
end
