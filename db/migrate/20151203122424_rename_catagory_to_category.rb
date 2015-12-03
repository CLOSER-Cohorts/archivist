class RenameCatagoryToCategory < ActiveRecord::Migration
  def change
    rename_table :catagories, :categories
    rename_column :codes, :catagory_id, :category_id
  end
end
