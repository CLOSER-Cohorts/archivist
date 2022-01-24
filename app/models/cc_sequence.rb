# frozen_string_literal: true

# The CcSequence model directly relates to the DDI3.X Sequence model
#
# Sequences are one of the five control constructs used in the questionnaire profile
# and used in Archivist. This control construct provides a single branch as a grouping
# method. They typically represent a section  of a questionnaire, often with a
# particular focus.
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/datacollection_xsd/elements/Sequence.html
#
class CcSequence < ::ParentalConstruct
  self.primary_key = :id

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'se'

  # XML tag name
  TYPE = 'Sequence'

  # Determines if this sequence is the top sequence of an instrument
  def is_top?
    self.parent.nil?
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
        children: self.children.map { |x| {id: x.id, type: x.class.name} }
    }
  end
end
