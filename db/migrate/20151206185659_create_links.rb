class CreateLinks < ActiveRecord::Migration[4.2]
  def change
    create_table :links do |t|
      t.references :target, polymorphic: true, index: true, null: false
      t.references :topic, index: true, foreign_key: true, null: false
      t.integer :x
      t.integer :y

      t.timestamps null: false
    end
    add_index :links, [:target_id, :target_type, :topic_id, :x, :y], unique: true, name: 'unique_linking'
  end
end
