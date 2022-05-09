class CreateCcConditions < ActiveRecord::Migration[4.2]
  def change
    create_table :cc_conditions do |t|
      t.string :literal
      t.string :logic

      t.timestamps null: false
    end
  end
end
