class AddCodeReferencesToRdsQs < ActiveRecord::Migration
  def change
    add_reference :rds_qs, :code, index: true
  end
end
