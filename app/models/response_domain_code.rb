class ResponseDomainCode < ApplicationRecord
  include ResponseDomain

  belongs_to :code_list

  before_create :set_instrument
  delegate :label, to: :code_list

  def codes
    self.code_list.codes.map do |x|
      {
          label: x.category.label,
          value: x.value,
          order: x.order
      }
    end
  end

  private
  def set_instrument
    self.instrument_id = code_list.instrument_id
  end
end
