class AddSlugs < ActiveRecord::Migration[6.1]
  def up
    # Tables to update, including :instruments
    tables = [:categories, :code_lists, :codes, :control_constructs, :identifiers, :instructions, :question_items, :question_grids, :instruments]
    
    # Add ddi_slug columns and indexes
    tables.each do |table|
      add_column table, :ddi_slug, :string
      if column_exists?(table, :instrument_id)
        add_index table, [:ddi_slug, :instrument_id], unique: true
      else
        add_index table, :ddi_slug, unique: true        
      end
    end

    # Populate the ddi_slug for each table
    tables.each do |table|
      # Assuming id is an integer and can be safely cast to string for ddi_slug
      execute <<-SQL.squish
        UPDATE #{table}
        SET ddi_slug = CAST(id AS TEXT);
      SQL
    end
  end

  def down
    # Tables to update, including :instruments
    tables = [:categories, :code_lists, :codes, :control_constructs, :identifiers, :instructions, :question_items, :question_grids, :instruments]
    
    # Remove ddi_slug columns and indexes
    tables.each do |table|
      remove_index table, :ddi_slug if index_exists?(table, :ddi_slug)
      remove_column table, :ddi_slug
    end
  end
end
