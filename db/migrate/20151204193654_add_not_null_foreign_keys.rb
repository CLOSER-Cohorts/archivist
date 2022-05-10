class AddNotNullForeignKeys < ActiveRecord::Migration[4.2]
  def change
    change_column :codes, :category_id, :integer, null: false
    change_column :codes, :code_list_id, :integer, null: false
    change_column :response_domain_codes, :code_list_id, :integer, null: false
    change_column :rds_qs, :question_id, :integer, null: false
    change_column :rds_qs, :question_type, :string, null: false
    change_column :rds_qs, :response_domain_id, :integer, null: false
    change_column :rds_qs, :response_domain_type, :string, null: false
    change_column :control_constructs, :construct_id, :integer, null: false
    change_column :control_constructs, :construct_type, :string, null: false
    change_column :cc_questions, :question_id, :integer, null: false
    change_column :cc_questions, :question_type, :string, null: false
    change_column :cc_questions, :response_unit_id, :integer, null: false
    change_column :question_grids, :horizontal_code_list_id, :integer, null: false
    change_column :question_grids, :vertical_code_list_id, :integer, null: false
  end
end
