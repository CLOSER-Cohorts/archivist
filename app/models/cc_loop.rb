# The CcLoop model directly relates to the DDI3.X LoopConstruct model
#
# Loops are one of the five control constructs used in the questionnaire profile
# and used in Archivist. This control construct provides a single repeatable branch for the
# instrument logic to progress. They typically represent a sequence of questions to be asked
# repeatedly until a condition is satisfied.
#
# Please visit
#
# === Properties
# * LoopVar
# * StartVal
# * EndVal
# * LoopWhile
class CcLoop < ApplicationRecord
  # This model is a Construct
  include Construct::Model

  # This model can contain linkable items
  include LinkableParent

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'lp'

  # XML tag name
  TYPE = 'Loop'

  # This model can be a parent and contain child constructs
  is_a_parent

  # In order to create a construct, it must be positioned within another construct.
  # This positional information is held on the corresponding ConstrolConstruct
  # model. This overloaded method is to allow the setting of the custom properties
  # for a loop.
  #
  # @param [Hash] params Parameters for creating a new loop
  #
  # @return [CcLoop] Returns newly created CcLoop
  def self.create_with_position(params)
    super do |obj|
      obj.label = params[:label]
      obj.end_val = params[:end_val]
      obj.loop_var = params[:loop_var]
      obj.loop_while = params[:loop_while]
      obj.start_val = params[:start_val]
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
        type: 'CcLoop',
        parent: self.parent.nil? ? nil : self.parent.id,
        position: self.position,
        loop_var: self.loop_var,
        start_val: self.start_val,
        end_val: self.end_val,
        loop_while: self.loop_while,
        children: self.children.map { |x| {id: x.construct.id, type: x.construct.class.name} }
    }
  end
end
