class AddingAncestoralTopicMaterializedView < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        execute <<~SQL
          CREATE MATERIALIZED VIEW ancestral_topic AS (
            WITH RECURSIVE cc_tree AS ( SELECT ccl.*, 1 AS level FROM cc_links ccl
              UNION ALL
              SELECT
              ccl.*,
                  tree.level + 1
              FROM
              cc_links AS ccl
              JOIN
              cc_tree AS tree
              ON tree.parent_id = ccl.id
              )
              SELECT
              t.*,
                  tree.construct_id,
                  tree.construct_type
              FROM
              cc_tree AS tree
              INNER JOIN
              topics AS t
              ON tree.topic_id = t.id
              WHERE
              tree.topic_id IS NOT NULL
              ORDER BY
              level
            );
  
          CREATE FUNCTION refresh_ancestral_topics()
          RETURNS trigger
          AS $$
          BEGIN
            REFRESH MATERIALIZED VIEW ancestral_topic;
            RETURN NULL;
          END;
          $$ LANGUAGE plpgsql;
          CREATE TRIGGER update_links
          AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE ON links
          FOR EACH STATEMENT EXECUTE PROCEDURE refresh_ancestral_topics();
        SQL
      end
      dir.down do
        execute <<~SQL
          DROP TRIGGER update_links;
          DROP FUNCTION refresh_ancestral_topics();
          DROP MATERIALIZED VIEW ancestral_topic;
        SQL
      end
    end
  end
end
