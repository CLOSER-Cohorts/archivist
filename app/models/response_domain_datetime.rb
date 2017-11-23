# The ResponseDomainDatetime is based on the DateTimeDomain model from DDI3.X
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/datacollection_xsd/elements/DateTimeDomain.html
#
# === Properties
# * Datetime Type
# * Label
# * Format
class ResponseDomainDatetime < ApplicationRecord
  # This model has all the standard {ResponseDomain} features from DDI3.X
  include ResponseDomain

  # Return the datetime_type as subtype
  #
  # @return [String] Datetime sub-type
  def subtype
    self.datetime_type
  end

  # Returns the sub-type params
  #
  # @return [String] Sub-type params
  def params
    '(%s)' % @format
  end
end
