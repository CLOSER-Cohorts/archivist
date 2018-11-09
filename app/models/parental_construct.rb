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
    sql ||= <<~SQL
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
  # @return [Array] All children
  def children
    Children.new({
        cc_conditions: self.association( :cc_conditions),
        cc_loops:      self.association( :cc_loops),
        cc_questions:  self.association( :cc_questions),
        cc_sequences:  self.association( :cc_sequences),
        cc_statements: self.association( :cc_statements)
    })
  end

  def construct_children(branch = nil)
    query_children = lambda do |query_branch, cc|
      if query_branch.nil?
        return cc.children.map { |c| {id: c.id, type: c.class.name } }
      else
        return cc.children.select { |c| c.branch == query_branch }.map { |c| {id: c.id, type: c.class.name } }
      end
    end

    begin
      cs = $redis.hget 'construct_children:' +
                           self.class.to_s +
                           (branch.nil? ? '' : (':' + branch.to_s)), self.id

      if cs.nil?
        cs = query_children.call branch, self
        $redis.hset 'construct_children:' +
                        self.class.to_s +
                        (branch.nil? ? '' : (':' + branch.to_s)), self.id,  cs.to_json
      else
        cs = JSON.parse cs
      end
    rescue
      cs = query_children.call branch, self
    end
    cs
  end

  # Returns the first child construct
  #
  # @return [ControlConstruct] First child construct
  def first_child
    children.min_by { |x| x.position}
  end

  # Returns the last child construct
  #
  # @return [ControlConstruct] Last child construct
  def last_child
    children.max_by { |x| x.position}
  end

  # Returns true if the construct has any children
  #
  # @return [Boolean] True for having children; False for no children
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
