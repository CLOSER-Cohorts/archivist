class AddInstrumentsToImports < ActiveRecord::Migration[5.0]
  def change
    add_reference :imports, :instrument, index: true
  end
end
