class MakePrefixUnique < ActiveRecord::Migration[5.0]
  def change
    change_column :instruments, :prefix, :string, unique: true
  end
end
