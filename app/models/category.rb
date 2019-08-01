# The Category model directly relates to the DDI3.X Category model
#
# Typically multiple categories are used to create {CodeList CodeLists}.
#
# Please visit https://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/logicalproduct_xsd/elements/Category.html
#
# === Properties
# * Label
class Category < ApplicationRecord
  # This model is exportable as DDI
  include Exportable

  # This model can be tracked using an Identifier
  include Identifiable

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'ca'

  # XML tag name
  TYPE = 'Category'

  # All categories must belong to an {Instrument}
  belongs_to :instrument

  # Each Category can be used by many {Code Codes}
  has_many :codes, inverse_of: :category

  # All Categories require a label
  validates :label, presence: true, uniqueness: { scope: :instrument_id }
end
