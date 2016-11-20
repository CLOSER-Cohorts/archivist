class CreateMapperDsets < ActiveRecord::Migration[5.0]
  def change
    create_table :mapper_dsets do |t|

      t.timestamps
    end
  end
end
