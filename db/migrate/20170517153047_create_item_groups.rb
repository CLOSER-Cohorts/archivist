class CreateItemGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :item_groups do |t|
      t.integer :group_type
      t.string :item_type
      t.string :label
      t.references :root_item, polymorphic: true

      t.timestamps
    end
  end
end
