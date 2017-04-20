class Variable < ApplicationRecord
  belongs_to :dataset
  has_many :maps, dependent: :destroy
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

  def add_sources(source_labels, x = nil, y = nil)
    sources = @var_type == 'Normal' ? find_by_label_from_possible_questions(source_labels) : self.dataset.variables.find_by_name(source_labels)
    [*sources].compact.each do |source|
      if self.maps.create ({
          variable: self,
          source:   source,
          x:        x,
          y:        y
      })
        self.strand + source.strand
      end
    end
  end

  private
  def find_by_label_from_possible_questions(label)
    sql = <<~SQL
            SELECT ccq.*
            FROM instruments_datasets ids
            INNER JOIN instruments i
            ON i.id = ids.instrument_id
            INNER JOIN cc_questions ccq
            ON ccq.instrument_id = i.id
            INNER JOIN control_constructs cc
            ON cc.construct_id = ccq.id
            AND cc.construct_type = 'CcQuestion'
            WHERE ids.dataset_id = ?
            AND cc.label IN (?)
            ORDER BY ccq.id
    SQL
    CcQuestion.find_by_sql [
                               sql,
                               self.dataset_id,
                               label
                           ]
  end
end
