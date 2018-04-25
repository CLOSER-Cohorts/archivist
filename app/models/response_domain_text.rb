# The ResponseDomainText is based on the TextDomain model from DDI3.X
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/datacollection_xsd/elements/TextDomain.html
#
# === Properties
# * Label
# * Maxlen
class ResponseDomainText < ApplicationRecord
  # This model has all the standard {ResponseDomain} features from DDI3.X
  include ResponseDomain

  # Returns the sub-type params
  #
  # @return [String] Sub-type params
  def params
    self.maxlen.nil? ? '' : '(' + '%g' % self.maxlen + ')'
  end
end
