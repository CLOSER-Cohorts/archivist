class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :type
      t.string :label
      t.string :study

      t.timestamps null: false
    end
  end
end
