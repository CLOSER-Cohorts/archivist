class CreateControlConstructs < ActiveRecord::Migration
  def change
    create_table :control_constructs do |t|
      t.string :label
      t.references :construct, polymorphic: true, index: true
      t.integer :parent_id, index: true
#      t.references :parent, index: true, foreign_key: true
      t.integer :position
      t.integer :branch

      t.timestamps null: false
    end
    add_foreign_key :control_constructs, :control_constructs, column: :parent_id
  end
end
