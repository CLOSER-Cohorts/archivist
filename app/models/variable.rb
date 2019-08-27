# The Variable is based on the Variable model from DDI3.X
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/logicalproduct_xsd/elements/Variable.html
#
# === Properties
# * Name
# * Label
# * Var_type
class Variable < ApplicationRecord
  # This model can have a Topic linked to it
  include Linkable::Model

  # This model can be used in mapping
  include Mappable

  # This model can be tracked using an Identifier
  include Identifiable

  # All variables must belong to a {Dataset}
  belongs_to :dataset

  # Maps provide the junction model for the many-to-many polymorphic join between
  # CcQuesitons and Variables for mapping.
  has_many :maps, dependent: :destroy

  # Maps where this object is the source instead of the destination
  # Variable
  has_many :reverse_maps, -> { where source_type: 'Variable' }, class_name: 'Map', foreign_key: :source_id

  # All {CcQuestion questions} associated through mapping
  has_many :questions, through: :maps, as: :source, source: :source, source_type: 'CcQuestion'
  has_many :question_topics, -> { distinct }, through: :questions, as: :topic, source: :topic

  # All source {Variable Variables}
  has_many :src_variables, through: :maps, as: :source, source: :source, source_type: 'Variable'

  # All destination {Variable Variables}
  has_many :der_variables, :through => :reverse_maps, :source => :variable

  # Groupings provide the junction model for the many-to-many join
  # with {Group Groups}
  has_many :groupings, as: :item

  # All {Group Groups} that this Variable is contained within
  has_many :group, through: :groupings

  validates :dataset, presence: true
  validate :topic_conflict

  def to_s
    name
  end

  def topic_conflict
    return unless topic
    cc_question_topics = questions.map(&:topic).uniq.compact
    if cc_question_topics.present? && !cc_question_topics.include?(topic)
      errors.add(:topic, I18n.t('activerecord.errors.models.variable.attributes.topic.conflict', topics: cc_question_topics.to_sentence, questions: questions.to_sentence))
    end
  end

  def resolved_topic
    return topic if topic
    question_topics.first
  end

  # Adds a new source item by label
  #
  # @param [String] source_labels The label of the new source item
  # @param [optional, Integer] x X coordinate in source is {QuestionGrid}
  # @param [optional, Integer] y Y coordinate in source is {QuestionGrid}
  def add_sources(source_labels, x = nil, y = nil)
    sources = self.var_type == 'Normal' ? find_by_label_from_possible_questions(source_labels) : self.dataset.variables.find_by_name(source_labels)
    [*sources].compact.each do |source|
      if self.maps.create ({
          variable: self,
          source: source,
          x: x,
          y: y
      })
        self.strand + source.strand
      end
    end
  end

  # Returns level of derivation
  #
  # @return [Integer] Derivation level
  def level
    return 2 unless self.questions.empty?
    (1 + self.src_variables.map(&:level).compact.max.to_i)
  end

  # Returns all source items
  #
  # @return [Array] All source {CcQuestion questions} and variables
  def sources
    self.questions.to_a + self.src_variables.to_a
  end

  private # Private method

  # Find a {CcQuestion question} by its label, but scoped
  # by {InstrumentsDatasets} join
  #
  # @param [String] label {CcQuestion} label to be searched for
  # @return [CcQuestion] Question found
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
