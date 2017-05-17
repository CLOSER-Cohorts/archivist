class CreateItemGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :item_groups do |t|
      t.references :item, polymorphic: true
      t.integer :group_type
      t.references :root_item, polymorphic: true

      t.timestamps
    end
  end
end
