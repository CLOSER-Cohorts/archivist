# frozen_string_literal: true

# The ResponseDomainNumeric is based on the NumericDomain model from DDI3.X
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/datacollection_xsd/elements/NumericDomain.html
#
# === Properties
# * Numeric Type
# * Label
# * Min
# * Max
class ResponseDomainNumeric < ApplicationRecord
  # This model has all the standard {ResponseDomain} features from DDI3.X
  include ResponseDomain

  # Return the numeric_type as subtype
  #
  # @return [String] Numeric sub-type
  def subtype
    self.numeric_type
  end

  # Returns the sub-type params
  #
  # @return [String] Sub-type params
  def params
    '(' + (self.min.nil? ? '~' : '%g' % self.min) + ',' + (self.max.nil? ? '~' : '%g' % self.max) + ')'
  end

  # Return min in the correct class if it's nil, integer or float
  #
  # @return [Nil, Integer, Float] Min value
  def min
    return super if super.nil?
    (numeric_type == 'Integer') ? super.to_i : super.to_f
  end

  # Return max in the correct class if it's nil, integer or float
  #
  # @return [Nil, Integer, Float] Max value
  def max
    return super if super.nil?
    (numeric_type == 'Integer') ? super.to_i : super.to_f
  end
end
