# The CcQuestion model directly relates to the DDI3.X QuestionConstruct model
#
# Questions are one of the five control constructs used in the questionnaire profile
# and used in Archivist. This control construct provides a join between a question
# and the construct layer. They typically represent a question asked at a particular
# point of an questionnaire to an individual denoted by the response unit.
#
# Please visits http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/datacollection_xsd/elements/QuestionConstruct.html
#
class CcQuestion < ::ControlConstruct
  self.primary_key = :id

  # This model can have a Topic linked to it
  include Linkable::Model

  # This model can contain linkable items
  include LinkableParent

  # This model can be used in mapping
  include Mappable

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'qc'

  # XML tag name
  TYPE = 'QuestionConstruct'

  # All QuestionConstructs must have a base question (QuestionItem or QuestionGrid)
  belongs_to :question, polymorphic: true

  # All QuestionConstructs must have one ResponseUnit, to which the question is directed
  belongs_to :response_unit

  # Maps provide the junction model for the many-to-many polymorphic join between
  # CcQuesitons and Variables for mapping.
  has_many :maps, as: :source, dependent: :destroy

  # All Variables associated through mapping
  has_many :variables, through: :maps, dependent: :destroy
  has_many :variable_topics, -> { distinct }, through: :variables, as: :topic, source: :topic

  # All CcQuestions require a ResponseUnit
  validates :label, uniqueness: { scope: :instrument_id }
  validates :question, :response_unit, presence: true

  # Validate to stop topic conflict between Variable(s) and CcQuestion
  validate :topic_conflict
  validate :resolved_topic_conflict

  delegate :label, to: :response_unit, allow_nil: true, prefix: true
  delegate :label, to: :question, allow_nil: true, prefix: :base
  delegate :control_construct_scheme, to: :instrument, allow_nil: true

  def topic_conflict
    return unless topic
    associated_variable_topics = variables.map(&:topic).uniq.compact
    if associated_variable_topics.present? && !associated_variable_topics.include?(topic)
      errors.add(:topic, I18n.t('activerecord.errors.models.cc_question.attributes.topic.conflict', topics: variable_topics.to_sentence, variables: variables.to_sentence))
    end
  end

  def resolved_topic_conflict
    return if topic
    variables_grouped_by_topic = variables.group_by(&:topic)
    if variables_grouped_by_topic.keys.count > 1
      new_topics = variables_grouped_by_topic.keys - [resolved_topic]
      new_variables = variables_grouped_by_topic.values_at(*new_topics).flatten
      errors.add(:topic, I18n.t('activerecord.errors.models.cc_question.attributes.resolved_topic.variables_conflict', new_variables: new_variables.to_sentence, new_topics: new_topics.to_sentence, existing_topic: resolved_topic))
    end
  end

  def resolved_topic
    return topic if topic
    variable_topics.first
  end

  def to_s
    base_label
  end

  # In order to create a construct, it must be positioned within another construct.
  # This positional information is held on the corresponding ConstrolConstruct
  # model. This overloaded method is to allow the setting of the custom properties
  # for a question construct.
  #
  # @param [Hash] params Parameters for creating a new question construct
  #
  # @return [CcLoop] Returns newly created CcQuestion
  def self.create_with_position(params)
    super params, true do |obj|
      obj.question_id = params[:question_id]
      obj.question_type = params[:question_type]
      obj.response_unit_id = params[:response_unit_id]
    end
  end

  # Returns the mapping level where the root questions are level 1
  #
  # @return [Integer] 1
  def level
    1
  end

  # Returns a Hash of the attributes and properties for broadcast over
  # archivist-realtime
  #
  # @deprecated Should be replaced by leveraging the jbuilder view
  #
  # @return [Hash] Properties to be broadcast for update
  def rt_attributes
    {
        id: self.id,
        label: self.label,
        type: 'CcQuestion',
        parent: self.parent.nil? ? nil : self.parent.id,
        position: self.position,
        question_id: self.question_id,
        question_type: self.question_type,
        response_unit_id: self.response_unit_id
    }
  end
end
