class FixGroupColumnName < ActiveRecord::Migration[4.2]
  def change
    rename_column :groups, :type, :group_type
  end
end
