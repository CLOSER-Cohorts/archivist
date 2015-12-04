class AddNotNullForeignKeys < ActiveRecord::Migration
  def change
    change_column :codes, :category_id, :integer, null: false
    change_column :codes, :code_list_id, :integer, null: false
    change_column :response_domain_codes, :code_list_id, :integer, null: false
    change_column :rds_qs, :question_id, :integer, null: false
    change_column :rds_qs, :question_type, :string, null: false
    change_column :rds_qs, :response_domain_id, :integer, null: false
  end
end
