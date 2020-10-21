# The ResponseDomainCode is based on the CodeDomain model from DDI3.X and serves as creates a
# response domain for a {CodeList}
#
# Using the min_responses and max_responses properties cardinality can be recorded.
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/datacollection_xsd/elements/CodeDomain.html
#
# === Properties
# * Min Responses
# * Max Responses
class ResponseDomainCode < ApplicationRecord
  # This model has all the standard {ResponseDomain} features from DDI3.X
  include ResponseDomain

  # All ResponseDomainCodes must belong to a {CodeList}
  belongs_to :code_list, inverse_of: :response_domain_code

  # ResponseDomainCodes can have many {Code}s through {CodeList}
  has_many :codes, through: :code_list

  # Before creating a ResponseDomainCode in the database ensure the instrument has been set
  before_create :set_instrument

  # RDCs do not have their own label, so it is delagated to the {CodeList} it belongs to
  delegate :label, to: :code_list

  validates :min_responses, :max_responses, presence: true, numericality: { only_integer: true, allow_blank: true }
  validates :code_list, presence: true

  private  # private methods
  # Sets instrument_id from the {CodeList} that this ResponseDomainCode belongs to
  def set_instrument
    self.instrument_id = code_list.instrument_id
  end
end
