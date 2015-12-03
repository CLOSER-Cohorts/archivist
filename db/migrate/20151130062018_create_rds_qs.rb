class CreateRdsQs < ActiveRecord::Migration
  def change
    create_table :rds_qs do |t|
      t.references :response_domain, polymorphic: true, index: true
      t.references :question, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
