class CreateDocuments < ActiveRecord::Migration[5.0]
  def change
    create_table :documents do |t|
      t.string :filename
      t.string :content_type
      t.binary :file_contents
      t.string :md5_hash, limit: 32
      t.references :item, polymorphic: true

      t.timestamps
    end
    add_index :documents, :md5_hash, unique: true
  end
end
