class UniqueMapping < ActiveRecord::Migration[5.0]
  def change
    add_index :maps, %i(source_id variable_id), unique: true, where: 'source_type = \'Variable\''
    add_index :maps, %i(source_id variable_id x y), unique: true, where: 'source_type = \'Question\''
  end
end
