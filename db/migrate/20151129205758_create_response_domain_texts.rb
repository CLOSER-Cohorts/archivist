class CreateResponseDomainTexts < ActiveRecord::Migration[4.2]
  def change
    create_table :response_domain_texts do |t|
      t.string :label
      t.integer :maxlen

      t.timestamps null: false
    end
  end
end
