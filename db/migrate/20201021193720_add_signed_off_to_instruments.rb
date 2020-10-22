class AddSignedOffToInstruments < ActiveRecord::Migration[5.2]
  def change
    unless column_exists? :instruments, :signed_off
      add_column :instruments, :signed_off, :boolean, default: false
    end
  end
end
