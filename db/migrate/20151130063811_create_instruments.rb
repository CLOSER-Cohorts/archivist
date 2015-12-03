class CreateInstruments < ActiveRecord::Migration
  def change
    create_table :instruments do |t|
      t.string :agency
      t.string :version
      t.string :prefix
      t.string :label
      t.string :study

      t.timestamps null: false
    end
  end
end
