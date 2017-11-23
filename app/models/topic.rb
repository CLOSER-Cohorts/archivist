class Topic < ApplicationRecord
  belongs_to :parent, class_name: 'Topic'
  has_many :children, class_name: 'Topic', foreign_key: :parent_id, dependent: :destroy

  attr_accessor :level

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
