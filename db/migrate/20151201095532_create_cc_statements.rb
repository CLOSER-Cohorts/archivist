class CreateCcStatements < ActiveRecord::Migration[4.2]
  def change
    create_table :cc_statements do |t|
      t.string :literal

      t.timestamps null: false
    end
  end
end
