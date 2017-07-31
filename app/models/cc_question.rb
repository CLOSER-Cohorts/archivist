# The CcQuestion model directly relates to the DDI3.X QuestionConstruct model
#
# Questions are one of the five control constructs used in the questionnaire profile
# and used in Archivist. This control construct provides a join between a question
# and the construct layer. They typically represent a question asked at a particular
# point of an questionnaire to an individual denoted by the response unit.
#
# Please visits
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
  has_many :variables, through: :maps

  # All CcQuestions require a ResponseUnit
  validates :question, :response_unit, presence: true

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

  # Returns the label of the base question
  #
  # Uses Redis caching for performance.
  #
  # @return [String] Base question label
  def base_label
    cached_value('base_label') { question.label }
  end

  # Provides a wrapper for properties to be cached using Redis
  #
  # TODO: Should this method be private?
  # TODO: Can this method be abstracted and applied more uniformly
  #
  # @param [String] label Key for cached property
  #
  # @return [String] Property value
  def cached_value(label)
    key = 'qc_question:' + label
    begin
      value = $redis.hget key, self.id
    rescue
      Rails.logger.warn 'Cannot get ' + key + ' from Redis cache'
    end
    if value.nil?
      value = yield
      unless value.nil?
        begin
          $redis.hset key, self.id, value
        rescue
          Rails.logger.warn 'Cannot set ' + key + ' to Redis cache'
        end
      end
    end
    value
  end

  # Returns all possible mappings that could join Strands into a Cluster
  #
  # TODO: Should be abstracted to a library (Mappable?)
  #
  # @return [Array] Empty array
  def cluster_maps
    []
  end

  # Returns the mapping level where the root questions are level 1
  #
  # @return [Integer] 1
  def level
    1
  end

  # Returns the label of the ResponseUnit
  #
  # Uses Redis caching for performance.
  #
  # @return [String] ResponseUnit label
  def response_unit_label
    cached_value('response_unit_label') { response_unit.label }
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

  # Returns all possible mappings that could be used to create a Strand
  #
  # @return [Array] Array of mapped variables
  def strand_maps
    self.variables.to_a
  end
end
