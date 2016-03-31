class Topic < ActiveRecord::Base
  belongs_to :parent, class_name: 'Topic'
  has_many :children, class_name: 'Topic', foreign_key: :parent_id, dependent: :destroy

  attr_accessor :level

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
