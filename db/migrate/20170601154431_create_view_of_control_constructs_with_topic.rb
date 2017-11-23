class CreateViewOfControlConstructsWithTopic < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        execute <<~SQL
          CREATE VIEW cc_links AS (
            SELECT cc.*, l.topic_id 
            FROM control_constructs AS cc 
            LEFT OUTER JOIN links AS l 
            ON l.target_id = cc.construct_id AND l.target_type = cc.construct_type 
            ORDER BY cc.id DESC
          );
        SQL
      end

      dir.down do
        execute <<~SQL
          DROP VIEW cc_links;
        SQL
      end
    end
  end
end
