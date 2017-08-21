# The ParentalConstruct model is an abstract class that provides
# the relationships for models that can have children to be able
# to access them.
class ParentalConstruct < ControlConstruct
  self.abstract_class = true

  # All {CcCondition} children
  has_many :cc_conditions, as: :parent , dependent: :destroy

  # All {CcLoop} children
  has_many :cc_loops, as: :parent , dependent: :destroy

  # All {CcQuestion} children
  has_many :cc_questions, as: :parent , dependent: :destroy

  # All {CcSequence} children
  has_many :cc_sequences, as: :parent , dependent: :destroy

  # All {CcStatement} children
  has_many :cc_statements, as: :parent , dependent: :destroy

  # Any parental construct can have a topic directly
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

  # Returns an array of all children in order
  #
  # @returns [Array] All children
  def children
    (
          cc_conditions +
          cc_loops +
          cc_questions +
          cc_sequences +
          cc_statements
    ).sort_by { |cc| [branch, cc.position] }
  end

  # Returns the first child construct
  #
  # @returns [ControlConstruct] First child construct
  def first_child
    children.min_by { |x| x.position}
  end

  # Returns the last child construct
  #
  # @returns [ControlConstruct] Last child construct
  def last_child
    children.max_by { |x| x.position}
  end

  # Returns true if the construct has any children
  #
  # @returns [Boolean] True for having children; False for no children
  def has_children?
    children.count > 0
  end

  # TODO: Needs updating or replacing
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
