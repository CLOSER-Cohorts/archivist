class Variable < ActiveRecord::Base
  belongs_to :dataset
  has_many :maps
  has_many :questions, through: :maps, as: :source, source: :source, source_type: 'CcQuestion'
  has_many :src_variables, through: :maps, as: :source, source: :source, source_type: 'Variable'
  has_many :der_variables, through: :maps, source: :variable

  include Linkable

  def sources
    self.questions.to_a + self.src_variables.to_a
  end
end
