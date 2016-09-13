class AddResponseCardinality < ActiveRecord::Migration[5.0]
  def change
    add_column :response_domain_codes, :min_responses, :integer, default: 1, null: false
    add_column :response_domain_codes, :max_responses, :integer, default: 1, null: false
  end
end
