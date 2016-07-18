class RdsQs < ActiveRecord::Base
  belongs_to :response_domain, polymorphic: true
  belongs_to :question, polymorphic: true

  before_create :set_instrument

  def set_instrument
    if self.instrument_id.nil?
      self.instrument_id = question.instrument_id || response_domain.instrument_id
    end
  end
end
