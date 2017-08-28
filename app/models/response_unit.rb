# The ResponseUnit is based on the ResponseUnit model from DDI3.X
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/datacollection_xsd/elements/ResponseUnit.html
#
# === Properties
# * Label
class ResponseUnit < ApplicationRecord
  # All response units must belong to an instrument
  belongs_to :instrument

  # Response units can be reused for many {CcQuestion questions}
  has_many :questions, class_name: 'CcQuestion', inverse_of: :response_unit
end
