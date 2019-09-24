# The Code is based on the Code model from DDI3.X and serves as the join between
# Categories and CodeLists
#
# A Code will have a value and use a Category to form a parallel to a DDI3.X Code
# which belongs to a single Code List.
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/logicalproduct_xsd/elements/Code.html
#
# === Properties
# * Value
# * Order
class Code < ApplicationRecord
  # This model is exportable as DDI
  include Exportable

  # This model can be tracked using an Identifier
  include Identifiable

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'co'

  # XML tag name
  TYPE = 'Code'

  # All Codes must belong to a Code List
  belongs_to :code_list

  # Each Code must have one Category
  belongs_to :category

  # Each Code belongs to an instrument to ensure security and validity
  belongs_to :instrument

  # Before creating a Code in the database ensure the instrument has been set
  before_create :set_instrument

  # Accept nested attributes for category so that we can manage the
  # Category from within a code form.
  accepts_nested_attributes_for :category

  # All Codes require a CodeList and Category
  validates :category, :code_list, presence: true

  # Delegates label to Category, protecting against nil Category
  delegate :label, to: :category, allow_nil: true

  # Sets instrument_id from the Code List that this Code belongs to
  def set_instrument
    self.instrument_id = self.code_list.instrument_id
  end
end
