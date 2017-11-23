class CreateIdentifiers < ActiveRecord::Migration[5.0]
  def change
    create_table :identifiers do |t|
      t.string :id_type
      t.string :value
      t.references :item, polymorphic: true, null: false

      t.timestamps
    end

    add_index 'identifiers', %w(id_type value), :unique => true
  end
end
