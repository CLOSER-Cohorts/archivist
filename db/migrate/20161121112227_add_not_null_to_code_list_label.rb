class AddNotNullToCodeListLabel < ActiveRecord::Migration[5.0]
  def change
    change_column_null :code_lists, :label, false
  end
end
