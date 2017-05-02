# The CcCondition model directly relates to the DDI3.X IfThenElseConstruct model
#
# Conditions are one of the five control constructs used in the questionnaire profile
# and used in Archivist. This control construct provides two branches for the
# instrument logic to progress. They typically represent a filter or conditional sequence
# with a questionnaire.
#
# Please visit
#
# === Properties
# * Literal
# * Logic
class CcCondition < ApplicationRecord
  # This model is a Construct
  include Construct::Model

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'if'

  # XML tag name
  TYPE = 'IfThenElse'

  # This model can be a parent and contain child constructs
  is_a_parent

  # In order to create a construct, it must be positioned within another construct.
  # This positional information is held on the corresponding ConstrolConstruct
  # model. This overloaded method is to allow the setting of the custom properties
  # for a condition.
  #
  # @param [Hash] params Parameters for creating a new condition
  #
  # @return [CcCondition] Returns newly created CcCondition
  def self.create_with_position(params)
    super do |obj|
      obj.label = params[:label]
      obj.literal = params[:literal]
      obj.logic = params[:logic]
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
        type: 'CcCondition',
        parent: self.parent.nil? ? nil : self.parent.id,
        position: self.position,
        literal: self.literal,
        logic: self.logic,
        children: self.children.where(branch: 0).map { |x| {id: x.construct.id, type: x.construct.class.name} },
        fchildren: self.children.where(branch: 1).map { |x| {id: x.construct.id, type: x.construct.class.name} }
    }
  end
end
