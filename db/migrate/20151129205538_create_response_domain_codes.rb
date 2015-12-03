class CreateResponseDomainCodes < ActiveRecord::Migration
  def change
    create_table :response_domain_codes do |t|
      t.references :code_list, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
