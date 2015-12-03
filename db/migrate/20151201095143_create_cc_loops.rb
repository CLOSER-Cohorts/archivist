class CreateCcLoops < ActiveRecord::Migration
  def change
    create_table :cc_loops do |t|
      t.string :loop_var
      t.string :start_val
      t.string :end_val
      t.string :loop_while

      t.timestamps null: false
    end
  end
end
