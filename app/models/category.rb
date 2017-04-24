# The Category model directly relates to the DDI3.X Category model
#
# Typically multiple categories are used to create code lists.
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/logicalproduct_xsd/elements/Category.html
#
# === Properties
# * Label
class Category < ApplicationRecord
  # This model is exportable as DDI
  include Exportable

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'ca'

  # XML tag name
  TYPE = 'Category'

  # All categories must belong to an instrument
  belongs_to :instrument

  # Before creating a new model in the database, check whether this would be a duplicate
  before_create :no_duplicates

  # Each category can be used by many codes
  has_many :codes

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
