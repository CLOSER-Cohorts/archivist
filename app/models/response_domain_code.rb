class ResponseDomainCode < ActiveRecord::Base
  include ResponseDomain
  belongs_to :code_list
  delegate :label, to: :code_list
  before_create :set_instrument

  def set_instrument
    instrument_id = code_list.instrument_id
  end
end
