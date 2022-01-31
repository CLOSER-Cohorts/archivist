# frozen_string_literal: true

# The CcStatement model directly relates to the DDI3.X Statement model
#
# Statements are one of the five control constructs used in the questionnaire profile
# and used in Archivist. This control construct allows a one-off text string to be
# placed into the structure of a questionnaire. They typically represent a statement
# made to the respondent for clarification or framing purposes.
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/archive_xsd/elements/Statement.html
#
# === Properties
# * Literal
class CcStatement < ::ControlConstruct
  self.primary_key = :id

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'si'

  # XML tag name
  TYPE = 'StatementItem'

  # All CcStatements require a literal
  validates :literal, presence: true
  validates :label, uniqueness: { scope: :instrument_id }

  # In order to create a construct, it must be positioned within another construct.
  # This positional information is held on the corresponding ConstrolConstruct
  # model. This overloaded method is to allow the setting of the custom properties
  # for a statement construct.
  #
  # @param [Hash] params Parameters for creating a new statement construct
  #
  # @return [CcLoop] Returns newly created CcStatement
  def self.create_with_position(params)
    super do |obj|
      obj.label = params[:label]
      obj.literal = params[:literal]
    end
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
        type: 'CcStatement',
        parent: self.parent.nil? ? nil : self.parent.id,
        position: self.position,
        literal: self.literal,
        instrument_id: self.instrument_id
    }
  end
end
