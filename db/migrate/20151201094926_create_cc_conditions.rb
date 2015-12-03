class CreateCcConditions < ActiveRecord::Migration
  def change
    create_table :cc_conditions do |t|
      t.string :literal
      t.string :logic

      t.timestamps null: false
    end
  end
end
