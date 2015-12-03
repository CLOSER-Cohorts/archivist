class CreateCcStatements < ActiveRecord::Migration
  def change
    create_table :cc_statements do |t|
      t.string :literal

      t.timestamps null: false
    end
  end
end
