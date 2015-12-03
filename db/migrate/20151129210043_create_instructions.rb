class CreateInstructions < ActiveRecord::Migration
  def change
    create_table :instructions do |t|
      t.string :text

      t.timestamps null: false
    end
  end
end
