class AddStudyToDatasets < ActiveRecord::Migration[5.0]
  def change
    add_column :datasets, :study, :string, null: true
  end
end
