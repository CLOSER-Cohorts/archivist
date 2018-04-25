# The QuestionItem model directly relates to the DDI3.X QuestionItem model
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/datacollection_xsd/elements/QuestionItem.html
#
# === Properties
# * Label
# * Literal
class QuestionItem < ApplicationRecord
  # This model has all the standard Question features from DDI3.X
  include Question::Model

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'qi'

  # XML tag name
  TYPE = 'QuestionItem'

  # Returns all response domains in order
  #
  # @return [Array] All response domains
  def response_domains
    self.rds_qs.order(:rd_order).includes(:response_domain).map &:response_domain
  end

  # Exports as an XML fragment
  #
  # @return [String] XML fragment
  def to_xml_fragment
    Exporters::XML::DDI::Fragment.export_3_2 Exporters::XML::DDI::QuestionItem, self
  end
end
