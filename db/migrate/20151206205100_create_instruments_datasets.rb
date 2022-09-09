class CreateInstrumentsDatasets < ActiveRecord::Migration[4.2]
  def change
    create_table :instruments_datasets do |t|
      t.references :instrument, index: true, foreign_key: true, null: false
      t.references :dataset, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
