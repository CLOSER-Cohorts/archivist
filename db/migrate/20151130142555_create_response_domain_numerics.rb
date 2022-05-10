class CreateResponseDomainNumerics < ActiveRecord::Migration[4.2]
  def change
    create_table :response_domain_numerics do |t|
      t.string :numeric_type
      t.string :label
      t.decimal :min
      t.decimal :max

      t.timestamps null: false
    end
  end
end
