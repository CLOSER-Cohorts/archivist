# The Category model directly relates to the DDI3.X Category model
#
# Typically multiple categories are used to create {CodeList CodeLists}.
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/logicalproduct_xsd/elements/Category.html
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

  # Before creating a new model in the database, check whether this would be a duplicate
  before_create :no_duplicates

  # Each Category can be used by many {Code Codes}
  has_many :codes, inverse_of: :category

  # All Categories require a label
  validates :label, presence: true

  private # Private methods

  # Checks that the Category does not already exist in the database
  #
  # All categories must have unique labels within the scope of an instrument
  def no_duplicates
    orig = self.instrument.categories.find_by_label self.label
    unless orig.nil?
      self.id = orig.id
      throw :abort
    end
  end
end
