class AddCodeReferencesToRdsQs < ActiveRecord::Migration[4.2]
  def change
    add_reference :rds_qs, :code, index: true
  end
end
