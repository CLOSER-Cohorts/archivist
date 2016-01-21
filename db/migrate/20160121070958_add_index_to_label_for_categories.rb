class AddIndexToLabelForCategories < ActiveRecord::Migration
  def change
    add_index :categories, :label
  end
end
