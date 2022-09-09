class CreateDatasets < ActiveRecord::Migration[4.2]
  def change
    create_table :datasets do |t|
      t.string :name, null: false, unique: true
      t.string :doi
      t.string :filename

      t.timestamps null: false
    end
  end
end
