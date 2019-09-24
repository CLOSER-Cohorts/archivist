class AddSlugToInstruments < ActiveRecord::Migration[5.0]
  def change
    unless column_exists? :instruments, :slug
      add_column :instruments, :slug, :string
      add_index :instruments, :slug, unique: true
    end

    Instrument.find_each{|i| i.update_column(:slug, i.prefix)}
  end
end
