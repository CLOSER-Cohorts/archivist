module LinkableParent
  extend ActiveSupport::Concern
  included do
    has_one :link, as: :target, dependent: :destroy
    has_one :topic, through: :link

    def find_closest_ancestor_topic
      sql = <<~SQL
        SELECT id, name, parent_id, code, created_at, updated_at, description
        FROM ancestral_topic
        WHERE construct_id = ?
        AND construct_type = ?
      SQL

      Topic.find_by_sql([
                            sql,
                            self.id,
                            self.class.name
                        ]).first
    end
  end
end