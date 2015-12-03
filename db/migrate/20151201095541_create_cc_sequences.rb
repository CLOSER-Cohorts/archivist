class CreateCcSequences < ActiveRecord::Migration
  def change
    create_table :cc_sequences do |t|
      t.string :literal

      t.timestamps null: false
    end
  end
end
