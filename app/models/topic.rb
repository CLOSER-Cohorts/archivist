# Topic represents a single entry from a controlled vocabulary of
# terms that can be applied to {CcQuestion questions} and
# {Variable variables}.
#
# Each item can only have one Topic.
#
# === Properties
# * Name
# * Code
# * Description
class Topic < ApplicationRecord
  # Each Topic can have a single parent Topic
  belongs_to :parent, class_name: 'Topic'

  # Each Topic can have multiple child Topics
  has_many :children, -> { includes(:children) }, class_name: 'Topic', foreign_key: :parent_id, dependent: :destroy

  # Make the level set and get-able
  attr_accessor :level

  def to_s
    name
  end

  # Returns counts for the number of uses by each study on
  # {CcQuestion questions}
  #
  # @return [Array] List of use counts by study
  def question_statistics
    sql = <<~SQL
        SELECT
          i.study,
          COUNT(*)
        FROM topics t INNER JOIN links l ON t.id = l.topic_id
          INNER JOIN cc_questions qc ON l.target_id = qc.id AND l.target_type = 'CcQuestion'
          INNER JOIN instruments i ON qc.instrument_id = i.id
          WHERE t.id = #{self.id}
          GROUP BY i.study;
    SQL
    ActiveRecord::Base.connection.execute sql
  end

  # Returns counts for the number of uses by each study on
  # {Variable variables}
  #
  # @return [Array] List of use counts by study
  def variable_statistics
    sql = <<~SQL
        SELECT
          d.study,
          COUNT(*)
        FROM topics t INNER JOIN links l ON t.id = l.topic_id
          INNER JOIN variables v ON l.target_id = v.id AND l.target_type = 'Variable'
          INNER JOIN datasets d ON v.dataset_id = d.id
          WHERE t.id = #{self.id}
          GROUP BY d.study;
    SQL
    ActiveRecord::Base.connection.execute sql
  end

  # Returns all Topics in hierarchical order, but as a flat
  # array.
  #
  # @return [Array] Topics in hierarchical order
  def self.flattened_nest
    output = []
    tops = Topic.where parent_id: nil
    runner = lambda do |parent, level|
      parent.level = level
      output.append parent
      unless parent.children.nil?
        parent.children.each do |child|
          runner.call child, level + 1
        end
      end
    end
    tops.each do |seq|
      runner.call seq, 1
    end
    output
  end
end
