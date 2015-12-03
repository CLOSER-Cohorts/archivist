class CreateResponseUnits < ActiveRecord::Migration
  def change
    create_table :response_units do |t|
      t.string :label

      t.timestamps null: false
    end
  end
end
