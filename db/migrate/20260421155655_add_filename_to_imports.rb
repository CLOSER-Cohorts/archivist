# frozen_string_literal: true

class AddFilenameToImports < ActiveRecord::Migration[6.1]
  def up
    add_column :imports, :filename, :string
    execute <<~SQL
      UPDATE imports
      SET filename = documents.filename
      FROM documents
      WHERE imports.document_id = documents.id
    SQL
  end

  def down
    remove_column :imports, :filename
  end
end
