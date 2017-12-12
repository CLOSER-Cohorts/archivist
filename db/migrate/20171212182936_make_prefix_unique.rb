class MakePrefixUnique < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        change_column :instruments, :prefix, :string, unique: true
      end
      dir.down do
        change_column :instruments, :prefix, :string
      end
    end
  end
end
