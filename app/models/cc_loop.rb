# The CcLoop model directly relates to the DDI3.X LoopConstruct model
#
# Loops are one of the five control constructs used in the questionnaire profile
# and used in Archivist. This control construct provides a single repeatable branch for the
# instrument logic to progress. They typically represent a sequence of questions to be asked
# repeatedly until a condition is satisfied.
#
# Please visit https://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/datacollection_xsd/elements/Loop.html
#
# === Properties
# * LoopVar
# * StartVal
# * EndVal
# * LoopWhile
class CcLoop < ::ParentalConstruct
  self.primary_key = :id

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'lp'

  # XML tag name
  TYPE = 'Loop'

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
        type: 'CcLoop',
        parent: self.parent.nil? ? nil : self.parent.id,
        position: self.position,
        loop_var: self.loop_var,
        start_val: self.start_val,
        end_val: self.end_val,
        loop_while: self.loop_while,
        children: self.children.map { |x| {id: x.id, type: x.class.name} }
    }
  end
end
