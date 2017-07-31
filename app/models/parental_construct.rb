# The ControlConstruct model is used to hold the positional information
# for all five of the construct models. Every construct must have one
# ControlConstruct and vice-versa.
#
# === Properties
# * Label
# * Position
# * Parent
# * Branch
class ParentalConstruct < ControlConstruct
  self.abstract_class = true

  has_many :cc_conditions, as: :parent , dependent: :destroy
  has_many :cc_loops, as: :parent , dependent: :destroy
  has_many :cc_questions, as: :parent , dependent: :destroy
  has_many :cc_sequences, as: :parent , dependent: :destroy
  has_many :cc_statements, as: :parent , dependent: :destroy
  belongs_to :topic

  #TODO: Needs updating
  def all_children_ccs
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
                 ON tree.id = ccl.parent_id
        )
        SELECT
           tree.* 
        FROM
           cc_tree AS tree
        WHERE
           NOT (
              tree.construct_id = ? 
              AND tree.construct_type = ? 
           )
    SQL

=begin
    ::ControlConstruct.find_by_sql([
                                       sql,
                                       self.id,
                                       self.class.name,
                                       self.id,
                                       self.class.name
                                   ])
=end
  end

  def children
    (
          cc_conditions +
          cc_loops +
          cc_questions +
          cc_sequences +
          cc_statements
    ).sort_by { |cc| [branch, cc.position] }
  end

  def first_child
    children.min_by { |x| x.position}
  end

  def last_child
    children.max_by { |x| x.position}
  end

  def has_children?
    children.count > 0
  end

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
           NOT (
              tree.construct_id = ? 
              AND tree.construct_type = ? 
           )
           AND tree.topic_id IS NOT NULL 
        ORDER BY
           level LIMIT 1
    SQL

    Topic.find_by_sql([
                          sql,
                          self.id,
                          self.class.name,
                          self.id,
                          self.class.name
                      ]).first
  end
end
