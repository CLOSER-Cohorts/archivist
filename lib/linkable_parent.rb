module LinkableParent
  extend ActiveSupport::Concern
  included do
    has_one :link, as: :target, dependent: :destroy
    has_one :topic, through: :link

    def find_closest_ancestor_topic
      sql = <<~SQL
        WITH RECURSIVE cc_tree AS 
        (
           SELECT
              ccl.*,
              1 AS level 
           FROM
              cc_links AS ccl 
           WHERE
              construct_id = ? 
              AND construct_type = ? 
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
           t.* 
        FROM
           cc_tree AS tree
        INNER JOIN
           topics AS t
        ON tree.topic_id = t.id
        WHERE
           tree.construct_id = ? 
           AND tree.construct_type = ? 
           AND tree.topic_id IS NOT NULL 
        ORDER BY
           level LIMIT 1
      SQL

      Topic.find_by_sql [
                            sql,
                            self.construct_id,
                            self.construct_type,
                            self.construct_id,
                            self.construct_type
                        ]
    end
  end
end