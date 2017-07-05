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
class CcCondition < ::ParentalConstruct
  self.primary_key = :id

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'if'

  # XML tag name
  TYPE = 'IfThenElse'

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
