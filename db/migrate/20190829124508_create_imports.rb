class CreateImports < ActiveRecord::Migration[5.0]
  def change
    create_table :imports do |t|
      t.references :document, foreign_key: true
      t.string :import_type
      t.references :dataset, foreign_key: true
      t.string :state
      t.text :log

      t.timestamps
    end
  end
end
