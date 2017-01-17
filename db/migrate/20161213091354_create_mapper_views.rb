class CreateMapperViews < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        execute <<~SQL
          CREATE VIEW qv_mappings AS (
          SELECT row_number() OVER () as id, COALESCE(cc.label, '0') as question, v.name as variable, m.x, m.y, qc.instrument_id, v.dataset_id FROM variables v
          LEFT JOIN maps m ON m.variable_id = v.id
          INNER JOIN cc_questions qc ON qc.id = m.source_id AND m.source_type = 'CcQuestion'
          INNER JOIN control_constructs cc ON qc.id = cc.construct_id AND cc.construct_type = 'CcQuestion'
          );

          CREATE VIEW dv_mappings AS (
          SELECT row_number() OVER () as id, s.name as source, v.name as variable, v.dataset_id FROM maps m
          INNER JOIN variables v ON m.variable_id = v.id
          INNER JOIN variables s ON s.id = m.source_id AND m.source_type = 'Variable'
          );
        SQL
      end

      dir.down do
        execute <<~SQL
          DROP VIEW qv_mappings;
          DROP VIEW dv_mappings;
        SQL
      end
    end
  end
end
