module LinkableParent
  extend ActiveSupport::Concern
  included do
    has_one :link, as: :target, dependent: :destroy
    has_one :topic, through: :link

    def find_closest_ancestor
      begin
        <<~SQL
          WITH constructs_selection AS (
            SELECT *
            FROM cc_links
            WHERE construct_id = ?
              AND construct_type = ?
            ORDER BY id, construct_id, parent_id, branch
          ) SELECT topics.id, "name", topics.parent_id, code, topics.created_at, topics.updated_at, description
              FROM constructs_selection
              LEFT JOIN topics
                ON constructs_selection.topic_id = topics.id
                where constructs_selection.topic_id IS NOT NULL
          ;
        SQL
      end
    end

    def find_closest_ancestor_topic
      @sql ||= find_closest_ancestor
      @topic ||= begin
        Topic.find_by_sql([
                            @sql,
                            self.id,
                            self.class.name
                        ]).first
      end
    end
  end
end
