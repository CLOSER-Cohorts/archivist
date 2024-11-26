class CreateExports < ActiveRecord::Migration[6.1]
  def change
    create_table :exports do |t|
      t.references :document, foreign_key: true, null: true
      t.string :export_type
      t.references :dataset, foreign_key: true, null: true
      t.references :instrument, foreign_key: true, null: true
      t.string :state
      t.text :log

      t.timestamps
    end
  end
end
