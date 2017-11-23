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
end
