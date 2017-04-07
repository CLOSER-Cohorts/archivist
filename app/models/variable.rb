class Variable < ApplicationRecord
  belongs_to :dataset
  has_many :maps
  has_many :reverse_maps, -> {where source_type: 'Variable'}, class_name: 'Map', foreign_key: :source_id
  has_many :questions, through: :maps, as: :source, source: :source, source_type: 'CcQuestion'
  has_many :src_variables, through: :maps, as: :source, source: :source, source_type: 'Variable'
  has_many :der_variables, :through => :reverse_maps, :source => :variable

  include Linkable
  include Mappable

  def sources
    self.questions.to_a + self.src_variables.to_a
  end

  def strand_maps
    self.questions.to_a
  end

  def cluster_maps
    self.der_variables.to_a + self.src_variables.to_a
  end

  def level
    return 2 unless self.questions.empty?
    (1 + self.src_variables.map(&:level).compact.max.to_i)
  end

  def add_source(source, x = nil, y = nil)
    if self.maps.create ({
      variable: self,
      source:   source,
      x:        x,
      y:        y
    })
      self.strand&.cluster&.delete
      self.strand&.delete
    end
  end
end
