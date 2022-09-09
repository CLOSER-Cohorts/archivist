class RemoveNotNullVerticalCodeList < ActiveRecord::Migration[4.2]
  def change
    change_column :question_grids, :vertical_code_list_id, :integer, null: true
  end
end
