class RenameGroupsToUserGroups < ActiveRecord::Migration[5.0]
  def change
    rename_table 'groups', 'user_groups'
  end
end
