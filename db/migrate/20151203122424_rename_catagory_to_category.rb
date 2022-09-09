class RenameCatagoryToCategory < ActiveRecord::Migration[4.2]
  def change
    rename_table :catagories, :categories
    rename_column :codes, :catagory_id, :category_id
  end
end
