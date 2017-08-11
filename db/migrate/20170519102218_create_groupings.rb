class CreateGroupings < ActiveRecord::Migration[5.0]
  def change
    create_table :streamlined_groupings do |t|
      t.references :item_group, foreign_key: true, null: false
      t.integer :item_id, null: false, foreign_ke: true

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL
          CREATE VIEW groupings AS (
            SELECT sg.id, sg.item_id, g.item_type, sg.item_group_id, sg.created_at, sg.updated_at
            FROM streamlined_groupings sg
            INNER JOIN item_groups g
            ON sg.item_group_id = g.id
          );
          CREATE RULE groupings_insert AS
          ON INSERT TO groupings DO 
          INSTEAD INSERT INTO streamlined_groupings(item_id, item_group_id, created_at, updated_at)
          VALUES (new.item_id, new.item_group_id, new.created_at, new.updated_at)
          RETURNING 
          id, 
          item_id, 
          (SELECT item_type FROM item_groups WHERE item_group_id=item_groups.id), 
          item_group_id,
          created_at,
          updated_at;
          CREATE RULE groupings_delete AS
          ON DELETE TO groupings DO
          INSTEAD DELETE FROM streamlined_groupings WHERE id = old.id;
        SQL
      end
      dir.down do
        execute <<~SQL
          DROP RULE groupings_insert ON groupings;
          DROP RULE groupings_delete ON groupings;
          DROP VIEW groupings;
        SQL
      end
    end
  end
end
