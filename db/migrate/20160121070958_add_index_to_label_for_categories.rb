class AddIndexToLabelForCategories < ActiveRecord::Migration[4.2]
  def change
    add_index :categories, :label
  end
end
