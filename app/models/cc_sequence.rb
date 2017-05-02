# The CcSequence model directly relates to the DDI3.X SequenceConstruct model
#
# Sequences are one of the five control constructs used in the questionnaire profile
# and used in Archivist. This control construct provides a single branch as a grouping
# method. They typically represent a section  of a questionnaire, often with a
# particular focus.
#
# Please visit
class CcSequence < ApplicationRecord
  # This model is a Construct
  include Construct::Model

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'se'

  # XML tag name
  TYPE = 'Sequence'

  # This model can be a parent and contain child constructs
  is_a_parent

  # In order to create a construct, it must be positioned within another construct.
  # This positional information is held on the corresponding ConstrolConstruct
  # model. This overloaded method is to allow the setting of the custom properties
  # for a sequence construct.
  #
  # @param [Hash] params Parameters for creating a new sequence construct
  #
  # @return [CcLoop] Returns newly created CcSequence
  def self.create_with_position(params)
    super do |obj|
      obj.label = params[:label]
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
        type: 'CcSequence',
        parent: self.parent.nil? ? nil : self.parent.id,
        position: self.position,
        literal: self.literal,
        children: self.children.map { |x| {id: x.construct.id, type: x.construct.class.name} }
    }
  end
end
